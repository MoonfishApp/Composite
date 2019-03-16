//
//  Node.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/15/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

final class Node {
    
    let interface: RPCServerInterface
    
//    let settings: RPCServerSettings
    
    init(interface: RPCServerInterface) {
        
        self.interface = interface
    }
    
    func bindToServer() {
        
        // 1. check if server is already running. If so, connect.
        
        // 2. Run server
    }
}
