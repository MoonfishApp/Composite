//
//  Node.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/15/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

enum NodeType: String {
    
    case kaya, ganache
}

final class Node {
    
    let type: NodeType
    
    var isInstalled: Bool = true
    
    let interface: RPCServerInterface
    var options: RPCServerOptions
    let operationQueue = OperationQueue()
    
    /// Do not call directly.
    /// Use NodeController.createNode() instead
    init(type: NodeType) {
        
        self.type = type
        self.interface = RPCServerInterface.load(type)
        self.options = RPCServerOptions.load(type)
        
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInteractive
    }
    
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
//    func isServerRunning() -> Bool {
//        let port = options["Port"]?.defaultString
//    }
//    
    func bindToServer() {
        
        // 1. check if server is already running. If so, connect.
        
        // 2. Run server
    }
    
    func relaunch() {
        
    }
}

