//
//  NodeWindowController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/17/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class NodeWindowController: NSWindowController {
    
    weak var node: Node? {
        didSet {
            
            guard node != nil else {
                self.close()
                return
            }
            
            statusViewController.node = node
            logViewController?.node = node
            tabViewController?.node = node
            do {
                try node?.startNode()
            } catch {
                print(error)
            }
            
            self.window!.title = node?.nodeType.rawValue.capitalizedFirstChar() ?? ""
        }
    }
    
    var statusViewController: NodeStatusViewController {
        return (contentViewController as! NSSplitViewController).splitViewItems[1].viewController as! NodeStatusViewController
    }
    
    var logViewController: NodeLogViewController? {
        return (contentViewController as! NSSplitViewController).splitViewItems.last?.viewController as? NodeLogViewController
    }
    
    var tabViewController: NodeTabViewController? {
        return (contentViewController as! NSSplitViewController).splitViewItems.first?.viewController as? NodeTabViewController
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
