//
//  Project.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/16/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

private struct SerializationKey {
    
    static let projectName = "projectName"
    static let platformName = "platformName"
    static let frameworkName = "frameworkName"
    static let frameworkVersion = "frameworkVersion"
    static let lastOpenFile = "lastOpenfile"
}


class Project: NSObject, NSCoding, Codable {

    /// Name of the project, e.g. ProjectName
    let name: String

    /// Interface
    let platformName: String
    
    // E.g. etherlime
    let frameworkName: String
    
    // E.g. 0.9.5
    let frameworkVersion: String?
    
    /// Default file to open (usually the contract)
    var defaultOpenFile: String?
    
    static func open(_ url: URL) throws -> Project {
    
        let data = try Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        return try decoder.decode(Project.self, from: data)
    }
    
    init(name: String, platformName: String, frameworkName: String, frameworkVersion: String? = nil, defaultOpenFile: String?) {
        
        self.name = name
        self.platformName = platformName
        self.frameworkName = frameworkName
        self.frameworkVersion = frameworkVersion // If nil, find latest version
        self.defaultOpenFile = defaultOpenFile?.replaceOccurrencesOfProjectName(with: name)
        
        // $(PROJECT_NAME)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.name = aDecoder.decodeObject(forKey: SerializationKey.projectName) as? String ?? ""
        self.platformName = aDecoder.decodeObject(forKey: SerializationKey.platformName) as? String ?? ""
        self.frameworkName = aDecoder.decodeObject(forKey: SerializationKey.projectName) as? String ?? ""
        self.frameworkVersion = aDecoder.decodeObject(forKey: SerializationKey.frameworkVersion) as? String
        self.defaultOpenFile = aDecoder.decodeObject(forKey: SerializationKey.lastOpenFile) as? String
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.name, forKey: SerializationKey.projectName)
        aCoder.encode(self.platformName, forKey: SerializationKey.platformName)
        aCoder.encode(self.frameworkName, forKey: SerializationKey.frameworkName)
        aCoder.encode(self.frameworkVersion, forKey: SerializationKey.frameworkVersion)
        aCoder.encode(self.defaultOpenFile, forKey: SerializationKey.lastOpenFile)
    }
    
}


