//
//  RPCServerOptions.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/15/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

final class RPCServerOptions: Codable {
    
    var options: [RPCServerOption] = []
    
    static func load(_ type: NodeType) -> RPCServerOptions {
        let url = Bundle.main.url(forResource: type.rawValue.capitalizedFirstChar() + "Interface", withExtension: "plist")!
        let data = try! Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        return try! decoder.decode(RPCServerOptions.self, from: data)
    }
    
    subscript(name: String) -> RPCServerOption? {
        return options.filter{ $0.name.uppercased() == name.uppercased() }.first        
    }
}

struct RPCServerOption: Codable {
    
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
    
    /// If true, option is passed as argument to node
    let enabled: Bool
    
    /// Value set by user
    var userValue: String?
}
