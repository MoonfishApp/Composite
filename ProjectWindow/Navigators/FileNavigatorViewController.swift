//
//  FileBrowserViewController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/18/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

/// TODO: key bindings https://www.raywenderlich.com/1201-nsoutlineview-on-macos-tutorial
final class FileNavigatorViewController: NSViewController {
    
    @IBOutlet weak var fileView: NSOutlineView!

    private var root: FileItem?
    private var projectObserver: NSKeyValueObservation?
    private var fileURLObserver: NSKeyValueObservation?
    
    override var representedObject: Any? {
        didSet {
            guard let representedObject = representedObject as? NSDocument else { return }
            
            if let project = representedObject as? ProjectDocument {
                
                fileURLObserver?.invalidate()
                fileURLObserver = project.observe(\ProjectDocument.fileURL, options: .new) { document, change in
                    
                    try? self.load(url: project.workDirectory, openFile: project.fileURL?.path)
                }
                
            } else if let textDocument = representedObject as? TextDocument {
                
//                guard let project = textDocument.project else {
//                    assertionFailure()
//                    return
//                }
                
                if let project = textDocument.project, let url = textDocument.project?.workDirectory {
                    try? self.load(url: url, openFile: textDocument.fileURL?.path)
                } else {
                
                    fileURLObserver?.invalidate()
                    fileURLObserver = textDocument.observe(\TextDocument.project, options: .new) { textDocument, change in
                        
                        guard let url = textDocument.project?.workDirectory else { return }

                        try? self.load(url: url, openFile: textDocument.fileURL?.path)
                    }
                }
            }

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    deinit {
        projectObserver?.invalidate()
        fileURLObserver?.invalidate()
    }
    
    @IBAction func fileViewDoubleClick(_ sender: NSOutlineView) {
        guard let item = sender.item(atRow: sender.clickedRow) as? FileItem, item.isDirectory == true else { return }
        
        if sender.isItemExpanded(item) {
            sender.collapseItem(item)
        } else {
            sender.expandItem(item)
        }
    }
    
    
    /// Called from ProjectWindowController
    func load(url: URL, openFile: String? = nil) throws {
        
        root = try FileItem(url: url)
        fileView.reloadData()
        
        // Open last open file from project (or default file in a new project)
        fileView.expandItem(root) // Always expand root
        guard let openFile = openFile as NSString?, var root = self.root else { return }
        let components = openFile.pathComponents
        for component in components {
            for item in root.children {
                if component == item.localizedName {
                    fileView.expandItem(item)
                    fileView.selectRowIndexes([fileView.row(forItem: item)], byExtendingSelection: false)
                    root = item
                }
            }
        }
    }
}

extension FileNavigatorViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? FileItem else { return nil }
        guard let view: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FileCell"), owner: self) as? NSTableCellView else {
            return nil
        }
        view.textField?.stringValue = item.localizedName
        view.imageView?.image = item.icon        
        return view
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else { return }
        
        let supportedPathExtensions = ["sol", "js", "json"]
        let selectedIndex = outlineView.selectedRow
        guard let item = outlineView.item(atRow: selectedIndex) as? FileItem, supportedPathExtensions.contains(item.url.pathExtension) else { return }

        let editWindowController = (view.window?.windowController as! ProjectWindowController)
        editWindowController.setEditor(url: item.url)
    }
}

extension FileNavigatorViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        // If root is not set, don't show anything
        guard root != nil else { return 0 }
        
        // item is nil if requesting root
        guard let item = item as? FileItem else { return 1 }
        
        return item.children.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let item = item as? FileItem else {
            assertionFailure()
            return false
        }
        return item.isDirectory
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let item = item as? FileItem else {
            return root!
        }
        return item.children[index]
    }
}


//    func loadBrowser(select item: String? = nil) {
////        guard let project = project, let document = document as? ProjectDocument else { return }
//        window?.title = project?.name ?? "Demo Project"
//        do {
////            let url = URL(fileURLWithPath: "/Users/ronalddanger/Development/Temp/Untitled9875/")
//
//            let url = URL(fileURLWithPath: "/Users/ronalddanger/Development/Temp/Untitled9875")
//            try fileBrowserViewController.load(url: url, projectName: "Demo Project", openFile: "contracts/Untitled9875.sol")
////            try fileBrowserViewController.load(url: document.workDirectory, projectName: project.name, openFile: item)
//        } catch {
//            let alert = NSAlert(error: error)
//            alert.runModal()
//        }
//    }
