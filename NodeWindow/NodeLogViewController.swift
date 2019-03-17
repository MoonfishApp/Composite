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
        
        // Test text
/*        textView.string =
        """
        ZILLIQA KAYA RPC SERVER (ver: 0.2.6)
        Server listening on 127.0.0.1:4200
        Running from local interpreter
        ================================================================================
        Available Accounts
        ================================================================================
        (1) f0ac4bae726065b4f6dd0ceccc2013fd87fb7cbe    (1000000 ZILs)    (Nonce: 0)
        (2) e9cb8b9017aeb5b7c045ead6354883ba64a2ae7f    (1000000 ZILs)    (Nonce: 0)
        (3) 0c3f43cb3d8fe38df51bac6c489061e8254db8e7    (1000000 ZILs)    (Nonce: 0)
        (4) 62531ba88ac5d68cf012980b2584130b9d46674c    (1000000 ZILs)    (Nonce: 0)
        (5) e940c3bc092a92ca6799d3fe565fcba4577456d1    (1000000 ZILs)    (Nonce: 0)
        (6) acff1238ed66bfbcdd8b78ba9818e70dd5a9a858    (1000000 ZILs)    (Nonce: 0)
        (7) ae05b5cea27cceac21231d1eed05dc59d5e0ec52    (1000000 ZILs)    (Nonce: 0)
        (8) 0df7c1055969b5e78df255fae77743c9ca19b0ee    (1000000 ZILs)    (Nonce: 0)
        (9) 0c0686f8fe054aca99f0853f4b2686351fbacd77    (1000000 ZILs)    (Nonce: 0)
        (10) 03dd185fcb2ce5a25fab3a07af07818f7e7e9e3a    (1000000 ZILs)    (Nonce: 0)
        
        Private Keys
        ================================================================================
        (1) 8064a974f946dce7977580a01b681533a20cd6afa9c2470d162a37f9add2061f
        (2) 7df351de4048180234dfc0941595b3b72ec8d4da85bef02af3dddd2389af6cbf
        (3) 229f6395e21a6fa81be7c833b3f5d16e80c87f365168e453f4e918dfd2d9cada
        (4) f9c8ecb123ff2ca13abdb9c97b3a4688bf41e05821ace0b23af2cca2033ef172
        (5) 6273ec3d2e1c6aeebbc4904ba77b8183c8df99b9fd338933fb772048964853d7
        (6) 0a847771f1e8590ef0b7f59e3ac6a6fe756ea32a7c3bbbef583110027b542f6a
        (7) f2d31c4cfb65170bc8d43c468c1821770fdff85dffccc9e4f0bafef809085658
        (8) ab5713ae5fe4f35bff40a44bfbd2e6221d37c6db1289b1eab25ca7012fe2634b
        (9) 65249b088307dfadbc477099149cd7e198b174cb9e6f58e9b1da90a2156bce03
        (10) 44aec78fae6e543eaf9a3d2a6a32eab630687c10190df2c4d10cbcc324d29086
        """.replacingOccurrences(of: " 127.0.0.1", with: " http://127.0.0.1") */
        
    }
    
}

extension NodeLogViewController: NSTextViewDelegate {

    

    
}
