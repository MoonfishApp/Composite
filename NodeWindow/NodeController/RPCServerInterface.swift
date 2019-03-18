//
//  RPCServerInterface.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/15/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

struct RPCServerInterface: Decodable {
    
    let launchCommand: String
    
    static func load(_ type: NodeType) -> RPCServerInterface {
        let url = Bundle.main.url(forResource: type.rawValue.capitalizedFirstChar() + "Interface", withExtension: "plist")!
        let data = try! Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        return try! decoder.decode(RPCServerInterface.self, from: data)
    }
    
    
    
}
