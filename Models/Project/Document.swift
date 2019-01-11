//
//  Document.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/1/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation
import Cocoa

class Document: NSDocument {
    
    ///
    private (set) var project: Project?
    
    ///
    private (set) var interface: EditorInterface? = nil
    
    /// URL of the .comp project file E.g. ~/Projects/ProjectName/ProjectName.comp
    var projectFileURL: URL {
        return fileURL!
    }
    
    /// Parent directory of the project, e.g. ~/Projects (not ~/Projects/ProjectName)
    var baseDirectory: URL {
        return workDirectory.deletingLastPathComponent()
    }
    
    /// E.g. ~/Projects/ProjectName
    var workDirectory: URL {
        return projectFileURL.deletingLastPathComponent()
    }
    
    
    var editWindowController: EditWindowController? {
        for window in windowControllers {
            if let window = window as? EditWindowController, let doc = window.document as? Document, doc == self {
                return window
            }
        }
        return nil
    }

    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }
    
    convenience init(project: Project, url: URL) {
        self.init()
        fileURL = url
        self.project = project
    }

    
    override class var autosavesInPlace: Bool {
        return true
    }

    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Edit"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("EditWindow")) as! EditWindowController
        self.addWindowController(windowController)
        
//        windowController.project = self.project 
    }

    
    override func data(ofType typeName: String) throws -> Data {
        
        guard let editWindowController = editWindowController, let project = editWindowController.project else {
            assertionFailure()
            return Data()
        }
        
        editWindowController.saveEditorFile()
        
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(project)
        return data
    }

    
    override func read(from data: Data, ofType typeName: String) throws {

        let decoder = PropertyListDecoder()
        project = try decoder.decode(Project.self, from: data)
        
        let platformName = project!.platformName
        let frameworkName = project!.frameworkName
        let frameworkVersion = project!.frameworkVersion
        
        guard let platform = Platform.init(rawValue: platformName) else { throw CompositeError.platformNotFound(platformName) }
        
        interface = try EditorInterface.loadInterface(platform: platform, framework: frameworkName, version: frameworkVersion).first
    }

    
}

