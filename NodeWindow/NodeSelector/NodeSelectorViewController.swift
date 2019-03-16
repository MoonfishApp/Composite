//
//  NodeSelectorViewController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/15/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class NodeSelectorViewController: NSViewController {

    var selectPlatform: String? = nil {
        didSet {
            print(selectPlatform ?? "")
            //select ...
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
