//
//  ProjectWindowContentViewController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 1/16/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class ProjectWindowContentViewController: NSSplitViewController {

    override var representedObject: Any? {
        
        didSet {
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
