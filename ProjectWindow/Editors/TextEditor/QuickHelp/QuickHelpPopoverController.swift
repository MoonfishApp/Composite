//
//  QuickHelpPopoverController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/14/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

final class QuickHelpPopoverController: NSViewController {
    
    @objc private dynamic var keyword: String = ""
    @objc private dynamic var reference: NSAttributedString = NSAttributedString(string: "")
    @objc private dynamic var source: String = ""
    
    @IBOutlet weak var titleTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    /// show popover
    func showPopover(relativeTo positioningRect: NSRect, of parentView: NSView) {
        
        let popover = NSPopover()
        popover.contentViewController = self
        popover.delegate = self
        popover.behavior = .semitransient
        popover.show(relativeTo: positioningRect, of: parentView, preferredEdge: .minY)
        parentView.window?.makeFirstResponder(parentView)
        
        // auto-close popover if selection is changed.
        if let textView = parentView as? NSTextView {
            weak var observer: NSObjectProtocol?
            observer = NotificationCenter.default.addObserver(forName: NSTextView.didChangeSelectionNotification, object: textView, queue: .main, using:
                { (note: Notification) in
                    
                    if !popover.isDetached {
                        popover.performClose(nil)
                    }
                    if let observer = observer {
                        NotificationCenter.default.removeObserver(observer)
                    }
            })
        }
    }
    
    func setup(keyword: String, reference: NSAttributedString, source: String) {
        self.keyword = keyword
        self.reference = reference
        self.source = source
    }
}

// MARK: Delegate

extension QuickHelpPopoverController: NSPopoverDelegate {
    
    /// make popover detachable
    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        
        return true
    }
}
