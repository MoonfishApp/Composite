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
//    override var representedObject: Any? {
//        
//        didSet {
//            
//            let viewcontroller: NSSplitViewItem
////            if let project = representedObject as? ProjectDocument {
////                self.insertSplitViewItem(<#T##splitViewItem: NSSplitViewItem##NSSplitViewItem#>, at: <#T##Int#>)
////            } else
//            if let document = representedObject as? TextDocument {
//                let storyboard = NSStoryboard(name: NSStoryboard.Name("CompositeEditor"), bundle: nil)
//                let editor = storyboard.instantiateInitialController()
//            } else {
//                return
//            }
//            
//            for viewController in self.children {
//                viewController.representedObject = representedObject
//            }
//        }
//    }
    
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
