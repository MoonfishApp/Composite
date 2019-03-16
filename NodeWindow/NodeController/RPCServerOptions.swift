//
//  RPCServerOptions.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/15/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

final class RPCServerOptions: Codable {
    
    private (set) var nodeNeedsRestart = false
    
    
    
    init(platform: String, framework: String) {
        
    }
    
    
}

struct RPCServerOption {
    
    /// Name shown in GUI
    let name: String
    
    /// Description shown in GUI
    let description: String
    
    /// Command line flag E.g. -d
    let flag: String
    
    /// Default value, string
    let defaultString: String?
    
    /// Default value, Bool
    let defaultBool: Bool?
}
