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
    
    var lastOpenFile: String? // Should be defaultOpenFile
    
    /// E.g. ~/Projects/ProjectName
//    let workDirectory: URL
    
    /// Parent directory of the project, e.g. ~/Projects (not ~/Projects/ProjectName)
//    var baseDirectory: URL {
//        return workDirectory.deletingLastPathComponent()
//    }
    
    init(name: String, platformName: String, frameworkName: String, frameworkVersion: String? = nil, lastOpenFile: String?) {
        
        self.name = name
        self.platformName = platformName
        self.frameworkName = frameworkName
        self.frameworkVersion = frameworkVersion // If nil, find latest version
        self.lastOpenFile = lastOpenFile?.replaceOccurrencesOfProjectName(with: name)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.name = aDecoder.decodeObject(forKey: SerializationKey.projectName) as? String ?? ""
        self.platformName = aDecoder.decodeObject(forKey: SerializationKey.platformName) as? String ?? ""
        self.frameworkName = aDecoder.decodeObject(forKey: SerializationKey.projectName) as? String ?? ""
        self.frameworkVersion = aDecoder.decodeObject(forKey: SerializationKey.frameworkVersion) as? String
        self.lastOpenFile = aDecoder.decodeObject(forKey: SerializationKey.lastOpenFile) as? String
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.name, forKey: SerializationKey.projectName)
        aCoder.encode(self.platformName, forKey: SerializationKey.platformName)
        aCoder.encode(self.frameworkName, forKey: SerializationKey.frameworkName)
        aCoder.encode(self.frameworkVersion, forKey: SerializationKey.frameworkVersion)
        aCoder.encode(self.lastOpenFile, forKey: SerializationKey.lastOpenFile)
    }
    
}


