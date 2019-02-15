//
//  ProjectContentViewController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 1/16/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

// Temp: used for two splitviews in storyboard
final class ProjectContentSplitViewController: NSSplitViewController {

//    var editorItem: NSSplitViewItem {
//        
//    }
//    
    override var representedObject: Any? {
        
        didSet {
            _ = self.children.map { $0.representedObject = representedObject }
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
