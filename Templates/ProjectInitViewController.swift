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
    var counter: Int = 0

    var projectInit: ProjectInit! {
        didSet {
            
            DispatchQueue.main.async {
            
                self.progressIndicator.startAnimation(self)
    //            progressIndicator.maxValue = Double(projectInit.stdOutputLines)
                do {
                    try self.projectInit.initializeProject(output: { output in
                        
                        DispatchQueue.main.async {
                            // Output in text view
                            let previousOutput = self.textView.string
                            let nextOutput = previousOutput + "\n" + output
                            self.textView.string = nextOutput
                            let range = NSRange(location:nextOutput.count,length:0)
                            self.textView.scrollRangeToVisible(range)
                            self.progressIndicator.increment(by: 1)
                            self.counter = self.counter + 1
                        }
                        
                    }) { exitStatus in
                        
                        DispatchQueue.main.async {
                            self.progressIndicator.stopAnimation(self)
                            
                            guard exitStatus == 0 else {
                                let error = CompositeError.bashScriptFailed("Bash error")
                                let alert = NSAlert(error: error)
                                alert.runModal()
                                return
                            }
                            
                            let documentController = NSDocumentController.shared
                            documentController.openDocument(withContentsOf: self.projectInit.projectFileURL, display: true) { (document, wasAlreadyOpen, error) in

                                if let error = error {
                                    self.progressIndicator.stopAnimation(self)
                                    let alert = NSAlert(error: error)
                                    alert.runModal()
                                }

//                                if let document = document as? ProjectDocument, let editWindowController = document.editWindowController {
//                                    editWindowController.setConsole(self.textView.string)
//                                    //                            editWindowController.project = self.projectDirectoryCreator.project
//                                }
                                self.view.window?.close()
                            }
                        }
                    }
                } catch {
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

/*
 
 
 How can I create new documents other than through user-action methods?
 You can use NSDocumentController’s open... methods, which create a document and, if shouldCreateUI is TRUE, also create the document’s window controller(s) and add the document to the list of open documents. These methods also check file paths and return an existing document for the file path if one exists.
 
 You can also use NSDocumentController's make... methods, which just create the document. Usually, you will want to call addDocument: to add the new document to the NSDocumentController.
 
 Finally, you can simply create a document yourself with any initializer the subclass supports. Usually, you will want to add the document to the NSDocumentController with NSDocumentController's addDocument: method.
 
 NSDocumentController's newDocument: action method creates a new document of the first type listed in the application’s array of document types (as configured in Xcode). But this isn't really enough for applications that want to support several distinct types of document.
 
 */
