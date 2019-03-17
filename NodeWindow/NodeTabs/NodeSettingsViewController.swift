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
            self.updateState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.updateState()
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
        
        guard let node = node else {
            flagsLabel.stringValue = ""
            return
        }
        
        // Show command and flags
        flagsLabel.stringValue = node.command
        
        // Update warning label and restart button
        if node.isRunning == true { // & options have changed
            
            restartLabel.stringValue = "⚠️ Restart node to apply changes"
            restartButton.title = "Restart node"
            restartButton.isEnabled = true
            stopNodeButton.isEnabled = true
            
        } else if node.isRunning == false && node.isBound == false {
            
            restartLabel.stringValue = "⚠️ No node running"
            restartButton.title = "Start node"
            restartButton.isEnabled = true
            stopNodeButton.isEnabled = false
            
        } else if node.isRunning == false && node.isBound == true {
            
            restartLabel.stringValue = "⚠️ External node running"
            restartButton.title = "Start node"
            restartButton.isEnabled = false
            stopNodeButton.isEnabled = false
        }

    }
}
