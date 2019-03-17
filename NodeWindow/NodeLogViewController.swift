//
//  NodeLogViewController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/15/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class NodeLogViewController: NSViewController {
    
    @IBOutlet private var textView: NSTextView!

    var output: String = "" {
        didSet {
            DispatchQueue.main.async {
                let smartLinkedString = self.output.replacingOccurrences(of: " 127.0.0.1", with: " http://127.0.0.1")
                self.textView.string = smartLinkedString
                self.textView.isEditable = true
                self.textView.checkTextInDocument(nil)
                self.textView.isEditable = false
                self.textView.scrollToEndOfDocument(nil)
            }
        }
    }
    
    weak var node: Node? {
        didSet {
            guard let node = node else { return }
            
            self.output = node.output
            
            // KVO output
            self.logObserver = node.observe(\Node.output, options: .new) { node, change in
                self.output = node.output
            }
        }
    }
    
    private var logObserver: NSKeyValueObservation?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension NodeLogViewController: NSTextViewDelegate {

    

    
}
