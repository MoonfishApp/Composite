//
//  Platform.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/5/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

enum Platform: String, Codable, CustomStringConvertible {
    
    case ethereum, tron, ethereumclassic, tezos, bitcoin, cosmos, stellar, nebulas, qtum, dispatch, ultrain
    
    var languages: [String] {
        switch self {
        case .ethereum, .ethereumclassic, .tron:
            return ["Solidity"]
        case .tezos:
            return ["Liquidity"]
        case .bitcoin:
            return ["Bitcoin Script"]
        case .cosmos:
            return ["Michelson"]
        case .stellar:
            return ["JavaScript", "Java", "Go"]
        case .nebulas:
            return ["JavaScript"]
        case .qtum:
            return ["Solidity"]
        case .dispatch:
            return ["Solidity"]
        case .ultrain:
            return ["TypeScript"]
        }
    }
    
    /// Returns the description nicely formatted with capitalized first character
    var description: String {
        switch self {
        case .ethereumclassic:
            return "Ethereum Classic"
        default:
            // Capitalize first letter
            return self.rawValue.capitalizedFirstChar()
        }
    }
    
//    var frameworks: [FrameworkInterfaceProtocol.Type] {        
//        switch self {
//        case .ethereum:
//            return [EtherlimeInterface.self, TruffleInterface.self]
//        default:
//            return []
//        }
//    }
//    
//    func interface(for framework: String) -> FrameworkInterfaceProtocol? {
//        switch framework {
//        case "etherlime":
//            return EtherlimeInterface(self)
//        case "truffle":
//            return TruffleInterface(self)
//        default:
//            return nil
//        }
//    }
    
}
