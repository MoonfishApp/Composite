//
//  ProjectInit.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 1/4/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

/**
 
 */
class ProjectInit {

    let frameworkInterface: FrameworkInterface
    
    /// Shortcut to the framework init struct
    let frameworkInit: FrameworkInit
    
    let framework: DependencyFrameworkViewModel
    
    let platform: DependencyPlatformViewModel
    
    let operationQueue = OperationQueue()
    
    var progress: Double = 0
    
    private var progressObserver: NSKeyValueObservation!
    
    /// Maximum number of operations
    private var maxOperationCount: Int = 0
    
    /// Name of the project (and project directory)
    let projectName: String

    /// The directory in which the project directory will be created.
    /// E.g. ~/Development/ The directory that will be created by ProjectInit
    /// will be ~/Development/<ProjectName>
    let baseDirectory: String
    
    var projectDirectory: URL {
        return URL(fileURLWithPath: baseDirectory).appendingPathComponent(projectName)
    }
    
    let template: Template?
    
    let projectFileURL: URL
    
    /// Call when project initialization finished successfully or unsuccessfully.
    /// Success: exit status = 0, error = nil.
    var finished: (Int, Error?) -> Void = {_,_ in }
    
    /// Stdout
    var output: (String)->Void = {_ in }
    
    // TODO: add env arguments
    init(projectName: String, baseDirectory: String, template: Template? = nil, framework: DependencyFrameworkViewModel, platform: DependencyPlatformViewModel) throws {

        // Set properties
        self.projectName = projectName
        self.baseDirectory = baseDirectory
        self.template = template
        self.framework = framework
        self.platform = platform
        
        projectFileURL = URL(fileURLWithPath: baseDirectory).appendingPathComponent(projectName).appendingPathComponent("\(projectName).composite")
        
        // Fetch framework init from FrameworkInterface.plist
        frameworkInterface = try FrameworkInterface.loadCommands(for: framework.framework.name)
        if let template = template, let commands = template.initType.commands(frameworkInterface) {
            frameworkInit = commands
        } else {
            frameworkInit = frameworkInterface.initInterface.initEmpty
        }
        
        // Set up queue
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInitiated
    }
    
    // Just checking we don't have a retain cycle
    // If all is well, app will crash
    deinit {
        print("Deinit ProjectInit")
        assertionFailure()
    }
    
    func initializeProject(output: @escaping (String)->Void, finished: @escaping (Int, Error?) -> Void) throws {

        // 1. Set closure properties
        self.finished = finished
        self.output = output
        
        //
        progressObserver = operationQueue.observe(\OperationQueue.operationCount, options: .new) { queue, change in
            
            if queue.operationCount > self.maxOperationCount {
                self.maxOperationCount = queue.operationCount
            }
            
            self.progress = 10 + (1.0 - (Double(queue.operationCount) / Double(self.maxOperationCount))) * 90.0
        }

        // 2. Fetch framework version
        if let version = versionOperation() {
            operationQueue.addOperation(version)
            operationQueue.addOperation(printVersion())
        }
        
        // 2. Create project directory (if needed)
        //    Some frameworks create the project directory themselves.
        //    If so, createProjectDirectory is false
        let bashDirectory: String
        if frameworkInit.createProjectDirectory == true {
            bashDirectory = URL(fileURLWithPath: baseDirectory).appendingPathComponent(projectName).path
            try FileManager.default.createDirectory(atPath: bashDirectory, withIntermediateDirectories: true)
        } else {
            bashDirectory = baseDirectory
        }
        
        // 3. Initialize new FrameworkInit instance
        //    From bashDirectory set in step 1
        if let initOperation = frameworkInitOperation(directory: bashDirectory) {
            operationQueue.addOperation(initOperation)
        }
        
        // 4. Create directory structure (if the framework doesn't do that already)
        if let createDirectoriesOperation = createDirectoriesOperation() {
            operationQueue.addOperation(createDirectoriesOperation)
        }
        
        // 5. Run framework initializer (e.g. etherlime init, if available)
        
        
        // 6. Copy template files to the project and rename to project name if necessary
        
        // 7. ...? Run script to finish up?
        
        // 8. Create new project file
        
        // 9. Call finished
        //finished(operation.exitStatus ?? 0)
        
    }
    
//    private func saveProjectFile() {
//
//        // Prepare openfile
//        var openFile: String? = nil
//        if let templateOpenFile = template?.openFile {
//            openFile = templateOpenFile.replacingOccurrences(of: "$(PROJECT_NAME)", with: projectName)
//        }
//
//        // TODO: fix framework version
//        let project = Project(name: projectName, platformName: frameworkInterface.platform, frameworkName: frameworkInterface.framework, frameworkVersion: "0", lastOpenFile: openFile)
//
//        // save openFile in projectfile as lastOpenedFile
//        let encoder = PropertyListEncoder()
//        encoder.outputFormat = .xml
//        do {
//            let data = try encoder.encode(project)
//            FileManager.default.createFile(atPath: projectDirectory.appendingPathComponent("\(projectName).composite").path, contents: data, attributes: nil)
//        } catch {
//            print(error)
//            assertionFailure()
//        }
//    }
    
    func cancel() {
        operationQueue.cancelAllOperations() // Check if all operations cancel correctly
    }
}

// Operation creators
extension ProjectInit {
    
    /// Called by Operation creators when they encounter an error
    ///
    ///
    /// - Parameter error: <#error description#>
    private func exitWithError(exitStatus: Int, error: Error?) {
        
        // 1. Cancel all operation in the queue
        cancel()
        
        // Send error message to stdout
        self.output((error ?? CompositeError.initError("Initialization error")).localizedDescription)
        
        // 2. Finish init with call to finished and pass error
        finished(exitStatus, error)
    }
    
    
    /// fetches framework version
    ///
    /// - Returns: operation
    private func versionOperation() -> Operation? {
        
        guard framework.version.isEmpty, let dependency = self.framework.dependencies.filter({ $0.isFrameworkVersion == true }).first else {
            return nil
        }
        
        let operation = dependency.versionQueryOperation()
        return operation
    }
    
    /// Outputs framework name and version number to stdout
    ///
    /// - Returns: operation
    private func printVersion() -> Operation {
        return BlockOperation {
            self.output(self.framework.name + " " + self.framework.version)
        }
    }
    
    /// Operation to creates the directory structure of the project
    /// (e.g. contracts, test, migrations, etc.)
    ///
    /// - Parameter output: stdout output
    /// - Returns: nil when the initDirectories in the framework interface was not set.
    ///            (in that case the framework init command will have created the directory structure
    private func createDirectoriesOperation() -> Operation? {

        guard let directories = frameworkInterface.initInterface.initDirectories, directories.count > 0 else { return nil }
        
        let operation = BlockOperation {
            for directory in directories {
                let url = self.projectDirectory.appendingPathComponent(directory, isDirectory: true)
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                } catch {
                    self.finished(0, CompositeError.initError("Error creating directory \(url.path)"))
                    return
                }
            }
        }
        return operation

    }
    
    
    /// Operation copying files from the Composite bundle to the project file
    ///
    /// - Parameter output: stdout output
    /// - Returns: returns nil if no files need to be copied
    private func copyFilesOperation() -> Operation? {

        guard let copyFiles = self.template?.copyFiles else { return nil }
        
        let operation = BlockOperation {
            
            // Copy files
            for file in copyFiles {
                do {
                    let newFilename = try file.copy(projectName: self.projectName, projectDirectory: self.projectDirectory)
                    self.output("Copied \(newFilename) to \(file.destination).")
                } catch {
                    self.output("ERROR copying \(file.filename) to \(file.destination):")
                    self.finished(0, error)
                    return
                }
            }
        }
        return operation
    }
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - directory: <#directory description#>
    ///   - output: <#output description#>
    /// - Returns: nil if no commands are found
    private func frameworkInitOperation(directory: String) -> Operation? {

        guard frameworkInit.commands.isEmpty == false else { return nil }
        
        let operation: BashOperation
        do {
            operation = try BashOperation(directory: directory, commands: frameworkInit.commands)
            operation.outputClosure = output
            operation.completionBlock = {
                
                if let exitStatus = operation.exitStatus, exitStatus != 0 {
                    self.exitWithError(exitStatus: exitStatus, error: CompositeError.initError("Error initializing project"))
                    return
                }
            }
            return operation
        } catch {
            exitWithError(exitStatus: 0, error: error)
        }
        return nil
    }
    
}
