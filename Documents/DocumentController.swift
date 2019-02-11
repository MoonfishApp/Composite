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
    
    /// open document
    override func openDocument(withContentsOf url: URL, display displayDocument: Bool, completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
        
        // Passing false to displayDocument to prevent two windows to be opened, since
        // we're opening the windows manually. 
        super.openDocument(withContentsOf: url, display: false) { (document, documentWasAlreadyOpen, error) in
            
            // TODO: based on state documentWasAlreadyOpen, decide whether to open
            // the project itself, or the lastOpenedFile in the project
        
            guard error == nil else {
                assertionFailure(error!.localizedDescription)
                return
            }
            
            assert(Thread.isMainThread)
            assert(document != nil)
            
            if let document = document as? TextDocument {
                
                // We probably need to add project to the file?
                
                completionHandler(document, documentWasAlreadyOpen, error)
                return
                
            } else if let project = document as? ProjectDocument {
                
                guard displayDocument == true else {
                    completionHandler(document, documentWasAlreadyOpen, error)
                    return
                }

                if let defaultDocument = project.project?.lastOpenFile {
                    
                    // Create a new editor window with the default file in the editor viewcontroller
                    
                    let defaultDocumentURL = project.workDirectory.appendingPathComponent(defaultDocument)
                    
//                    print("defaultDoc: \(defaultDocument)")
//                    print("URL: \(defaultDocumentURL.path)")
                    
                    guard FileManager.default.fileExists(atPath: defaultDocumentURL.path) == true else {
                        project.makeWindowControllers()
                        project.showWindows()
                        completionHandler(document, documentWasAlreadyOpen, error)
                        return
                    }

                    self.openDocument(withContentsOf: defaultDocumentURL, display: false) { (document, documentWasAlreadyOpen, error) in

                        if let textDocument = document as? TextDocument {
                            textDocument.project = project
                            textDocument.makeWindowControllers()
                            textDocument.showWindows()
                            completionHandler(document, documentWasAlreadyOpen, error)
                            return
                        }
                    }
                } else {
                    
                    // Project does not have default file
                    // Open editor window with project file
                    project.makeWindowControllers()
                    project.showWindows()
                    completionHandler(document, documentWasAlreadyOpen, error)
                    return
                }
                
            } else {
                assertionFailure()
            }
            /*
            //See if default text document can be opened
            // OR see if windows need to be restored
            
            // if default text Doc, run self.openDocument(textdocument, displayDocument: false)
            
            // How do we get the created document here?
            
            textDocument.makeWindowControllers()
            textDocument.showWindows()
            
            
            // invalidate encoding that was set in the open panel
            self.accessorySelectedEncoding = nil
            
            if let transientDocument = transientDocument, let document = document as? TextDocument {
                self.replaceTransientDocument(transientDocument, with: document)
                if displayDocument {
                    document.makeWindowControllers()
                    document.showWindows()
                }
                
            } else if displayDocument, let document = document {
                if self.deferredDocuments.isEmpty {
                    // display the document immediately, because the transient document has been replaced.
                    document.makeWindowControllers()
                    document.showWindows()
                } else {
                    // defer displaying this document, because the transient document has not yet been replaced.
                    self.deferredDocuments.append(document)
                }
            }
            
            completionHandler(document, documentWasAlreadyOpen, error) */
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
    
}
