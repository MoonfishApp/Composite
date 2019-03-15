//
//  OutputViewController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/18/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

final class OutputViewController: NSViewController {

    @IBOutlet var textView: NSTextView!
    
    /// Replaces content in textView with stdout
    var stdout: String = "" {
        didSet {
            self.textView.string = stdout
            self.textView.scrollToEndOfDocument(nil)
            
            // Hack to make URLs clickable
            self.textView.isEditable = true
            self.textView.checkTextInDocument(nil)
            self.textView.isEditable = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

