//
//  DocumentController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 1/23/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

protocol AdditionalDocumentPreparing: AnyObject {
    
    func didMakeDocumentForExisitingFile(url: URL)
}

class DocumentController: NSDocumentController {
    
    private(set) lazy var autosaveDirectoryURL: URL =  try! FileManager.default.url(for: .autosavedInformationDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    private(set) var accessorySelectedEncoding: String.Encoding?
    
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
    
    
    /// open document
    override func openDocument(withContentsOf url: URL, display displayDocument: Bool, completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
        
        // Opening windows manually, so always pass displayDocument = false to super
        super.openDocument(withContentsOf: url, display: false) { (document, documentWasAlreadyOpen, error) in
            
            // If error was returned, we're done.
            guard error == nil else {
                //assertionFailure(error!.localizedDescription)
                completionHandler(document, documentWasAlreadyOpen, error)
                return
            }
            
            if let textDocument = document as? TextDocument {
                
                // 1. invalidate encoding that was set in the open panel
                self.accessorySelectedEncoding = nil
                
                // 2. If displayDocument is false, user selected text document in the
                //    file navigator. Caller will handle displaying the document.
                guard displayDocument == true else {
                    completionHandler(textDocument, documentWasAlreadyOpen, error)
                    return
                }
                
                // 3. Show text document in a new window.
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
        
        // [caution] This method may be called from a background thread due to concurrent-opening.
        
        do {
            try self.checkOpeningSafetyOfDocument(at: url, typeName: typeName)
            
        } catch {
            // ask user for opening file
            try DispatchQueue.syncOnMain {
                guard self.presentError(error) else { throw CocoaError(.userCancelled) }
            }
        }
        
        // make document
        let document = try super.makeDocument(withContentsOf: url, ofType: typeName)
        
        (document as? AdditionalDocumentPreparing)?.didMakeDocumentForExisitingFile(url: url)
        
        return document
    }

    override func beginOpenPanel(_ openPanel: NSOpenPanel, forTypes inTypes: [String]?, completionHandler: @escaping (Int) -> Void) {
        
        // TODO: If inTypes is passed to super, the open dialog will allow *every*
        // document to be opened, including PDFs and PNGs
        // Quick fix: hardcoding supported contracts.
        // This doesn't affect opening other files (e.g. js or json) from within
        // project window's file navigator.
        //        inTypes?.compactMap { print($0) }
        super.beginOpenPanel(openPanel, forTypes: ["composite", "scilla", "sol"]) { (result: Int) in
            completionHandler(result)
        }
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
    
    
    override func noteNewRecentDocument(_ document: NSDocument) {

        // Only add ProjectDocuments to the recent open menu, not individual text documents
        guard document is ProjectDocument else { return }
        super.noteNewRecentDocument(document)
    }
    
    
    /// return enability of actions
    override func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        
        if item.action == #selector(newWindowForTab) {
            return self.currentDocument != nil
        }
        
        if item.action == #selector(newFile(_:)) {
            return self.currentDocument != nil
        }
        
        return super.validateUserInterfaceItem(item)
    }
    
    override func newDocument(_ sender: Any?) {
        assertionFailure()
        // Show new file template here
    }
    
    /// Check file before creating a new document instance.
    ///
    /// - Parameters:
    ///   - url: The location of the new document object.
    ///   - typeName: The type of the document.
    /// - Throws: `DocumentReadError`
    private func checkOpeningSafetyOfDocument(at url: URL, typeName: String) throws {
        
        // check if the file is possible binary
        let cfTypeName = typeName as CFString
        let binaryTypes = [kUTTypeImage,
                           kUTTypeAudiovisualContent,
                           kUTTypeGNUZipArchive,
                           kUTTypeZipArchive,
                           kUTTypeBzip2Archive]
        if binaryTypes.contains(where: { UTTypeConformsTo(cfTypeName, $0) }),
            !UTTypeEqual(cfTypeName, kUTTypeScalableVectorGraphics)  // SVG is plain-text (except SVGZ)
        {
            throw DocumentReadError(kind: .binaryFile(type: typeName), url: url)
        }
        
        // check if the file is enorm large
        let fileSizeThreshold = UserDefaults.standard[.largeFileAlertThreshold]
        if fileSizeThreshold > 0,
            let fileSize = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize,
            fileSize > fileSizeThreshold
        {
            throw DocumentReadError(kind: .tooLarge(size: fileSize), url: url)
        }
    }

    
    /// Based on TextEdit example, see https://stackoverflow.com/questions/34497218/nsdocument-opening-over-a-default-document
    func replace(_ document: NSDocument, inController controller: NSWindowController) {
        
        guard Thread.isMainThread else { return assertionFailure() }
        
        let documentToBeReplaced = currentDocument // Note: Can be nil
        
        // Pass project
        if let document = document as? TextDocument, document.project == nil, let documentToBeReplaced = documentToBeReplaced as? TextDocument {
            document.project = documentToBeReplaced.project
        }
        
        document.addWindowController(controller) //(controller.copy() as! NSWindowController)
        controller.document = document

        if let documentToBeReplaced = documentToBeReplaced {
            documentToBeReplaced.removeWindowController(controller)
            documentToBeReplaced.close()
            removeDocument(documentToBeReplaced)
        }
    }
}

extension DocumentController {
    
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
    
    /// Display new window for project
    ///
    /// - Parameters:
    ///   - project: project to be displayed
    ///   - openFile: file to opened. Overrides defaultOpenFile property
    ///   - completionHandler: called when completed
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
    }
    
    
    /// Creates new window for textdocument. Finds project file if needed
    ///
    ///
    /// - Parameters:
    ///   - textDocument: text document to display
    ///   - url: url of text document
    ///   - completionHandler: called when done
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
        
        // 2. No project file found. Hand over to importViewController
        let importWindowController = (NSStoryboard(name: NSStoryboard.Name("Import"), bundle: nil).instantiateInitialController()! as! NSWindowController)
        importWindowController.showWindow(self)
        (importWindowController.contentViewController as! ImportViewController).representedObject = textDocument
        completionHandler(textDocument, nil)
    }

    
    /// Shows text document and project
    ///
    /// - Parameters:
    ///   - textDocument: textDocument to be displayed
    ///   - project: project textDocument is part of
    private func showTextDocument(_ textDocument: TextDocument, asPartOf project: ProjectDocument) {
        
        textDocument.project = project
        textDocument.makeWindowControllers()
        textDocument.showWindows()
    }
}


// MARK: - Error

private struct DocumentReadError: LocalizedError, RecoverableError {
    
    enum ErrorKind {
        case binaryFile(type: String)
        case tooLarge(size: Int)
    }
    
    let kind: ErrorKind
    let url: URL
    
    
    var errorDescription: String? {
        
        switch self.kind {
        case .binaryFile:
            return String(format: "The file “%@” doesn’t appear to be text data.".localized,
                          self.url.lastPathComponent)
            
        case .tooLarge(let size):
            return String(format: "The file “%@” has a size of %@.".localized,
                          self.url.lastPathComponent,
                          ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))
        }
    }
    
    
    var recoverySuggestion: String? {
        
        switch self.kind {
        case .binaryFile(let type):
            let localizedTypeName = (UTTypeCopyDescription(type as CFString)?.takeRetainedValue() as String?) ?? "unknown file type"
            return String(format: "The file is %@.\n\nDo you really want to open the file?".localized, localizedTypeName)
            
        case .tooLarge:
            return "Opening such a large file can make the application slow or unresponsive.\n\nDo you really want to open the file?".localized
        }
    }
    
    
    var recoveryOptions: [String] {
        
        return ["Open".localized,
                "Cancel".localized]
    }
    
    
    func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        
        return (recoveryOptionIndex == 0)
    }
    
}
