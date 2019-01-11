//
//  DependencyState.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/21/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

enum DependencyState {
    case unknown, uptodate, outdated, notInstalled, installing, comingSoon
    
    var buttonlabel: String? {
        switch self {
        case .comingSoon:
            return "Coming soon"
        case .notInstalled:
            return "Install"
        case .outdated:
            return "Update"
        case .installing:
            return "Installing..."
        default:
            return nil
        }
    }
    
    var buttonIsEnabled: Bool {
        
        switch self {
        case .installing, .comingSoon:
            return false
        default:
            return true
        }
    }
    
    var buttonIsHidden: Bool {
        
        return self == .comingSoon
    }
    
    
    /// Returns name of the dependency, with added emoji
    ///
    /// - Parameter name: <#name description#>
    /// - Returns: <#return value description#>
    func display(name: String) -> String {
        
        let emoji: String
        
        switch self {
        case .unknown: emoji = "❓"
        case .uptodate: emoji = "✅"
        case .outdated: emoji = "⚠️"
        case .notInstalled:
            emoji = "❌"
        case .installing, .comingSoon: emoji = "🕗"
        }
        
        return emoji + " " + name
    }
}
