//
//  EditWindowController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/11/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa
import SavannaKit

class EditWindowController: NSWindowController {
    
    @IBOutlet weak var runButton: NSToolbarItem!
    
    var editorURL: URL? = nil
    
    override var document: AnyObject? {
        didSet {
            
            // Load file browser and open last opened file
            var lastOpenFile: URL? = nil
            if let file = project?.lastOpenFile {
                lastOpenFile = (document as! Document).workDirectory.appendingPathComponent(file)
            }
            
            loadBrowser(select: lastOpenFile?.path)
            if let lastOpenFile = lastOpenFile {
                setEditor(url: lastOpenFile)
            }
        }
    }
    
    var project: Project? {
        guard let document = self.document as? Document else { return nil }
        return document.project
    }
    
    var consoleTextView: NSTextView {
        return (self.window?.contentViewController?.childViewControllers[1] as! SplitViewController).consoleView
    }
    
    var fileBrowserViewController: FileBrowserViewController {
        return (self.window?.contentViewController! as! NSSplitViewController).childViewControllers[0] as! FileBrowserViewController
    }
    
    private var editView: SyntaxTextView {
        return (self.window?.contentViewController?.childViewControllers[1] as! SplitViewController).editorView
    }

    override func windowDidLoad() {
        super.windowDidLoad()
//        window?.appearance = NSAppearance(named: .vibrantDark)
//            window?.restorationClass = EditWindowRestoration.self
    }
    
//    override func awakeFromNib() {
//        loadBrowser()
//    }
    
    func loadBrowser(select item: String? = nil) {
        guard let project = project, let document = document as? Document else { return }
        window?.title = project.name        
        do {
            try fileBrowserViewController.load(url: document.workDirectory, projectName: project.name, openFile: item)
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
    }

    
    /// Sets console vc text. Called by PreparingViewController
    func setConsole(_ string: String) {
        consoleTextView.string = consoleTextView.string + "\n" + string
        
        let range = NSRange(location:consoleTextView.string.count,length:0)
        consoleTextView.scrollRangeToVisible(range)
    }
    
    func setEditor(url: URL) {
        do {
            let text = try String(contentsOf: url)
            saveEditorFile()
            editView.text = text
            editorURL = url
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
    }
    
    func saveEditorFile() {
        guard let editorURL = editorURL else {
            return
        }
        do {
//            Occasional bug: projects get duplicated as subdirectories of an open project.
//            wrong url
//            ▿ file:///Users/ronalddanger/Development/Temp/Untitled89652768/Untitled2346789/contracts/TutorialToken.sol
//
//            untitled 89 is the right one.
//            this file is saved in the 2768 directory. the full project is actually saved there
//            print("******===== \(editorURL.path)")
            try editView.text.write(to: editorURL, atomically: true, encoding: .utf8)
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
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
}
