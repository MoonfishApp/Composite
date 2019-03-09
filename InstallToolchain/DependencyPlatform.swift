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
        return platforms.filter{ $0.platform == platform }.first
    }
    
    static func loadIncluded() throws -> [DependencyPlatform] {
        
        let platforms = try loadPlatforms()
        return platforms.filter{ $0.frameworks.count > 0 }
    }
    
    static func load(forExtension fileExtension: String) throws -> [DependencyPlatform]? {
        
        var supportedPlatforms = [DependencyPlatform]()
        for platform in try loadIncluded() {
        
            // Assumption for now: if at least one framework supports the file extension,
            // (equal to contract programming language), all frameworks of the platform
            // will support the file extension. We'll need to revisit this if
            // frameworks of a platform support different languages.
            let frameworks = platform.frameworks.compactMap{ $0.fileExtensions?.contains(fileExtension) }
            if !frameworks.isEmpty {
                supportedPlatforms.append(platform)
            }
        }
        return supportedPlatforms.isEmpty ? nil : supportedPlatforms
    }
}

