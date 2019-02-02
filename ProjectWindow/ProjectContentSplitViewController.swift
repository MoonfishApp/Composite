//
//  ProjectContentViewController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 1/16/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

final class ProjectContentSplitViewController: NSSplitViewController {

//    var editorItem: NSSplitViewItem {
//        
//    }
//    
    override var representedObject: Any? {
        
        didSet {

            // Open the right editor, depending on the document
            let editor: NSViewController
            if let _ = representedObject as? ProjectDocument {
                let storyboard = NSStoryboard(name: NSStoryboard.Name("ProjectEditor"), bundle: nil)
                editor = storyboard.instantiateInitialController() as! NSViewController
            } else if let _ = representedObject as? TextDocument {
                let storyboard = NSStoryboard(name: NSStoryboard.Name("CompositeEditor"), bundle: nil)
                editor = storyboard.instantiateInitialController() as! NSViewController
            } else {
                let storyboard = NSStoryboard(name: NSStoryboard.Name("NoEditor"), bundle: nil)
                editor = storyboard.instantiateInitialController() as! NSViewController
            }
            let oldEditor = splitViewItems[1]
            let inspectorItem = splitViewItems[2]
            let newEditor = NSSplitViewItem(viewController: editor)
            removeSplitViewItem(oldEditor)
            removeSplitViewItem(inspectorItem)
            addSplitViewItem(newEditor)
            addSplitViewItem(inspectorItem)
            
            for viewController in self.children {
                viewController.representedObject = representedObject
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    

}

/// Handle tabview changes of Nagivator and Inspector side panes
extension ProjectContentSplitViewController: TabViewControllerDelegate {
    
    func tabViewController(_ viewController: NSTabViewController, didSelect tabViewIndex: Int) {
        
    }
}
