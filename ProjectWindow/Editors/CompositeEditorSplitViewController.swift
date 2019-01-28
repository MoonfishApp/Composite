//
//  CompositeEditorSplitViewController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 1/17/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

final class CompositeEditorSplitViewController: NSSplitViewController {

    override var representedObject: Any? {
        
        didSet {
            for viewController in self.children {
                viewController.representedObject = representedObject
            }
        }
    }
}
