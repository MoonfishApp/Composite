//
//  DocumentWindowController.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by nakamuxu on 2004-12-13.
//
//  ---------------------------------------------------------------------------
//
//  © 2004-2007 nakamuxu
//  © 2013-2019 1024jp
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Cocoa

final class DocumentWindowController: NSWindowController {
    
    // MARK: Private Properties
    
    private var windowAlphaObserver: UserDefaultsObservation?
    
    @IBOutlet private var toolbarController: ToolbarController?
    
    
    
    // MARK: -
    // MARK: Lifecycle
    
    deinit {
        self.windowAlphaObserver?.invalidate()
    }
    
    
    
    // MARK: Window Controller Methods
    
    /// prepare window
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        // -> It's set as false by default if the window controller was invoked from a storyboard.
        self.shouldCascadeWindows = true
        // -> Do not use "document" for autosave name because homehow windows forget the size with that name (2018-09)
        self.windowFrameAutosaveName = "Document Window"
        
        // set background alpha
        (self.window as! DocumentWindow).backgroundAlpha = UserDefaults.standard[.windowAlpha]
        
        // observe opacity setting change
        self.windowAlphaObserver?.invalidate()
        self.windowAlphaObserver = UserDefaults.standard.observe(key: .windowAlpha, options: [.new]) { [unowned self] change in
            (self.window as? DocumentWindow)?.backgroundAlpha = change.new!
        }
    }
    
    
    /// apply passed-in document instance to window
    override var document: AnyObject? {
        
        didSet {
            guard let document = document as? TextDocument else { return }
            
            self.toolbarController!.document = document
            self.contentViewController!.representedObject = document
            
            // -> In case when the window was created as a restored window (the right side ones in the browsing mode)
            if document.isInViewingMode, let window = self.window as? DocumentWindow {
                window.backgroundAlpha = 1.0
            }
        }
    }
    
    
    
    // MARK: Actions
    
    /// show editor opacity slider as popover
    @IBAction func showOpacitySlider(_ sender: Any?) {
        
        guard
            let window = self.window as? DocumentWindow,
            let origin = sender as? NSView ?? self.contentViewController?.view,
            let sliderViewController = self.storyboard?.instantiateController(withIdentifier: "Opacity Slider") as? NSViewController,
            let contentViewController = self.contentViewController
            else { return assertionFailure() }
        
        sliderViewController.representedObject = window.backgroundAlpha
        
        contentViewController.present(sliderViewController, asPopoverRelativeTo: .zero, of: origin,
                                      preferredEdge: .maxY, behavior: .transient)
    }
    
    
    /// change editor opacity via toolbar
    @IBAction func changeOpacity(_ sender: NSSlider) {
        
        (self.window as! DocumentWindow).backgroundAlpha = CGFloat(sender.doubleValue)
    }
    
}



extension DocumentWindowController: NSUserInterfaceValidations {
    
    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        
        switch item.action {
        case #selector(showOpacitySlider)?:
            return self.window?.styleMask.contains(.fullScreen) == false
        default:
            return true
        }
    }
    
}



extension DocumentWindowController: NSWindowDelegate { }
