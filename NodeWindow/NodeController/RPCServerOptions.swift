//
//  RPCServerOptions.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/15/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

final class RPCServerOptions: Codable {
    
    private (set) var options: [RPCServerOptionField] = []
    
    var argumentsArray: [String] {
        return self.options.filter({ $0.enabled == true }).compactMap{
            guard let value = $0.userValue ?? $0.defaultString ?? $0.defaultBool?.description else { return nil }
            return "\($0.flag) \(value)"
        }
    }
    
    var arguments: String {
        
        var string = ""
        _ = argumentsArray.map{ string += $0 + " " }
        return string
    }
    
    init(options: [RPCServerOptionField]) {
        self.options = options
    }
    
    static func load(_ type: NodeType) -> RPCServerOptions {
        let url = Bundle.main.url(forResource: type.rawValue.capitalizedFirstChar() + "Options", withExtension: "plist")!
        let data = try! Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        let options = try! decoder.decode([RPCServerOptionField].self, from: data)
        return RPCServerOptions(options: options)
    }
    
    subscript(name: String) -> RPCServerOptionField? {
        return options.filter{ $0.name.uppercased() == name.uppercased() }.first        
    }
    
    subscript(index: Int) -> RPCServerOptionField {
        get {
            return self.options[index]
        }
    }
    
    func enableOption(enabled: Bool, at index: Int) {
        options[index].enabled = enabled
    }
    
    func setUserValue(value: String?, at index: Int) {
        options[index].userValue = value
    }
}

struct RPCServerOptionField: Codable {
    
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
    
    // User values not stored in plist
    
    /// If true, option is passed as argument to node
    var enabled: Bool = false
    
    /// Value set by user
    var userValue: String?
    
    private enum CodingKeys: String, CodingKey {
        case name, description, flag, defaultString, defaultBool
    }
}
