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
    
    var command: String {
        
        switch self {
        case .kaya:
            return "kaya-cli"
        case .ganache:
            return "ganache-cli"
        }
    }
}

enum NodeState {
    case notInstalled, stopped, internalNode, externalBound, error(Int)
}

final class Node: NSObject {
    
    let nodeType: NodeType
    
    /// Change takes effect next time server is restarted
    var address: String
    
    /// Change takes effect next time server is restarted
    var port: String
    
    var command: String { return self.nodeType.command + " " + self.options.arguments }
    
    // Log viewcontroller uses KVO to update its content
    @objc dynamic var output: String = ""
    
    private (set) weak var windowController: NSWindowController?
    
    private var stateObserver: NSKeyValueObservation?
    
    private (set) var state: NodeState = .stopped {
        didSet {
            stateChange = UUID().uuidString
        }
    }
    
    /// Workaround to make state enum KVO compliant
    /// Set stateChange to random new value to trigger KVO
    @objc dynamic private (set) var stateChange: String?
    
//    let interface: RPCServerInterface
    var options: RPCServerOptions
    
    let nodeQueue = OperationQueue()
    let pingQueue = OperationQueue()
    
    /// Do not call directly.
    /// Use NodeController.createNode() instead
    init(type: NodeType, address: String = "127.0.0.1", port: String? = nil) {
        
        self.nodeType = type
//        self.interface = RPCServerInterface.load(type)
        self.options = RPCServerOptions.load(type)
        self.address = address
        if let port = port {
            self.port = port
        } else {
            self.port = self.options["Port"]?.defaultString ?? "80"
        }
        
        super.init()
        
        nodeQueue.maxConcurrentOperationCount = 1
        nodeQueue.qualityOfService = .userInteractive
        pingQueue.maxConcurrentOperationCount = 1
        pingQueue.qualityOfService = .userInitiated
        
        self.stateObserver = self.nodeQueue.observe(\OperationQueue.operationCount, options: .new) { queue, change in
            if queue.operationCount > 0 {
                self.state = .internalNode
            } else {
                self.state = .stopped
            }
        }
    }
    
    deinit {
        print("DEINIT")
        nodeQueue.cancelAllOperations()
    }
    
    @IBAction func showWindow(_ sender: Any?) {
        let nodeWindowController = NSWindowController.instantiate(storyboard: "Node") as! NodeWindowController
        nodeWindowController.showWindow(sender)
        nodeWindowController.node = self
        self.windowController = nodeWindowController
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
    
    private func nodeOperation() throws -> BashOperation {
//        let operation = try BashOperation(commands: ["ganache-cli"])
        
        // Note: Kaya cannot run in ~ because it needs to create a directory: ../data
        
        let operation = try BashOperation(directory: "/Users/ronalddanger/tt", commands: [self.command])
        operation.completionBlock = {
            
            self.output += "\nNode stopped"
            if let exitStatus = operation.exitStatus {
             
                self.output += "\nExit status \(exitStatus)\n\n"
                if exitStatus != 0 {
                    self.state = .error(exitStatus)
                }
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

