//
//  TemplateCollectionViewItem.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/13/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

// See https://www.youtube.com/watch?v=26yik3rnPiQ

class TemplateCollectionViewItem: NSCollectionViewItem {
    
    @IBOutlet weak var erc: NSTextField!
    @IBOutlet weak var descriptionTextField: NSTextField!
    @IBOutlet weak var moreInfoButton: NSButton!
    
    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            view.layer?.backgroundColor = isSelected == true ? NSColor.lightGray.cgColor : NSColor.white.cgColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = isSelected == true ? NSColor.lightGray.cgColor : NSColor.white.cgColor
    }
}
