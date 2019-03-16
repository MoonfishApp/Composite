//
//  NodeLogViewController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/15/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class NodeLogViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func disclosureButton(_ sender: Any) {
        
        guard let splitController = (parent as? NSSplitViewController), let splitItem = splitController.splitViewItems.last else { return }
        
        splitItem.collapseBehavior = .preferResizingSplitViewWithFixedSiblings
        splitController.toggleSidebar(nil)
        
    }
}
