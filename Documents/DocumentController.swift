//
//  DocumentController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 1/23/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class DocumentController: NSDocumentController {
    
    private(set) lazy var autosaveDirectoryURL: URL =  try! FileManager.default.url(for: .autosavedInformationDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    
    // MARK: -
    // MARK: Lifecycle
    
    override init() {
        
        super.init()
        
        self.autosavingDelay = UserDefaults.standard[.autosavingDelay]
    }
    
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Document Controller Methods
    
    /// automatically insert Shre menu (on macOS 10.13 and later)
    override var allowsAutomaticShareMenu: Bool {
        
        return true
    }
    
    /// returns first project file in directory
    ///
    /// - Parameter directory: directory to search
    /// - Returns: nil if no project file was found, otherwise the first one found
    private func findProjectFile(in directory: URL) throws -> URL? {
        
        // Sanity check
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: directory.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            assertionFailure()
            return nil
        }
        
        return try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]).filter({ $0.pathExtension == ProjectDocument.fileExtension }).first
    }
    
    private func showTextDocument(_ textDocument: TextDocument, asPartOf project: ProjectDocument) {
        
        textDocument.project = project
        textDocument.makeWindowControllers()
        textDocument.showWindows()
    }
    
    
    private func show(project: ProjectDocument, openFile: String? = nil, completionHandler: @escaping (NSDocument?) -> Void) { //, documentWasAlreadyOpen: Bool, error: Error?, completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
        
        // 1. If there's no other file (usually contract) to open, create a window with the project shown.
        guard let defaultDocument = openFile ?? project.project?.defaultOpenFile, FileManager.default.fileExists(atPath: project.workDirectory.appendingPathComponent(defaultDocument).path) == true else {
            
            project.makeWindowControllers()
            project.showWindows()
            completionHandler(project)
            return
        }
        
        // 2. Open default or provided document
        let documentToOpen = project.workDirectory.appendingPathComponent(defaultDocument)
        self.openDocument(withContentsOf: documentToOpen, display: false) { (document, documentWasAlreadyOpen, error) in
            
            if let textDocument = document as? TextDocument {
                self.showTextDocument(textDocument, asPartOf: project)
                completionHandler(textDocument)
                return
            }
        }
        
        
        /*
        
        if let defaultDocument = openFile ?? project.project?.defaultOpenFile {
            
            // If no default or open file is provided, open window with project file
            let defaultDocumentURL = project.workDirectory.appendingPathComponent(defaultDocument)
            guard FileManager.default.fileExists(atPath: defaultDocumentURL.path) == true else {
                project.makeWindowControllers()
                project.showWindows()
                return
            }

            
            // Create a new editor window with the default file in the editor viewcontroller

            self.openDocument(withContentsOf: defaultDocumentURL, display: false) { (document, documentWasAlreadyOpen, error) in
                
                if let textDocument = document as? TextDocument {
                    self.showTextDocument(textDocument, asPartOf: project)
                    return
                }
            }
        } else {
            
            // Project does not have default file
            // Open editor window with project file
            project.makeWindowControllers()
            project.showWindows()
        } */
    }
    
    
    
    private func show(textDocument: TextDocument, url: URL, completionHandler: @escaping (NSDocument?, Error?) -> Void) {
        
        // The app needs a project file to display textDocument
        
        // 1. Check if a project file is in the same directory or parent directory.
        //    If so, open project file
        let documentDirectory = url.deletingLastPathComponent()
        let parentDirectory = documentDirectory.deletingLastPathComponent()
        do {
            if let projectFileURL = [try self.findProjectFile(in: documentDirectory), try self.findProjectFile(in: parentDirectory)].compactMap({ $0 }).first {
                
                // Open found project file
                self.openDocument(withContentsOf: projectFileURL, display: false, completionHandler: { (document, documentWasAlreadyOpen, error) in
                    
                    // Error opening project file
                    guard error == nil else {
                        assertionFailure(error!.localizedDescription)
                        completionHandler(document, error!)
                        return
                    }
                    
                    // Somehow opened document isn't a project file
                    guard let projectDocument = document as? ProjectDocument else {
                        assertionFailure("project isn't a project")
                        completionHandler(document, CompositeError.cannotOpenFile(projectFileURL.path))
                        return
                    }
                    
                    // Show textDocument as part of the project
                    self.showTextDocument(textDocument, asPartOf: projectDocument)
                    completionHandler(textDocument, nil)
                })
                return
            }
        } catch {
            completionHandler(textDocument, error)
            return
        }
        
        
        assertionFailure()
        // 2. There is no project file. Create a lost of platforms and frameworks
        //    that support the text file extension.
        
        // 3. Present user with choice to create a new project.
        
        // 4. Create new project and add selected file
        
    }
    
    /// open document
    override func openDocument(withContentsOf url: URL, display displayDocument: Bool, completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
        
        // Opening windows manually, so always pass displayDocument = false to super
        super.openDocument(withContentsOf: url, display: false) { (document, documentWasAlreadyOpen, error) in
            
            // If error was returned, we're done.
            guard error == nil else {
                assertionFailure(error!.localizedDescription)
                completionHandler(document, documentWasAlreadyOpen, error)
                return
            }
            
            if let textDocument = document as? TextDocument {
                
                // 1. If displayDocument is false, user selected text document in the
                //    file navigator. Caller will handle displaying the document.
                guard displayDocument == true else {
                    completionHandler(textDocument, documentWasAlreadyOpen, error)
                    return
                }
                
                // 2. Show text document in a new window.
                self.show(textDocument: textDocument, url: url) { document, error in
                    completionHandler(document, documentWasAlreadyOpen, error)
                }
                
            } else if let project = document as? ProjectDocument {
                
                // 1. If the project doesn't need a new window, just return the project
                //    This is usually when a user clicks on the project file in file navigator
                guard displayDocument == true else {
                    completionHandler(project, documentWasAlreadyOpen, error)
                    return
                }

                // 2. Show new window
                self.show(project: project) { document in
                    completionHandler(document, documentWasAlreadyOpen, error)
                }

            } else {
                assertionFailure("Document type not supported")
                completionHandler(document, documentWasAlreadyOpen, error)
            }
        }
    }
    
    /// open untitled document
    /// Not supported
    override func openUntitledDocumentAndDisplay(_ displayDocument: Bool) throws -> NSDocument {
        assertionFailure()
        return NSDocument()
    }
    
    /// instantiates a document located by a URL, of a specified type, and returns it if successful
    override func makeDocument(withContentsOf url: URL, ofType typeName: String) throws -> NSDocument {
        
        // make document
        let document = try super.makeDocument(withContentsOf: url, ofType: typeName)
        
        return document
    }

    
    /// add encoding menu to open panel
    /*override func beginOpenPanel(_ openPanel: NSOpenPanel, forTypes inTypes: [String]?, completionHandler: @escaping (Int) -> Void) {
        
        let accessoryController = OpenPanelAccessoryController.instantiate(storyboard: "OpenDocumentAccessory")
        
        // initialize encoding menu and set the accessory view
        accessoryController.openPanel = openPanel
        openPanel.accessoryView = accessoryController.view
        
        // force accessory view visible
        openPanel.isAccessoryViewDisclosed = true
        
        // run non-modal open panel
        super.beginOpenPanel(openPanel, forTypes: inTypes) { (result: Int) in
            
            if result == NSApplication.ModalResponse.OK.rawValue {
                self.accessorySelectedEncoding = accessoryController.selectedEncoding
            }
            
            completionHandler(result)
        }
    }*/
    
    /// return enability of actions
    override func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        
        if item.action == #selector(newWindowForTab) {
            return self.currentDocument != nil
        }
        
        return super.validateUserInterfaceItem(item)
    }
    
    override func newDocument(_ sender: Any?) {
        assertionFailure()
        // Show new file template here
    }
    
    @IBAction func newWindowForTab(_ sender: Any?) {
        
        guard let document = currentDocument else { return }
        
        document.makeWindowControllers()
        guard let newTab = document.windowControllers.last?.window else { return }
        document.windowControllers.first?.window?.addTabbedWindow(newTab, ordered: .below)
    }
    
    /// Based on TextEdit example, see https://stackoverflow.com/questions/34497218/nsdocument-opening-over-a-default-document
    func replace(_ document: NSDocument, inController controller: NSWindowController) {
        
        guard Thread.isMainThread else { return assertionFailure() }
        
        let documentToBeReplaced = currentDocument // Note: Can be nil
        
        document.addWindowController(controller) //(controller.copy() as! NSWindowController)
        controller.document = document

        if let documentToBeReplaced = documentToBeReplaced {
            documentToBeReplaced.removeWindowController(controller)
            documentToBeReplaced.close()
            removeDocument(documentToBeReplaced)
        }

        /*
        if ([NSThread isMainThread]) {
            NSDocument *transientDoc = [documents objectAtIndex:0], *doc = [documents objectAtIndex:1];
            NSArray *controllersToTransfer = [[transientDoc windowControllers] copy];
            NSEnumerator *controllerEnum = [controllersToTransfer objectEnumerator];
            NSWindowController *controller;
            
         
            while (controller = [controllerEnum nextObject]) {
                [doc addWindowController:controller];
                [transientDoc removeWindowController:controller];
            }
            [transientDoc close];
         
            // We replaced the value of the transient document with opened document, need to notify accessibility clients.
            for (NSLayoutManager *layoutManager in [[(Document *)doc textStorage] layoutManagers]) {
                for (NSTextContainer *textContainer in [layoutManager textContainers]) {
                    NSTextView *textView = [textContainer textView];
                    if (textView) NSAccessibilityPostNotification(textView, NSAccessibilityValueChangedNotification);
                }
            }
            
        } else {
            [self performSelectorOnMainThread:_cmd withObject:documents waitUntilDone:YES];
        }*/
        
    }
}
