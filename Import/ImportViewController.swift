//
//  ImportViewController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/7/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

final class ImportViewController: NSViewController {
    
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var createNewProjectButton: NSButton!
    @IBOutlet var importDatasource: ImportDatasource!

    override var representedObject: Any? {
        didSet {
            guard let representedObject = representedObject as? TextDocument else { return }
            self.importDatasource.document = representedObject
            outlineView.reloadData()
            outlineView.expandItem(nil, expandChildren: true)
            
            // Select first framework
            outlineView.selectRowIndexes([1], byExtendingSelection: true)
            
            // If no suitable frameworks were found
            if importDatasource.platforms?.isEmpty ?? true {
                self.noFrameworksFound()
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    @IBAction func createNewProject(_ sender: Any) {
        
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = (representedObject as! NSDocument).fileURL?.deletingPathExtension().path ?? ""
        savePanel.beginSheetModal(for: view.window!) { result in
            
            guard result == .OK, let directory = savePanel.url else { return }
            
            // Do not allow overwriting existing files or directories
            guard ProjectInit.canCreateProject(at: directory) == true else {
                let alert = NSAlert()
                alert.messageText = "Cannot overwrite existing file or directory."
                alert.informativeText = "Choose another projectname."
                alert.runModal()
                return
            }
            
            // Fetch selected framework
//            guard let framework = self.outlineView.item(atRow: outlineView.selectedRow) as? DependencyFrameworkViewModel else { return assertionFailure() }
//            
//            // Create project init
//            let projectInit = ProjectInit(projectName: <#T##String#>, baseDirectory: <#T##String#>, framework: <#T##DependencyFrameworkViewModel#>, platform: <#T##DependencyPlatformViewModel#>)
            
            
            // Fetch selected view models
//            let platform = platforms[platformPopup.indexOfSelectedItem]
//            let framework = platform.frameworks[frameworkPopup.indexOfSelectedItem]
//
//            let projectInit = try ProjectInit(projectName: projectname, baseDirectory: baseDirectory.path, template: template, framework: framework, platform: platform)
//            return projectInit
            
//            let projectName = directory.lastPathComponent.replacingOccurrences(of: " ", with: "-") // e.g. "MyProject"
//            let baseDirectory = directory.deletingLastPathComponent() // e.g. "/~/Documents/"
//
//            do {
//                let projectInit = try self.createProjectInit(projectname: projectName, baseDirectory: baseDirectory, template: template)
//                self.projectInit = projectInit
//            } catch {
//                let alert = NSAlert(error: error)
//                alert.runModal()
//            }
            
            let id = NSStoryboardSegue.Identifier("ProjectInitSegue")
            self.performSegue(withIdentifier: id, sender: self)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.view.window?.close()
    }
    
    func noFrameworksFound() {
        
        self.createNewProjectButton.isEnabled = false
        let alert = NSAlert()
        alert.messageText = "Unable to open file"
        alert.informativeText = "Unknown contract type"
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .warning
        
        alert.beginSheetModal(for: self.view.window!) { response in
            self.view.window?.close()
        }
    }
}

extension ImportViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

        guard let view: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ImportCellView"), owner: self) as? NSTableCellView else {
            assertionFailure()
            return nil
        }
        
        if let item = item as? DependencyPlatformViewModel {
            view.textField?.stringValue = item.name
        } else if let item = item as? DependencyFrameworkViewModel {
            view.textField?.stringValue = item.name
        } else {
            assertionFailure()
            view.textField?.stringValue = ""
        }

        return view
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return item is DependencyFrameworkViewModel
    }
}


