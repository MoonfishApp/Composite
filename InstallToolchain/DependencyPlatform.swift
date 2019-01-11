//
//  DependencyPlatform.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/5/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

struct DependencyPlatform: Codable {
    
    let platform: Platform
    
    // URL path to more info, usually project site. E.g. https://ethereum.org
    let projectUrl: String
    
    // URL path to documenation, e.g. http://www.ethdocs.org/en/latest/
    let documentationUrl: String
    
    var name: String {
        return platform.description
    }
    
    let frameworks: [DependencyFramework]
    
    
    /// Loads all depencies for all platforms from Dependencies.plist
    ///
    /// - Returns:  Array of DependencyPlatforms
    /// - Throws:   Codable error
    static func loadPlatforms() throws -> [DependencyPlatform] {
        
        let dependenciesFile = Bundle.main.url(forResource: "Dependencies.plist", withExtension: nil)!
        let data = try Data(contentsOf: dependenciesFile)
        let decoder = PropertyListDecoder()
        return try decoder.decode([DependencyPlatform].self, from: data)
    }
    
    
    /// Loads all dependenies for a single platform
    ///
    /// - Parameter platform: the platform, e.g. .ethereum
    /// - Returns:  The DependencyPlatform or nil
    /// - Throws:   Codable error
    static func load(_ platform: Platform? = nil) throws -> DependencyPlatform? {
        
        let platforms = try loadPlatforms()
        return platforms.filter{ (item) -> Bool in return item.platform == platform }.first
    }
    
    static func loadIncluded() throws -> [DependencyPlatform] {
        
        let platforms = try loadPlatforms()
        return platforms.filter{ (item) -> Bool in return item.frameworks.count > 0 }
    }
}

