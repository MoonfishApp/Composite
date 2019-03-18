//
//  NodeTabViewController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/17/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class NodeTabViewController: NSTabViewController {

    weak var node: Node? {
        didSet {
            
            for tab in tabViewItems {
                (tab.viewController as! NodeGenericTabViewController).node = node
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
