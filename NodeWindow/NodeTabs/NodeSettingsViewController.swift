//
//  NodeSettingsViewController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/17/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class NodeSettingsViewController: NodeGenericTabViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var restartButton: NSButton!
    @IBOutlet weak var stopNodeButton: NSButton!
    @IBOutlet weak var restartLabel: NSTextField!
    @IBOutlet weak var flagsLabel: NSTextField!

    override var node: Node? {
        didSet {
            self.stateObserver = node?.observe(\Node.stateChange, options: .new) { node, change in
                self.updateState()
            }
            self.tableView.reloadData()
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

extension NodeSettingsViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        return self.node?.options.options.count ?? 0
    }
}

extension NodeSettingsViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let tableColumn = tableColumn, let node = node else { return nil }
        let option = node.options[row]
        
        let view: NSTableCellView!
        
        if tableColumn.identifier == NSUserInterfaceItemIdentifier("CheckboxColumn") {
            
            let checkbox = NSButton(checkboxWithTitle: " ", target: self, action: #selector(self.checkboxClicked))
            checkbox.tag = row
            checkbox.state = option.enabled == true ? .on : .off
            return checkbox
            
        } else if tableColumn.identifier == NSUserInterfaceItemIdentifier("KeyColumn") {
            
            view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "KeyCell"), owner: self) as? NSTableCellView
            view.textField?.stringValue = option.name
            view.toolTip = option.description
            view.textField?.textColor = NSColor.black
            
        } else if tableColumn.identifier == NSUserInterfaceItemIdentifier("ValueColumn") {
            
            view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ValueCell"), owner: self) as? NSTableCellView
            view.textField?.stringValue = option.userValue ?? option.defaultString ?? ""
            view.textField?.delegate = self
            view.textField?.tag = row
            
        } else {
            
            view = nil
            assertionFailure()
        }
        
        return view
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        
        tableView.editColumn(2, row: row, with: nil, select: true)
        return false
    }
    
    @IBAction func checkboxClicked(_ sender: Any?) {
        
        guard let checkbox = sender as? NSButton, let node = node else { return assertionFailure() }
        
        let row = checkbox.tag
        node.options.enableOption(enabled: checkbox.state == .on, at: row)
        
        if checkbox.state == .on { tableView.editColumn(2, row: row, with: nil, select: true) }
        self.flagsLabel.stringValue = node.command
    }
}

extension NodeSettingsViewController: NSTextFieldDelegate {
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
        guard let textField = obj.object as? NSTextField, let node = node else { return assertionFailure() }
        
        let row = textField.tag
        let value = textField.stringValue
        
        node.options.setUserValue(value: value.isEmpty ? nil : value, at: row)
        self.tableView.reloadData()
        self.flagsLabel.stringValue = node.command
    }
}
