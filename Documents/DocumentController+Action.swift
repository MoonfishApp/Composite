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
    
    @IBAction func newProject(_ sender: Any?) {
        
        print("New Proejct")
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Template"), bundle: nil)
        let templateController = storyboard.instantiateInitialController() as? NSWindowController
        templateController?.showWindow(sender)
        
        // Show template here?
        
        /*
        let document: NSDocument
        do {
            document = try self.openUntitledDocumentAndDisplay(false)
        } catch {
            self.presentError(error)
            return
        }
        
        DocumentWindow.tabbingPreference = .manual
        document.makeWindowControllers()
        document.showWindows()
        DocumentWindow.tabbingPreference = nil */
    }
    
    @IBAction func newFile(_ sender: Any?) {
    }
    
}
