//
//  ProjectWindow.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 2/24/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class ProjectWindow: NSWindow {
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        self.titleVisibility = .hidden
    }

}
