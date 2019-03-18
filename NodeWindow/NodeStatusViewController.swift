//
//  NodeStatusViewController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/15/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class NodeStatusViewController: NSViewController {

    @IBOutlet weak var statusLabel: NSTextField!
    
    var node: Node? {
        didSet {
            self.stateObserver = node?.observe(\Node.stateChange, options: .new) { node, change in
                self.updateState()
            }
        }
    }
    
    private var stateObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func disclosureButton(_ sender: Any) {
        
        guard let splitController = (parent as? NSSplitViewController), let splitItem = splitController.splitViewItems.last else { return }
        
        splitItem.collapseBehavior = .preferResizingSplitViewWithFixedSiblings
        splitController.toggleSidebar(nil)
        
    }
    
    private func updateState() {
        
        DispatchQueue.main.async {
            guard let node = self.node else {
                self.statusLabel.stringValue = "🛑 No node available"
                return
            }
            
            switch node.state {
            case .notInstalled:
                
                self.statusLabel.stringValue = "⚠️ \(node.nodeType.rawValue.capitalizedFirstChar()) not installed"
                
            case .stopped:
                
                self.statusLabel.stringValue = "⚠️ No node running"
                
            case .internalNode:
                
                self.statusLabel.stringValue = "✅ Running internal node"
                
            case .externalBound:
                
                self.statusLabel.stringValue = "✅ Bound to external node"
                
            case .error(_):
                
                self.statusLabel.stringValue = "🛑 Node error"
            }
        }
    }

}
