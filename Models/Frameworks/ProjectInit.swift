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
    
    let frameworkInit: FrameworkInit
    
    let operationQueue = OperationQueue()
    
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
    
    // TODO: add env arguments
    init(projectName: String, baseDirectory: String, template: Template? = nil, frameworkName: String, frameworkVersion: String? = nil, platform: String? = nil) throws {

        // Set properties
        self.projectName = projectName
        self.baseDirectory = baseDirectory
        self.template = template
        projectFileURL = URL(fileURLWithPath: baseDirectory).appendingPathComponent(projectName).appendingPathComponent("\(projectName).composite")
        
        // Fetch framework init from FrameworkInterface.plist
        frameworkInterface = try FrameworkInterface.loadCommands(for: frameworkName)
        if let template = template, let commands = template.initType.commands(frameworkInterface) {
            frameworkInit = commands
        } else {
            frameworkInit = frameworkInterface.initInterface.initEmpty
        }
        
        // Set up queue
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInitiated
    }
    
    func initializeProject(output: @escaping (String)->Void, finished: @escaping (Int) -> Void) throws {
        
        // 1. Create project directory (if needed)
        //    Some frameworks create the project directory themselves.
        //    If so, createProjectDirectory is false
        let bashDirectory: String
        if frameworkInit.createProjectDirectory == true {
            bashDirectory = URL(fileURLWithPath: baseDirectory).appendingPathComponent(projectName).path
            try FileManager.default.createDirectory(atPath: bashDirectory, withIntermediateDirectories: true)
        } else {
            bashDirectory = baseDirectory
        }
        
        // 2. Initialize new FrameworkInit instance
        //    From bashDirectory set in step 1
        let initOperation = frameworkInitOperation(directory: bashDirectory, output: <#T##(String) -> Void#>)
        
        //        operationQueue.addOperation(operation)

        
        // 3. Create directories (if needed)
        
        // 4. Run framework initializer (e.g. etherlime init, if available)
        
        // 5. Copy template files to the project and rename to project name if necessary
        
        // 6. ...? Run script to finish up?
        
        
    }
    
    private func saveProjectFile() {
        
        // Prepare openfile
        var openFile: String? = nil
        if let templateOpenFile = template?.openFile {
            openFile = templateOpenFile.replacingOccurrences(of: "$(PROJECT_NAME)", with: projectName)
        }
        
        // TODO: fix framework version
        let project = Project(name: projectName, platformName: frameworkInterface.platform, frameworkName: frameworkInterface.framework, frameworkVersion: "0", lastOpenFile: openFile)
        
        // save openFile in projectfile as lastOpenedFile
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        do {
            let data = try encoder.encode(project)
            FileManager.default.createFile(atPath: projectDirectory.appendingPathComponent("\(projectName).composite").path, contents: data, attributes: nil)
        } catch {
            print(error)
            assertionFailure()
        }
    }
    
    func cancel() {
        operationQueue.cancelAllOperations()
    }
}

// Operations
extension ProjectInit {
    
    private func createDirectoriesOperation(output: @escaping (String)->Void) -> Operation? {

        guard let directories = frameworkCommands.initDirectories, directories.count > 0 else { return nil }
        
        let operation = BlockOperation {
            for directory in directories {
                let url = self.projectDirectory.appendingPathComponent(directory, isDirectory: true)
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                } catch {
                    output("ERROR creating \(url.path) directory.")
                }
            }
        }
        return operation

    }
    
    private func copyFilesOperation(output: @escaping (String)->Void) -> Operation? {

        let operation = BlockOperation {
            
            // Copy files
            if let copyFiles = self.template?.copyFiles {
                for file in copyFiles {
                    do {
                        let newFilename = try file.copy(projectName: self.projectName, projectDirectory: self.projectDirectory)
                        output("Copied \(newFilename) to \(file.destination).")
                    } catch {
                        output("ERROR copying \(file.filename) to \(file.destination):")
                        output(error.localizedDescription)
                    }
                }
            }
        }
        return operation
    }
    
    private func frameworkInitOperation(directory: String, output: @escaping (String)->Void) -> Operation? {

        do {
            let operation = try BashOperation(directory: directory, commands: frameworkInit.commands)
            operation.outputClosure = output
            operation.completionBlock = {
            
                //            // Copy files
                //            if let copyFiles = self.template?.copyFiles {
                //                for file in copyFiles {
                //                    do {
                //                        let newFilename = try file.copy(projectName: self.projectName, projectDirectory: self.projectDirectory)
                //                        output("Copied \(newFilename) to \(file.destination).")
                //                    } catch {
                //                        output("ERROR copying \(file.filename) to \(file.destination).")
                //                    }
                //                }
                //            }
                
                // Create .comp project file
                self.saveProjectFile()
                
                finished(operation.exitStatus ?? 0)
            }
        } catch {
            output("ERROR creating \(url.path) directory.")
            output(error.localizedDescription)
            self.operationQueue.cancelAllOperations()
        }
        return operation
    }
    
}
