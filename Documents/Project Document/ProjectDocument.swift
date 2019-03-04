//
//  ProjectDocument.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/1/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation
import Cocoa

/*
 [NSDocumentController fileExtensionsFromType:] is deprecated, and does not work when passed a uniform type identifier (UTI). If the application didn't invoke it directly then the problem is probably that some other NSDocument or NSDocumentController method is getting confused by a UTI that's not actually declared anywhere. Maybe it should be declared in the UTExportedTypeDeclarations section of this app's Info.plist but is not. The alleged UTI in question is "app.composite.project".
 
 */

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
        
        return fileURL!.deletingLastPathComponent()
    }
    
    /// return document window's editor wrapper
    var viewController: NSViewController? {
        
        return self.windowControllers.first?.contentViewController
    }

    override class var autosavesInPlace: Bool {
        
        return true
    }

    override init() {
        
        super.init()
        hasUndoManager = false
        // Add your subclass-specific initialization here.
    }
    
    convenience init(project: Project, url: URL) {
        
        self.init()
        fileURL = url
        self.project = project
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
        
        let data = try Data(contentsOf: url)
        
        let decoder = PropertyListDecoder()
        self.project = try decoder.decode(Project.self, from: data)
        
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
    
    init?(coder aDecoder: NSCoder) {
        self.project = aDecoder.decodeObject(forKey: SerializationKey.project) as? Project
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
    

//    override func save(_ sender: Any?) {
//        <#code#>
//    }
//    
//    override func saveAs(_ sender: Any?) {
//        <#code#>
//    }
    
    override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
        
        
        // modify place to create backup file
        //   -> save backup file always in `~/Library/Autosaved Information/` directory
        //      (The default backup URL is the same directory as the fileURL.)
        let newURL: URL = {
//            guard
//                saveOperation == .autosaveElsewhereOperation,
//                let fileURL = self.fileURL
//                else { return url }
//
//            let autosaveDirectoryURL = (DocumentController.shared as! DocumentController).autosaveDirectoryURL
//            let baseFileName = fileURL.deletingPathExtension().lastPathComponent
//                .replacingOccurrences(of: ".", with: "", options: .anchored)  // avoid file to be hidden
            
            // append a unique string to avoid overwriting another backup file with the same file name.
//            let fileName = baseFileName + " (" + self.autosaveIdentifier + ")"
            
//            return autosaveDirectoryURL.appendingPathComponent(fileName).appendingPathExtension(fileURL.pathExtension)
            return URL(fileURLWithPath: "")
        }()
        
        super.save(to: newURL, ofType: typeName, for: saveOperation) { [unowned self] (error: Error?) in
            defer {
                completionHandler(error)
            }
            
            guard error == nil else { return }
//
//            assert(Thread.isMainThread)
//
//            // apply syntax style that is inferred from the file name or the shebang
//            if saveOperation == .saveAsOperation {
//                let fileName = url.lastPathComponent
//                if let styleName = SyntaxManager.shared.settingName(documentFileName: fileName)
//                    ?? SyntaxManager.shared.settingName(documentContent: self.string)
//                    // -> Due to the async-saving, self.string can be changed from the actual saved contents.
//                    //    But we don't care about that.
//                {
//                    self.setSyntaxStyle(name: styleName)
//                }
//            }
//
//            switch saveOperation {
//            case .saveOperation, .saveAsOperation, .saveToOperation:
//                self.analyzer.invalidateFileInfo()
//                ScriptManager.shared.dispatchEvent(documentSaved: self)
//            case .autosaveAsOperation, .autosaveElsewhereOperation, .autosaveInPlaceOperation: break
//            }
        }
    }
    
    private func applyContentToWindow() {
        if let viewController = self.viewController {
            viewController.representedObject = self
        }
    }
    
}

