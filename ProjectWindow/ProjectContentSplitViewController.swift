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
        
        
        // -> needs layer to mask rounded window corners
        //                to draw backgrounds of subviews correctly on macOS 10.12 (and macOS 10.13?)
        self.view.wantsLayer = true
    }
    

}

/// Handle tabview changes of Nagivator and Inspector side panes
extension ProjectContentSplitViewController: TabViewControllerDelegate {
    
    func tabViewController(_ viewController: NSTabViewController, didSelect tabViewIndex: Int) {
        
    }
}
