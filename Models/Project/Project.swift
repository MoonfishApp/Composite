//
//  Project.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/16/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

struct Project: Codable {
    
    /// Name of the project, e.g. ProjectName
    let name: String

    /// Interface
    let platformName: String
    
    // E.g. etherlime
    let frameworkName: String
    
    // E.g. 0.9.5
    let frameworkVersion: String?
    
    // TODO: add
    var lastOpenFile: String?
    
    
    init(name: String, platformName: String, frameworkName: String, frameworkVersion: String? = nil, lastOpenFile: String?) {
        self.name = name
        self.platformName = platformName
        self.frameworkName = frameworkName
        self.frameworkVersion = frameworkVersion // If nil, find latest version
        self.lastOpenFile = lastOpenFile?.replaceOccurrencesOfProjectName(with: name)
    }
}


