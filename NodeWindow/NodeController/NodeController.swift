//
//  NodeController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/15/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

final class NodeController: NSObject {
    
    static let shared = NodeController()
    
    private (set) var nodes = [Node]()
    
    private override init() {
        
        let zilliqa = Node(type: .kaya)
        nodes.append(zilliqa)
        zilliqa.showWindow(nil)
    }
    
    func stopNodes(nodes: [Node]? = nil) {
        
        if nodes == nil {
            for node in self.nodes {
                node.stopNode()
            }
            self.nodes = [Node]()
        } else {
            assertionFailure()
        }
        
    }
    
    
}
