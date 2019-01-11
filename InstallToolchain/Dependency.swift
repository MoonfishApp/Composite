//
//  Dependency.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/5/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation
import Cocoa


/// Dependency is an application Composite depends on, e.g. truffle
class Dependency: Codable {
    
    /// Filename
    let name: String
    
    /// Default location of the dependency
    let defaultLocation: String
    
    /// Version of this dependency is forwarded to the framework
    let isFrameworkVersion: Bool
    
    /// Command to display version
    let versionCommand: String?
        
    /// Command to install depedency
    let installCommand: String?
    
    /// If there's no command line install, use http link
    let installLink: String?
    
    /// Command to upgrade dependency to latest version
    let updateCommand: String?
    
    /// Command to check if dependency is up to date
    let outdatedCommand: String?
    
    /// Just for reminding what
    let comment: String?
    
    /// Some tools are not required. E.g. Brew is not always needed, as some tools
    /// can be installed without Brew. If all tools are installed, but not Brew, Composite
    /// will ignore any tool that has required set to false
    let required: Bool
}


