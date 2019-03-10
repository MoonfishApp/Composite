//
//  ProjectDocument.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/1/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

//import Foundation
import Cocoa

private struct SerializationKey {
    
    static let project = "project"
}

final class ProjectDocument: NSDocument, NSCoding {
    
    static let fileExtension = "composite"
    
    /// The project instance
    private (set) var project: Project?
    
    ///
//    private (set) var interface: EditorInterface? = nil
    
    /// Parent directory of the project, e.g. ~/Projects (not ~/Projects/ProjectName)
    var baseDirectory: URL {
        
        return workDirectory.deletingLastPathComponent()
    }
    
    /// E.g. ~/Projects/ProjectName
    var workDirectory: URL {
        
        guard let fileURL = fileURL else { return URL(fileURLWithPath: "")}
        return fileURL.deletingLastPathComponent()
    }
    
    /// return document window's editor wrapper
    var viewController: NSViewController? {
        
        return self.windowControllers.first?.contentViewController
    }

    override class var autosavesInPlace: Bool {
        
        return true
    }

    override init() {
        
        // [caution] This method may be called from a background thread due to concurrent-opening.
        
        super.init()
        hasUndoManager = false
        // Add your subclass-specific initialization here.
    }
    
    convenience init(project: Project, url: URL) {
        
        self.init()
        fileURL = url
        self.project = project
    }
    
    init?(coder aDecoder: NSCoder) {
        self.project = aDecoder.decodeObject(forKey: SerializationKey.project) as? Project
    }
    
    /// can read document on a background thread?
    override class func canConcurrentlyReadDocuments(ofType: String) -> Bool {        
        
        return true
    }
    
    override func canAsynchronouslyWrite(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType) -> Bool {
        
        return true
    }
    
    /// return preferred file extension corresponding to the current syntax style
    override func fileNameExtension(forType typeName: String, saveOperation: NSDocument.SaveOperationType) -> String? {
        
        return ProjectDocument.fileExtension
    }
    
    override func duplicate(_ sender: Any?) {
        
        fatalError("Not supported")
    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        
        guard url.pathExtension == ProjectDocument.fileExtension else { throw CompositeError.fileNotFound(typeName) }
        
        self.project = try Project.open(url)

        // TODO: Load FrameworkInterface and EditorInterface
        
//        let platformName = project!.platformName
//        let frameworkName = project!.frameworkName
//        let frameworkVersion = project!.frameworkVersion
        
//        guard let platform = Platform.init(rawValue: platformName) else { throw CompositeError.platformNotFound(platformName) }
        
        //        interface = try EditorInterface.loadInterface(platform: platform, framework: frameworkName, version: frameworkVersion).first
    }
    
    
    /// store internal document state
    override func encodeRestorableState(with coder: NSCoder) {
        
        if let project = project {
            coder.encode(project, forKey: SerializationKey.project)
        }

        super.encodeRestorableState(with: coder)
    }
    
    /// resume UI state
    override func restoreState(with coder: NSCoder) {
        
        super.restoreState(with: coder)
        
        if let project = coder.decodeObject(forKey: SerializationKey.project) as? Project {
            self.project = project
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.project, forKey: SerializationKey.project)
    }
    
    /// avoid let system add the standard save panel accessory (pop-up menu for document type change)
    override var shouldRunSavePanelWithAccessoryView: Bool {
        
        return false
    }
    
    override func makeWindowControllers() {
        
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("ProjectWindow"), bundle: nil)
        // Note: Changing the storyboard ID "EditWindow" in the storyboard to "ProjectWindow"
        // somehow always get magically rolled back to "EditWindow" by Xcode. So "EditWindow"
        // it is then for now
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("EditWindow")) as! ProjectWindowController
        addWindowController(windowController)
        
        applyContentToWindow()
    }

    
    override func data(ofType typeName: String) throws -> Data {
        
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(project)
        return data
    }
    
    private func applyContentToWindow() {
        if let viewController = self.viewController {
            viewController.representedObject = self
        }
    }
    
    /// apply current state to menu items
//    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
//
//        switch menuItem.action {
//        case #selector(changeEncoding(_:))?:
//            let encodingTag = self.hasUTF8BOM ? -Int(self.encoding.rawValue) : Int(self.encoding.rawValue)
//            menuItem.state = (menuItem.tag == encodingTag) ? .on : .off
//
//        case #selector(changeLineEnding(_:))?:
//            menuItem.state = (LineEnding(index: menuItem.tag) == self.lineEnding) ? .on : .off
//
//        case #selector(changeSyntaxStyle(_:))?:
//            let name = self.syntaxParser.style.name
//            menuItem.state = (menuItem.title == name) ? .on : .off
//
//        default: break
//        }
//
//        return super.validateMenuItem(menuItem)
//    }
    
}

