//
//  ProjectInit.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 1/4/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

/**
 
 */
class ProjectInit: NSObject {

    let frameworkInterface: FrameworkInterface
    
    /// Shortcut to the framework init struct
    let frameworkInit: FrameworkInit
    
    let framework: DependencyFrameworkViewModel
    
    let platform: DependencyPlatformViewModel
    
    let operationQueue = OperationQueue()
    
    /// Progress from 0 to 100. Min value set to 10 to indicate progress to user
    @objc private (set) dynamic var progress: Double = 10
    
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
    
    /// If a new project has to be created based on an existing contract,
    /// importFile will contain the location of the existing contract
    let importFile: URL?
    
    /// URL of where importFile will be copied to
    /// The project's default file will be set to this url
    var importFileDestination: URL? {
        
        guard let importFile = importFile else { return nil }
        let importFilename = importFile.lastPathComponent
        return URL(fileURLWithPath: baseDirectory).appendingPathComponent(projectName).appendingPathComponent(framework.contractDirectory).appendingPathComponent(importFilename)
    }
    
    /// Call when project initialization finished successfully or unsuccessfully.
    /// Success: exit status = 0, error = nil.
    var finished: (Int, Error?) -> Void = {_,_ in }
    
    /// Stdout
    var output: (String)->Void = {_ in }
    
    // TODO: add env arguments
    init(directory: URL, template: Template? = nil, framework: DependencyFrameworkViewModel, platform: DependencyPlatformViewModel, importFile: URL? = nil) throws {

        // Set properties
        self.projectName = directory.lastPathComponent //.replacingOccurrences(of: " ", with: "-") // e.g. "MyProject"
        self.baseDirectory = directory.deletingLastPathComponent().path // e.g. "/~/Documents/"
        self.template = template
        self.framework = framework
        self.platform = platform
        self.importFile = importFile
        
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
    
    static func canCreateProject(at url: URL) -> Bool {

        return FileManager.default.fileExists(atPath: url.path) == false
    }
    
    func initializeProject(output: @escaping (String)->Void, finished: @escaping (Int, Error?) -> Void) throws {

        // 1. Set closure properties
        self.finished = finished
        self.output = output
        
        // 2. Keep track of completion progress
        progressObserver = operationQueue.observe(\OperationQueue.operationCount, options: .new) { queue, change in
            
            if queue.operationCount > self.maxOperationCount {
                self.maxOperationCount = queue.operationCount
            }
            
            self.progress = 10 + (1.0 - (Double(queue.operationCount) / Double(self.maxOperationCount))) * 90.0
        }

        // 3. Fetch framework version
        if let version = versionOperation() {
            operationQueue.addOperation(version)
            let printOperation = printVersion()
            operationQueue.addOperation(printOperation)
            printOperation.addDependency(version)
        }
        
        // 4. Create project directory (if needed)
        //    Some frameworks create the project directory themselves.
        //    If so, createProjectDirectory is false
        let bashDirectory: String
        if frameworkInit.createProjectDirectory == true {
            bashDirectory = URL(fileURLWithPath: baseDirectory).appendingPathComponent(projectName).path
            try FileManager.default.createDirectory(atPath: bashDirectory, withIntermediateDirectories: true)
        } else {
            bashDirectory = baseDirectory
        }
        
        // 5. Initialize new FrameworkInit instance
        //    E.g. etherlime init
        //    from bashDirectory set in step 1
        if let initOperation = frameworkInitOperation(directory: bashDirectory) {
            operationQueue.addOperation(initOperation)
        }
        
        // 6. Create directory structure (if the framework doesn't do that already)
        if let createDirectoriesOperation = createDirectoriesOperation() {
            operationQueue.addOperation(createDirectoriesOperation)
        }
        
        // 7. Copy template files to the project and rename to project name if necessary
        if let copyFiles = copyFilesOperation() {
            operationQueue.addOperation(copyFiles)
        }
        
        // 8. Copy imported file
        if let copyImportedFile = copyImportedFileOperation() {
            operationQueue.addOperation(copyImportedFile)
        }
        
        // 8. Create new project file
        operationQueue.addOperation(createProjectFile())
        
        // 9. Call finished
        operationQueue.addOperation(finishedSuccessfully())
        
        // 10. Open project file
        // Nope, that's handled by projectInitWindow
//        operationQueue.addOperation(openProject())
    }
    
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
        
        // Find the dependency that sets the framework version
        // Return nil if version is already set
        guard framework.version.isEmpty, let dependency = self.framework.dependencies.filter({ $0.isFrameworkVersion == true }).first else {
            return nil
        }
        
        let operation = dependency.versionQueryOperation()
        return operation
    }
    
    /// Outputs framework name and version number to stdout
    /// TODO: this doesn't work. all dependencies have empty version strings.
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
                    let newFilename = try file.copy(projectName: self.projectName, projectDirectory: self.projectDirectory, subdirectory: self.framework.name)
                    self.output("Copied \(newFilename) to \(file.destination).")
                } catch {
                    self.output("Error copying \(file.filename) to \(file.destination):")
                    self.finished(0, error)
                    return
                }
            }
        }
        return operation
    }
    
    private func copyImportedFileOperation() -> Operation? {
        
        guard let importFile = self.importFile,
            let destination = self.importFileDestination else { return nil }

        return BlockOperation {
            do {
                try FileManager.default.copyItem(at: importFile, to: destination)
            } catch {
                self.output("Error copying \(importFile) to \(destination):")
                self.finished(0, error)
                return
            }
        }
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
    
    private func createProjectFile() -> Operation {
        
        return BlockOperation {
        
//            this has to be relative, since we're storing the path in the project document on disk
//            if importFile then substract project directory
            
//            var openFile: String? = nil
//            if let templateFile = self.template?.openFile {
//                openFile = self.projectDirectory.appendingPathComponent(templateFile).path
//            } else if let importFile = self.importFileDestination {
//                openFile = importFile.path.replacingOccurrences(of: self.projectDirectory.path, with: "")
//            }
            
            let openFile = self.template?.openFile ?? self.importFileDestination?.path.replacingOccurrences(of: self.projectDirectory.path, with: "")
                
            let project = Project(name: self.projectName, platformName: self.platform.name, frameworkName: self.framework.name, frameworkVersion: self.framework.version, defaultOpenFile: openFile)
            let document = ProjectDocument(project: project, url: self.projectFileURL)
            
            document.save(to: self.projectFileURL, ofType: ProjectDocument.fileExtension, for: .saveToOperation, completionHandler: { error in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
            })
        }
    }
    
    private func finishedSuccessfully() -> Operation {
        
        return BlockOperation{
            self.output("Initialization successful")
            self.finished(0, nil)
        }
    }
    
//    private func openProject() -> Operation {
//
//        return BlockOperation{
//            DocumentController.shared.openDocument(withContentsOf: self.projectFileURL, display: true) { (document, wasAlreadyOpen, error) in
//
//                guard error == nil else {
//                    self.output("Error opening \(self.projectFileURL)")
//                    self.finished(0, error)
//                    return
//                }
//            }
//        }
//    }
}
