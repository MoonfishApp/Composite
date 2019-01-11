//
//  BashOperation.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 1/5/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

protocol BashOutputProtocol {
    
    /// Operation received stdOut output from shell
    /// Will always be called from the main thread
    func bashOperation(_ operation: BashOperation, receivedOutput string: String)
    
    /// Operation received error from shell
    /// Will always be called from the main thread
    func bashOperation(_ operation: BashOperation, receivedError string: String)
}

class BashOperation: Operation {
    
    /// Alternative to using
    var delegate: BashOutputProtocol?
    
    /// Closure to forward stdout
    var outputClosure: ((String) -> Void)?
    
    /// Closure to forward stderr
    var errClosure: ((String) -> Void)?
    
    /// If any of the commands in the script returns non-zero,
    /// the script will cancel and forward the exit code
    /// 0 is success, anything else is an error
    /// http://www.tldp.org/LDP/abs/html/exitcodes.html
    private (set) var exitStatus: Int?
    
    /// Complete output
    private (set) var output: String = ""
    
    private let task = Process()
    private let outputPipe = Pipe()
    private let inputPipe = Pipe()
    
    private let launchpath: String
    private var notification: NSObjectProtocol!
    private let arguments: [String]

    /// Convenience initializer for generic Execute.command script
    ///
    /// - Parameters:
    ///   - script: <script>.command in the main bundle to be executed.
    ///   - path: Path of the <script>.command. If nil, main bundle will be assumed
    ///   - directory: directory where script will be run (e.g. project directory)
    ///   - commands: Commands to execute. Quotes will be added
    ///   - output: Output of the script will be send here
    ///   - finished: Called when finished with exit code
    /// - Throws: File not found if Bash script cannot be found
    init(script: String = "Execute", ext: String = "command", path: String? = nil,
         directory: String, commands: [String]) throws {
        
        // 1. Prepare script location
        // Set launchPath to the location of the bash script to be executed
        if let path = path {
            launchpath = URL(fileURLWithPath: path).appendingPathComponent(script).appendingPathExtension(ext).absoluteString
        } else if let path = Bundle.main.path(forResource: script, ofType: ext) {
            launchpath = path
        } else {
            throw CompositeError.fileNotFound("Script \(script).\(ext) not found in directory \(path ?? "(empty)")")
        }
        
        // 2. Set location where the commands need to be executed
        // Expand ~ since NSTask does not do that
        var expandedDirectory = ""
        if directory == "~" {
            expandedDirectory = FileManager.default.homeDirectoryForCurrentUser.path
        } else {
            expandedDirectory = directory.escapedSpaces
        }
        
        // 3. Set Bash arguments
        var arguments = [String]()
        arguments.append("-d")
        arguments.append(expandedDirectory)
        
        for command in commands {
            arguments.append(command)
        }

        self.arguments = arguments
    }
    
    override func main() {
        
        defer {
            NotificationCenter.default.removeObserver(notification)
        }
        
        // main code, execute bash task
        guard isCancelled == false else {
            return
        }
        
        task.standardInput = self.inputPipe
        task.launchPath = self.launchpath
        task.arguments = self.arguments
        task.environment = [
            "PATH": "/usr/local/bin/:/usr/bin:/bin:/usr/sbin:/sbin",
            "HOME": FileManager.default.homeDirectoryForCurrentUser.path
        ]
        
        // Handle termination
        self.task.terminationHandler = { task in
            self.exitStatus = Int(task.terminationStatus)
        }
        
        // Handle output
        self.captureStandardOutput()
        
        task.launch()
        task.waitUntilExit()
    }
    
    /// For now, both stdout and stderr are sent to the same pipe.
    func captureStandardOutput() {
        
        task.standardOutput = outputPipe
        task.standardError = outputPipe
        
        notification = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            
            let output = self.outputPipe.fileHandleForReading.availableData
            guard let outputString = String(data: output, encoding: String.Encoding.utf8), !outputString.isEmpty else { return }
            
            DispatchQueue.main.async(execute: {
                print(outputString)
                self.outputClosure?(outputString)
                self.delegate?.bashOperation(self, receivedOutput: outputString)
                self.output = self.output + "\n" + outputString
                self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify() // Do we need this?
            })
        }
        DispatchQueue.main.async(execute: {
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        })
    }
    
//    override func cancel() {
//        task.terminate()
//        Need to manually implement cancel now?
//    }

}
