//
//  SplitViewController+SyntaxTextViewDelegate.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/2/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa
import SavannaKit
import SourceEditor

extension SplitViewController: SyntaxTextViewDelegate {
    
    func didChangeText(_ syntaxTextView: SyntaxTextView) {
        
        
    }
    
    func didChangeSelectedRange(_ syntaxTextView: SyntaxTextView, selectedRange: NSRange) {
        
        
    }
    
    func lexerForSource(_ source: String) -> Lexer {
        return lexer
    }
    
}
