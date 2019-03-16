//
//  ProjectWindowController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/11/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa


private struct SerializationKey {
    
    static let project = "project"
}

final class ProjectWindowController: NSWindowController {
    
    @IBOutlet weak var runButton: NSToolbarItem!
    
    override var document: AnyObject? {
        didSet {
            window?.contentViewController?.representedObject = document
        }
    }
    
    /// ProjectInitVC and ImportVC pass their stdout here
    var stdout: String = "" {
        didSet {
            
            guard let outputcontrollers = self.contentViewController?.findViewControllers(subclassOf: OutputViewController.self) else {
                return
            }
            _ = outputcontrollers.map { $0.stdout = stdout}
            print(stdout)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shouldCascadeWindows = true        
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.isRestorable = false
//        window?.appearance = NSAppearance(named: .vibrantDark)
//            window?.restorationClass = EditWindowRestoration.self
    }
    

    @IBAction func runButtonClicked(_ sender: Any) {
        
//        guard let document = document as? Document, let interface = document.interface else { return }
//        script?.terminate()
//        saveEditorFile()
//
//        do {
//            script = try interface.executeRun(workDirectory: document.workDirectory, output: { output in
//                self.setConsole(output)
//            }) { exitStatus in
//                self.script = nil
//                guard exitStatus == 0 else {
//                    let error = CompositeError.bashScriptFailed("Bash error")
//                    let alert = NSAlert(error: error)
//                    alert.runModal()
//                    return
//                }
//            }
//        } catch {
//            let alert = NSAlert(error: error)
//            alert.runModal()
//        }

    }

    @IBAction func pauseButtonClicked(_ sender: Any) {
//        script?.terminate()
//        script = nil
//        setConsole("Cancelled.")
//        runButton.isEnabled = true
    }
    
    @IBAction func lintButtonClicked(_ sender: Any) {
        
//        guard let document = document as? Document, let interface = document.interface else { return }
//        script?.terminate()
//        saveEditorFile()
//
//        do {
//            script = try interface.executeLint(workDirectory: document.workDirectory, output: { output in
//                self.setConsole(output)
//            }, finished: { exitStatus in
//                guard exitStatus == 0 else {
//                    let error = CompositeError.bashScriptFailed("Bash error")
//                    let alert = NSAlert(error: error)
//                    alert.runModal()
//                    return
//                }
//            })
//        } catch {
//            let alert = NSAlert(error: error)
//            alert.runModal()
//        }
    }
    
    @IBAction func webButtonClicked(_ sender: Any) {
        
      
        
//        guard let project = project, let sender = sender as? NSButton else { return }
//
//        if let webserver = webserver { webserver.terminate() }
//
//        if sender.state == .on {
////            sender.highlight(true)
//            do {
//                webserver = try ScriptTask.webserver(project: project, output: { output in
//                    self.setConsole(output)
//                }) {
//                    // finish
//                }
//            } catch {
////                sender.highlight(false)
//                let alert = NSAlert(error: error)
//                alert.runModal()
//            }
//        }
    }
    
    //    override func windowTitle(forDocumentDisplayName displayName: String) -> String {
    //        <#code#>
    //    }
    
    
//    override func encodeRestorableState(with coder: NSCoder) {
//
//        // There is an issue encoding TextDocuments. The Project property in TextDocument
//        // is not being encoded. It seems that NSDocument properties of NSDocuments can't be stored
//        // So instead, we save the project file, and set the lastOpenFile to the current TextDocument
//        if let textDocument = document as? TextDocument, let project = textDocument.project {
//            coder.encode(project, forKey: SerializationKey.project)
//        }
//
//        super.encodeRestorableState(with: coder)
//
//    }
//
//    override func restoreState(with coder: NSCoder) {
//        super.restoreState(with: coder)
//
//        if coder.containsValue(forKey: SerializationKey.project) {
//            let project = coder.decodeObject(forKey: SerializationKey.project) as? Project
//            NSLog("found project: %@", project ?? "NIL")
//        }
//    }
    
    // AppDelegate has generic implementation. This implementation selects current platform.
    @IBAction func showNodeSelector(_ sender: Any?) {
        let nodeSelectorWindowController = NSWindowController.instantiate(storyboard: "NodeSelector")
        nodeSelectorWindowController.showWindow(sender)
        
        let nodeSelector = (nodeSelectorWindowController.contentViewController as! NodeSelectorViewController)
        nodeSelector.selectPlatform = "Zilliqa"
    }
    
}
