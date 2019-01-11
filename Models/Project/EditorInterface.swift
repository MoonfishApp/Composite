//
//  FrameworkInterface.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 10/15/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

struct EditorInterface: Codable {
    
    
    struct StructuredOutput: Codable {
        let path: String
        let version: String
    }
    
    
    struct RegexOutput: Codable {
        let warning: String
        let error: String
    }
    
    
    /// E.g. Ethereum
    let platform: Platform
    
    
    /// E.g. Etherlime
    let framework: String?
    
    
    /// Minimum version, e.g. 0.8.0
    let minVersion: String?
    
    
    /// Maximum version, e.g. 0.9.0
    let maxVersion: String?
    
    
    /// Run command
    let run: String?
    
    
    /// Compile command
    let compile: String?
    
    
    /// Lint command
    let lint: String?
    
    
    /// Structured output file location and version
    let structuredOutput: StructuredOutput?
    
    
    /// Regex output
    let regexOutput: RegexOutput?
}

extension EditorInterface {
    
    func executeRun(workDirectory: URL, output: @escaping (String)->Void, finished: @escaping (Int) -> Void) throws -> BashOperation {
        return try BashOperation(directory: workDirectory.path, commands: ["ls"])
        
//        let task = try ScriptTask(script: "TruffleRun", arguments: [workDirectory.path], output: output, finished: finished)
//        task.run()
//        return task
    }
    
    func executeLint(workDirectory: URL, output: @escaping (String)->Void, finished: @escaping (Int) -> Void) throws -> BashOperation {
        return try BashOperation(directory: workDirectory.path, commands: ["ls"])
//        let task = try ScriptTask(script: "SoliumTruffle", arguments: [workDirectory.path], output: output, finished: finished)
//        task.run()
//        return task
    }
    
    func executeCompile(workDirectory: URL, output: @escaping (String)->Void, finished: @escaping (Int) -> Void) throws -> BashOperation {
        return try BashOperation(directory: workDirectory.path, commands: ["ls"])
//        let task = try ScriptTask(script: "TruffleRun", arguments: [workDirectory.path], output: output, finished: finished)
//        task.run()
//        return task
    }
    
    func executeWebserver(workDirectory: URL, output: @escaping (String)->Void, finished: @escaping (Int) -> Void) throws -> BashOperation {
        return try BashOperation(directory: workDirectory.path, commands: ["ls"])
//        let task = try ScriptTask(script: "TruffleWebserver", arguments: [workDirectory.path], output: output, finished: finished)
//        task.run()
//        return task
    }
}

extension EditorInterface {
    
    static func loadInterface(platform: Platform, framework: String?, version: String?) throws -> [EditorInterface] {
        let interfaceFile = Bundle.main.url(forResource: "EditorInterface", withExtension: "plist")!
        let data = try Data(contentsOf: interfaceFile)
        let decoder = PropertyListDecoder()
        var interfaces = try decoder.decode([EditorInterface].self, from: data)
        
        interfaces = interfaces.filter({ $0.platform == platform })
        if let framework = framework {
            interfaces = interfaces.filter({ $0.framework?.lowercased() == framework.lowercased() })
        }
    
        // TODO: Version
        return interfaces
    }
    
}
