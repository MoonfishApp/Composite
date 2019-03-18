//
//  NodeSettingsViewController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/17/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class NodeSettingsViewController: NodeGenericTabViewController {

    @IBOutlet weak var restartButton: NSButton!
    @IBOutlet weak var stopNodeButton: NSButton!
    @IBOutlet weak var restartLabel: NSTextField!
    @IBOutlet weak var flagsLabel: NSTextField!

    override var node: Node? {
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
    
    @IBAction func stopNode(_ sender: Any) {
        node?.stopNode()
    }
    
    @IBAction func restartNode(_ sender: Any) {
        do {
            try node?.relaunch()
        } catch {
            print(error)
        }
    }
    
    private func updateState() {
        
        DispatchQueue.main.async {
            guard let node = self.node else {
                self.restartLabel.stringValue = ""
                self.restartButton.title = "Restart node"
                self.flagsLabel.stringValue = ""
                self.restartButton.isEnabled = false
                self.stopNodeButton.isEnabled = false
                return
            }
            
            // Show command and flags
            self.flagsLabel.stringValue = node.command
            
            switch node.state {
            case .notInstalled:
                
                self.restartLabel.stringValue = ""
                self.restartButton.title = "Restart node"
                self.restartButton.isEnabled = false
                self.stopNodeButton.isEnabled = false
                
            case .stopped, .error(_):
                
                self.restartLabel.stringValue = ""
                self.restartButton.title = "Start node"
                self.restartButton.isEnabled = true
                self.stopNodeButton.isEnabled = false
                
            case .internalNode:
                
                // if changes were made:
                self.restartLabel.stringValue = "⚠️ Restart node to apply changes"
                self.restartButton.title = "Restart node"
                self.restartButton.isEnabled = true
                self.stopNodeButton.isEnabled = true
                
            case .externalBound:
                
                self.restartLabel.stringValue = "⚠️ External node running"
                self.restartButton.title = "Start node"
                self.restartButton.isEnabled = false
                self.stopNodeButton.isEnabled = false
                
            }
        }
    }
}
