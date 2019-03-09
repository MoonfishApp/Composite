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
//            let index = outlineView.index
            
//            outlineView.selectite
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    @IBAction func createNewProject(_ sender: Any) {
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.view.window?.close()
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


