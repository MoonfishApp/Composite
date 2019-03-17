//
//  NodeSettingsViewController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/17/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class NodeSettingsViewController: NodeGenericTabViewController {

//    weak var node: Node? {
//        didSet {
        
//            statusViewController.node = node
//            logViewController?.node = node
//            do {
//                try node?.startNode()
//            } catch {
//                print(error)
//            }
//        }
//    }
    
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
}
