//
//  FrameworkInterface.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 1/2/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

/// Stores the available commands for a framework (e.g. Truffle or Tronbox)
/// properties are read from Dependencies.plist file
struct FrameworkInterface: Codable {
        
    /// E.g. ethereum
    let platform: String
    
    /// E.g. truffle
    let framework: String
    
    /// Oldest version of the framework the included commands work with
    let minVersion: String
    
    /// Newest version of the frameworks the included commands work with
    let maxVersion: String
    
    /// Name of the configuration file
    /// (used to open the configuration by clicking on the project name in the IDE)
    let configurationFile: String
    
    let errorRegex: String?
    
    let warningRegex: String?
    
    let initInterface: InitInterface
    
    /// Commands
    let commands: Commands
    
    /// Loads all framework commands from FrameworkCommands.plist in the bundle
    static func loadCommands() throws -> [FrameworkInterface] {
        
        let dependenciesFile = Bundle.main.url(forResource: "FrameworkInterface.plist", withExtension: nil)!
        let data = try Data(contentsOf: dependenciesFile)
        let decoder = PropertyListDecoder()
        return try decoder.decode([FrameworkInterface].self, from: data)
    }
    
    static func loadCommands(for framework: String, version: String? = nil, platform: String? = nil) throws -> FrameworkInterface {
        
        // TODO: match versions
        guard let commands = try loadCommands().filter({ $0.framework.capitalized == framework.capitalized }).first else {
            throw CompositeError.frameworkNotFound(framework)
        }
        return commands
    }
}

struct Commands: Codable {
    
    let compile: String
    
    let deploy: String
    
    let cleanDeploy: String?
    
    let runTests: String
    
    let cleanCompile: String?
    
    let cleanRunTests: String?
    
    let cleanProject: String?
    
    let console: String?
    
    let lint: String?
    
}

struct InitInterface: Codable {

    let initDirectories: [String]?
    
    let initTemplate: FrameworkInit
    
    let initExample: FrameworkInit?
}

struct FrameworkInit: Codable {
    
    /// The Bash commands that will be executed to initialize the project
    let commands: [String]
    
    /// If true, ProjectInit will create the project directory (<directory>/<projectName>) and run the commands in the project directory.
    /// If false, ProjectInit will run the commands in <directory>. This is how Embark works.
    let createProjectDirectory: Bool
    
    let directories: [String]?
}
