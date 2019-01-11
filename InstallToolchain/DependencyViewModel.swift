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
    
    private weak var installOperation: BashOperation? = nil
    
    private weak var updateOperation: BashOperation? = nil
    
    let name: String
    
    var displayName: String { return state.display(name: name)}
    
    let path: String
    
    let installLink: String?
    
    let versionCommand: String?
    
    let installCommand: String?
    
    let updateCommand: String?
    
    let outdatedCommand: String?
    
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
    
    private (set) var isFrameworkVersion: Bool
    
    let required: Bool
    
    var state: DependencyState {
        
        // Installing
        if isInstalling() {
            return .installing
        }
        
        // Not installed
        if isInstalled == false {
            return .notInstalled
        }
        
        // upToDate / isOutdated
        if newerVersionAvailable != nil {
            return .outdated
        }
        
        return .uptodate
    }
    
    init(_ dependency: Dependency) {
    
        name = dependency.name.capitalizedFirstChar().replacingOccurrences(of: ".app", with: "")
        
        /// The full path of the app (directory and app)
        path = URL(fileURLWithPath: dependency.defaultLocation).appendingPathComponent(dependency.name).path
        required = dependency.required
        isFrameworkVersion = dependency.isFrameworkVersion
        installLink = dependency.installLink
        
        versionCommand = dependency.versionCommand
        installCommand = dependency.installCommand
        updateCommand = dependency.updateCommand
        outdatedCommand = dependency.outdatedCommand
    }
}


// File validation
extension DependencyViewModel {
    
    /// True if file exists at defaultLocation
    /// TODO: use which command?
    var isInstalled: Bool {
        return FileManager.default.fileExists(atPath: path)
    }
}

// Operations
extension DependencyViewModel {
    
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
            if let version = self.versionQueryParser(operation.output) {
                self.version = version
            }
        }

        return operation
    }
    
    func outdatedOperation() -> BashOperation? {
        
        guard
            let command = outdatedCommand,
            command.isEmpty == false,
            let operation = try? BashOperation(directory: "~", commands: [command])
            else { return nil }
        
        operation.completionBlock = {
            self.newerVersionAvailable = self.versionQueryParser(operation.output)
        }
        
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
        guard isInstalled == false else { return nil }
        
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
        
        installOperation = operation
        return [operation, versionQueryOperation()].compactMap{ $0 }
    }
    
    func update() -> [BashOperation]? {
        
        guard
            let command = updateCommand,
            command.isEmpty == false,
            isInstalled == true,
            let operation = try? BashOperation(directory: "~", commands: [command])
            else { return nil }
        
        operation.completionBlock = {
            self.newerVersionAvailable = nil
            if let version = self.versionQueryParser(operation.output) {
                self.version = version
            }
        }
        updateOperation = operation
        return [operation, versionQueryOperation()].compactMap{ $0 }
    }
    
    
    /// Run this after the operation has finished. Pass the operation's output property
    ///
    /// - Parameter output: <#output description#>
    /// - Returns: <#return value description#>
    private func versionQueryParser(_ output: String) -> String? {
        
        // Filter 1.0.1-rc1 type version number
        // Some apps return multiple lines, and this closure will be called multiple times.
        // Therefore, if no match if found, the output closure will not be called, since the
        // version number could be in the previous or next line.
        guard let regex = try? NSRegularExpression(pattern: "(\\d+)\\.(\\d+)\\.(\\d+)\\-?(\\w+)?", options: .caseInsensitive) else {
            return nil
        }
        let versions = regex.matches(in: output, options: [], range: NSRange(location: 0, length: output.count)).map {
            String(output[Range($0.range, in: output)!])
        }
        
        // Some dependencies return multiple lines for their version information
        // Return the first one
        return versions.first
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
        if let i = installOperation, i.isExecuting == true { return true }
        if let u = updateOperation, u.isExecuting == true { return true }
        return false
    }
}

extension DependencyViewModel: CustomStringConvertible {
    
    var description: String {
        return name
    }
}
