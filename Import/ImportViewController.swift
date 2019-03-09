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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func createNewProject(_ sender: Any) {
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.view.window?.close()
    }
}

extension ImportViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        return nil
    }
    
//    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
//        <#code#>
//    }
}


