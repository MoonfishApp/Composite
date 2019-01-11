//
//  PlatformCollectionViewItem.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 1/7/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class PlatformCollectionViewItem: NSCollectionViewItem {
    
    @IBOutlet weak var logoImageView: NSImageView!
    @IBOutlet weak var platformLabel: NSTextField!
    @IBOutlet weak var infoLabel: NSTextField!
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
