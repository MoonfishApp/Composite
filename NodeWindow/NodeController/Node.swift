//
//  Node.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/15/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

enum NodeType: String {
    
    case kaya, ganache
}

final class Node: NSObject {
    
    let type: NodeType
    
    /// Change takes effect next time server is restarted
    var server: String
    
    /// Change takes effect next time server is restarted
    var port: String
    
    @objc dynamic var output: String = ""
    
//    /// True if ganache, Kaya, etc. is installed
//    /// If not installed, localohost co
//    var isInstalled: Bool = true
    
    /// Node is running within Composite. Composite can restart
    var isRunning: Bool {
        return self.nodeQueue.operations.count > 0
    }
    
    /// If isRunning == false, and isBound == true, then Composite is
    /// connected to a node, but is not running the node.
    /// Settings cannot be changed if isBound == false
    private (set) var isBound: Bool = true
    
    
//    let interface: RPCServerInterface
    var options: RPCServerOptions
    
    let nodeQueue = OperationQueue()
    let pingQueue = OperationQueue()
    
    /// Do not call directly.
    /// Use NodeController.createNode() instead
    init(type: NodeType) {
        
        self.type = type
//        self.interface = RPCServerInterface.load(type)
        self.options = RPCServerOptions.load(type)
        self.server = "127.0.0.1"
        self.port = "4200"
        
        super.init()
        
        nodeQueue.maxConcurrentOperationCount = 1
        nodeQueue.qualityOfService = .userInteractive
        pingQueue.maxConcurrentOperationCount = 1
        pingQueue.qualityOfService = .userInitiated
    }
    
    deinit {
        print("DEINIT")
        nodeQueue.cancelAllOperations()
    }
    
    @IBAction func showWindow(_ sender: Any?) {
        let nodeWindowController = NSWindowController.instantiate(storyboard: "Node") as! NodeWindowController
        nodeWindowController.showWindow(sender)
        nodeWindowController.node = self
    }
    
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
//    func isServerRunning() -> Bool {
//        let port = options["Port"]?.defaultString
//    }
//
    
    func startNode() throws {
        try nodeQueue.addOperation(nodeOperation())
    }
    
    func stopNode() {
        nodeQueue.cancelAllOperations()
        nodeQueue.operations.first?.cancel()
    }
    
    func relaunch() throws {
        stopNode()
        try startNode()
    }
    
    func bindToServer() {
        
        // 1. check if server is already running. If so, connect.
        
        // 2. Run server
    }
    
    func nodeOperation() throws -> BashOperation {
//        let operation = try BashOperation(commands: ["ganache-cli"])
        let operation = try BashOperation(directory: "/Users/ronalddanger/tt", commands: ["kaya-cli"])
        operation.completionBlock = {
            
            self.output += "\nNode stopped"
            if let exitStatus = operation.exitStatus {
                self.output += "\nExit status \(exitStatus)"
            }
        }
        operation.outputClosure = { stdout in
            self.output += stdout
        }
        operation.errClosure = { stderr in
            self.output += stderr // TODO: change color?
        }
        return operation
    }
    
    // This is probably not the best solution.
    // NSPort might be a better solution (?) in the future
    func pingServer() {
//        nc -z 127.0.0.1 8541
    }
    
    private func pingOperation() {
//        let command = "nc -z \(self.server) \(self.port)"
//        let operation = try BashOperation(commands: <#T##[String]#>)
    }

}

