//
//  PreparingViewController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/14/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class ProjectInitViewController: NSViewController {
    
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var cancelButton: NSButton!
    
    private var progressObserver: NSKeyValueObservation!

    var projectInit: ProjectInit! {
        didSet {
            
                // observe init progress
                self.progressObserver = self.projectInit.observe(\ProjectInit.progress, options: .new) { project, change in
                    DispatchQueue.main.async {
                        self.progressIndicator.doubleValue = project.progress
                    }
                }
                
                self.progressIndicator.startAnimation(self)
                do {
                    try self.projectInit.initializeProject(output: { output in
                        
                        DispatchQueue.main.async {
                            // Output in text view
                            let previousOutput = self.textView.string
                            let nextOutput = previousOutput + "\n" + output
                            self.textView.string = nextOutput
                            let range = NSRange(location:nextOutput.count,length:0)
                            self.textView.scrollRangeToVisible(range)
                        }
                        
                }) { exitStatus, error in
                        
                    DispatchQueue.main.async {
                        self.progressIndicator.stopAnimation(self)
                        
                        guard exitStatus == 0 && error == nil else {
                            let error = error ?? CompositeError.bashScriptFailed("Bash error")
                            let alert = NSAlert(error: error)
                            alert.runModal()
                            return
                        }
                        
                        self.view.window?.close()
                        DocumentController.shared.openDocument(withContentsOf: self.projectInit.projectFileURL, display: true) { (document, wasAlreadyOpen, error) in

                            if let error = error {
                                self.progressIndicator.stopAnimation(self)
                                let alert = NSAlert(error: error)
                                alert.runModal()
                            }
                            self.view.window?.close()
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.progressIndicator.stopAnimation(self)
                    let alert = NSAlert(error: error)
                    alert.runModal()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
//        projectInit.scriptTask?.terminate()
        view.window?.close()
    }    
}


