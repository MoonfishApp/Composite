//
//  TemplateOptionsViewController.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/26/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class TemplateOptionsViewController: NSViewController {

    weak var container: TemplateContainerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func back(_ sender: Any) {
        container.showTemplates()
    }
    
    @IBAction func done(_ sender: Any) {
        let savePanel = NSSavePanel()
        savePanel.beginSheetModal(for: view.window!) { (result) in

//            guard result == .OK, let directory = savePanel.url else { return }
//
//            // Temporary: do not allow overwriting existing files or directories
//            let fileManager = FileManager.default
//            guard fileManager.fileExists(atPath: directory.path) == false else { return }
//
//            let projectName = directory.lastPathComponent
//            let baseDirectory = directory.deletingLastPathComponent()
//
//            guard let selectedIndex = self.template.selectionIndexPaths.first else { return }
//            let selectedTemplate = self.itemAt(selectedIndex)
//            let templateName = selectedTemplate.templateName.isEmpty ? selectedTemplate.name : selectedTemplate.templateName
//            let selectedCategory = self.categories[selectedIndex.section]
//
//            let project = Project(name: projectName, baseDirectory: baseDirectory, lastOpenFile: selectedTemplate.openFile)
//            self.projectCreator = ProjectCreator(templateName: templateName, installScript: selectedCategory.command, project: project, copyFiles: selectedTemplate.copyFiles)
//
//            let id = NSStoryboardSegue.Identifier(rawValue: "PreparingSegue")
//            self.performSegue(withIdentifier: id, sender: self)
        }
    }
    
    /// Set up PreparingViewController
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
//        super.prepare(for: segue, sender: sender)
//        assert(projectCreator != nil)
//
//        let preparingViewController = ((segue.destinationController as! NSWindowController).contentViewController! as! PreparingViewController)
//        preparingViewController.projectCreator = projectCreator
//        self.view.window!.close()
    }
}
