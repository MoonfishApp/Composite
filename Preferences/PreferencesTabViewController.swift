//
//  PreferencesTabViewController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/22/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class PreferencesTabViewController: NSTabViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = NSMakeSize(view.frame.size.width, view.frame.size.height)
    }
    
    override func viewDidAppear() {
        self.parent?.view.window?.title = self.title ?? "Preferences"
    }
    
}
