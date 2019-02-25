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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func setOutput(text: String, replaceText: Bool = false) {
        DispatchQueue.main.async {
            // Output in text view
            let previousOutput = replaceText == true ? "" : self.textView.string
            let nextOutput = previousOutput + "\n" + text
            self.textView.string = nextOutput
            let range = NSRange(location:nextOutput.count,length:0)
            self.textView.scrollRangeToVisible(range)
        }
    }
    
    
    
}
