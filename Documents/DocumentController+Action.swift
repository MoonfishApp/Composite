//
//  DocumentController+Action.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 1/26/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

// MARK: Action Messages

extension DocumentController {
    
    /// open a new document as tab in the existing frontmost window
//    @IBAction override func newWindowForTab(_ sender: Any?) {
//    @IBAction func newTab(_ sender: Any?) {
        
//        print("New Tab action")
//
//        guard let document = currentDocument, let window = document.windowForSheet else {
//            assertionFailure()
//            return
//        }
//        let newTab = window.copy() as! NSWindow
//        window.addTabbedWindow(newTab, ordered: .above)
        
//        document.addWindowController(newTab)
        
        // Get active document
        // Copy current NSWindow belonging to active document
        // document.addWindowController(newWindowController)
        // Add NSWindow as tab to active NSWindowController
        
        
        
        // Show current file in new tab
        
        //        let document: NSDocument
        //        do {
        //            document = try self.openUntitledDocumentAndDisplay(false)
        //        } catch {
        //            self.presentError(error)
        //            return
        //        }
        //
        //        document.makeWindowControllers()
        //        document.windowControllers.first?.window?.tabbingMode = .preferred
        //        document.showWindows()
//    }
    
    
    
    /// open current project in a new window
    @IBAction func newWindow(_ sender: Any?) {
        
        print("New Window action")
//        let document: NSDocument
//        do {
//            document = try self.openUntitledDocumentAndDisplay(false)
//        } catch {
//            self.presentError(error)
//            return
//        }
//
//        DocumentWindow.tabbingPreference = .manual
//        document.makeWindowControllers()
//        document.showWindows()
//        DocumentWindow.tabbingPreference = nil
    }
    
    
    @IBAction func newWindowForTab(_ sender: Any?) {
        
        guard let document = currentDocument else { return }
        
        document.makeWindowControllers()
        guard let newTab = document.windowControllers.last?.window else { return }
        document.windowControllers.first?.window?.addTabbedWindow(newTab, ordered: .below)
    }
    
    @IBAction func newProject(_ sender: Any?) {
        
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
        delegate.showProjectTemplates(self)
    }
    
    @IBAction func newFile(_ sender: Any?) {
        
        guard let currentDocument = self.currentDocument, let currentDirectory = currentDocument.fileURL?.deletingLastPathComponent(), let window = currentDocument.windowControllers.first?.window else { return }
        
        let savePanel = NSSavePanel()
        savePanel.directoryURL = currentDirectory
        savePanel.isExtensionHidden = false
        savePanel.allowedFileTypes = ["scilla", "sol", "js", "json"] // TODO: default extension should be first item
        savePanel.beginSheetModal(for: window) { (result) in
            
            guard result == .OK, let location = savePanel.url else { return }
            print("success: \(location)")

            // Create empty document
            let document = TextDocument()
            if let currentDocument = currentDocument as? TextDocument {
                document.project = currentDocument.project
            } else if let currentDocument = currentDocument as? ProjectDocument {
                document.project = currentDocument
            }
            
            document.save(to: location, ofType: "", for: .saveOperation, completionHandler: { error in
                print("done")
                savePanel.close()
                if let windowController = currentDocument.windowControllers.first! as? ProjectWindowController {
                    windowController.document = document
                }
            })
            
        }
    }
    
}
