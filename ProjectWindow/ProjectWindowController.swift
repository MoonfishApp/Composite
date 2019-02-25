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
    
    var project: Project? {
        if let projectDocument = (document as? TextDocument)?.project {
            return projectDocument.project
        }
        if let projectDocument = document as? ProjectDocument {
            return projectDocument.project
        } else {
            assertionFailure()
            return nil
        }
    }
    
    private let commandQueue: OperationQueue = OperationQueue()
    private var commandProgressObserver: NSKeyValueObservation?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shouldCascadeWindows = true        
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.isRestorable = false
//        window?.appearance = NSAppearance(named: .vibrantDark)
//        window?.restorationClass = EditWindowRestoration.self
        
        commandQueue.maxConcurrentOperationCount = 1
        commandQueue.qualityOfService = .userInteractive
        
        commandProgressObserver = commandQueue.observe(\OperationQueue.operationCount, options: .new) { queue, change in
            DispatchQueue.main.async {
//                if queue.operationCount == 0 {
//                    self.progressIndicator.stopAnimation(self)
//                    self.progressIndicator.isHidden = true
//                    self.TotalInstallCount = 0
//                } else {
//                    if queue.operationCount > self.TotalInstallCount {
//                        self.TotalInstallCount = queue.operationCount
//                    }
//                    self.progressIndicator.doubleValue = (1.0 - (Double(queue.operationCount) / Double(self.TotalInstallCount))) * 100.0
//                    self.progressIndicator.startAnimation(self)
//                    self.progressIndicator.isHidden = false
                }
            }
    }

    @IBAction func runButtonClicked(_ sender: Any) {
        
        guard let project = project else { return assertionFailure() }
        
        
        setConsole(text: "Run")

        
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
        
        guard let project = project else { return assertionFailure() }
        
        commandQueue.cancelAllOperations()
        setConsole(text: "", replaceText: true)
        
//        script?.terminate()
//        script = nil
//        setConsole("Cancelled.")
//        runButton.isEnabled = true
    }
    
    @IBAction func lintButtonClicked(_ sender: Any) {
        
        guard let project = project else { return assertionFailure() }
        
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
        
        guard let project = project else { return assertionFailure() }
      
        
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
    
    func setConsole(text: String, replaceText: Bool = false) {
        
        guard let inspectorItems = (self.contentViewController as? ProjectContentSplitViewController)?.splitViewItems,
            inspectorItems.count >= 3,
            let consoleItems = (inspectorItems[1].viewController as? ProjectContentSplitViewController)?.splitViewItems,
            consoleItems.count >= 2,
            let output = (consoleItems[1].viewController as? OutputViewController)
        else {
                return assertionFailure()
        }
        
        output.setOutput(text: text, replaceText: replaceText)
    }
}
