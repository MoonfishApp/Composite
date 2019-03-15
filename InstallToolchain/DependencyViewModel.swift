//
//  DependencyViewModel.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/21/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation
import Cocoa

class DependencyViewModel {
    
    static let notificationString = "DependencyViewModelNotification"
    
    private var installOperations = NSPointerArray.weakObjects()
    private var updateOperations = NSPointerArray.weakObjects()
    
    let name: String
    
    /// Includes install-state emoji
    var displayName: String { return state.display(name: name) }
    
    let filename: String
    
    let installLink: String?
    
    let versionCommand: String?
    
    let versionRegex: String
    
    let installCommand: String?
    
    let initCommand: String?
    
    let updateCommand: String?
    
    let outdatedCommand: String?
    
    // Find location of dependency
    let whichCommand: String
    
    var output: (String)->Void = {_ in }
    
    private (set) var version: String = "" {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: DependencyViewModel.notificationString), object: self)
        }
    }
    
    private (set) var newerVersionAvailable: String? = nil {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: DependencyViewModel.notificationString), object: self)
        }
    }

    private (set) var path: String? = nil {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: DependencyViewModel.notificationString), object: self)
        }
    }
    
    private (set) var isFrameworkVersion: Bool
    
    let required: Bool
    
    var state: DependencyState {
        
        // Installing
        if isInstalling() {
            return .installing
        }
        
        // Not installed
        // Note that some tools (like opam) only set a version humber
        if path == nil && version.isEmpty {
            return .notInstalled
        }
        
        // From here on, we're certain the dependency is installed
        
        // upToDate / isOutdated
        if newerVersionAvailable != nil  {
            return .outdated
        }
        
        // Unable to ascertain whether version is up to date
        if newerVersionAvailable == nil && (outdatedCommand ?? "").isEmpty {
            return .unknown
        }
        
        return .uptodate
    }
    
    init(_ dependency: Dependency) {
    
        name = dependency.name.capitalizedFirstChar().replacingOccurrences(of: ".app", with: "")
        filename = (dependency.filename ?? "").isEmpty ? dependency.name : dependency.filename!
    
        required = dependency.required
        isFrameworkVersion = dependency.isFrameworkVersion
        installLink = dependency.installLink
        
        versionCommand = dependency.versionCommand
        versionRegex = (dependency.versionRegex ?? "").isEmpty ? "(\\d+)\\.(\\d+)\\.(\\d+)\\-?(\\w+)?" : dependency.versionRegex!
        installCommand = dependency.installCommand
        initCommand = dependency.initCommand
        updateCommand = dependency.updateCommand
        outdatedCommand = dependency.outdatedCommand
        whichCommand = "which " + filename
    }
}

// Operations
extension DependencyViewModel {
    
    
    func fileLocationOperation() -> BashOperation? {
        
        guard whichCommand.isEmpty == false, let operation = try? BashOperation(commands: [whichCommand], verbose: false)
            else { return nil }
        
        operation.completionBlock = {
            guard operation.output.isEmpty == false else {
                return
            }
            
            // Remove the double forward slash the 'which' command returns
            let url = URL(fileURLWithPath: operation.output.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)).standardizedFileURL
            self.path = url.path
        }
        
        operation.outputClosure = output
        
        return operation
    }
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    func versionQueryOperation() -> BashOperation? {
        
        guard
            let command = versionCommand,
            command.isEmpty == false,
            let operation = try? BashOperation(directory: "~", commands: [command])
            else { return nil }
        
        operation.completionBlock = {
            if let versions = self.versionQueryParser(operation.output), let version = versions.first {
                self.version = version.trimmingCharacters(in: .whitespaces)
            }
        }
        
        operation.outputClosure = output

        return operation
    }
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    func initOperation() -> BashOperation? {
        
        guard
            let command = initCommand,
            command.isEmpty == false,
            let operation = try? BashOperation(directory: "~", commands: [command])
            else { return nil }
        
        operation.outputClosure = output
        
        return operation
    }
    
    func outdatedOperation() -> BashOperation? {
        
        guard
            let command = outdatedCommand,
            command.isEmpty == false,
            let operation = try? BashOperation(directory: "~", commands: [command])
            else { return nil }
        
        operation.completionBlock = {
            self.newerVersionAvailable = self.versionQueryParser(operation.output)?.last
        }
        
        operation.outputClosure = output
        
        return operation
    }
    
    func install() -> [BashOperation]? {
        
        // Hardcoded edgecase for brew.
        // The brew installer needs to run as admin.
        if name == "brew" {
            installBrew()
            return nil
        }
        
        // If dependency is already installed, return nil
        guard state == .notInstalled else { return nil }
        
        // If dependency needs to be downloaded from a web page and installed manually, open url
        if let link = installLink, let url = URL(string: link) {
            NSWorkspace.shared.open(url)
            return nil
        }
        
        // If there's no installCommand, do nothing
        guard
            let command = installCommand,
            command.isEmpty == false,
            let operation = try? BashOperation(directory: "~", commands: [command])
            else { return nil }
        
        operation.outputClosure = output
        let operations = [operation, initOperation(), fileLocationOperation(), versionQueryOperation()].compactMap{ $0 }
        self.installOperations.addObjects(operations)
        return operations
    }
    
    func update() -> [BashOperation]? {
        print(updateCommand!)
        guard
            let command = updateCommand,
            command.isEmpty == false,
            state != .notInstalled,
            let operation = try? BashOperation(directory: "~", commands: [command])
            else { return nil }
        
        operation.completionBlock = {
            self.newerVersionAvailable = nil
        }
        operation.outputClosure = output
        let operations = [operation, versionQueryOperation()].compactMap{ $0 }
        self.updateOperations.addObjects(operations)
        return operations
    }
    
    
    /// Run this after the operation has finished. Pass the operation's output property
    ///
    /// - Parameter output: <#output description#>
    /// - Returns: <#return value description#>
    private func versionQueryParser(_ output: String) -> [String]? {
        
        // Filter 1.0.1-rc1 type version number
        // Some apps return multiple lines, and this closure will be called multiple times.
        // Therefore, if no match if found, the output closure will not be called, since the
        // version number could be in the previous or next line.
        guard let regex = try? NSRegularExpression(pattern: versionRegex, options: .caseInsensitive) else {
            return nil
        }
        let versions = regex.matches(in: output, options: [], range: NSRange(location: 0, length: output.count)).map {
            String(output[Range($0.range, in: output)!])
        }
        
        // Some dependencies return multiple lines for their version information
        // Return the first one
        return versions
    }
    
    
    /// TODO: Look into running task as root to install tools like Berw
    ///
    // See:
    /// https://developer.apple.com/library/archive/documentation/Security/Conceptual/SecureCodingGuide/Articles/AccessControl.html
    /// https://www.reddit.com/r/macprogramming/comments/3wuvmz/how_to_createrun_an_nstask_in_swift_with_sudo/
    /// https://www.cocoawithlove.com/2009/05/invoking-other-processes-in-cocoa.html
    /// AppleScript: http://nonsenseinbasic.blogspot.com/2013/03/mac-os-x-programming-running-nstask.html
    /// https://github.com/coteditor/cot/blob/develop/cot
    private func installBrew()  {
        
        let message = "Please install brew manually by copying the following text in MacOS terminal"
        let command = "/usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\""
        
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = command
        alert.runModal()
    }
    
    func isInstalling() -> Bool {
        
        let installing = installOperations.allObjects.compactMap { ($0 as! Operation).isExecuting == true ? $0 : nil }
        let updating = updateOperations.allObjects.compactMap { ($0 as! Operation).isExecuting == true ? $0 : nil }
        return installing.count > 0 || updating.count > 0
    }
}

extension DependencyViewModel: CustomStringConvertible {
    
    var description: String {
        return name
    }
}
