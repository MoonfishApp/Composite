//
//  SolidityLexer.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 8/1/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation
import SourceEditor
import SavannaKit

/**
 Based on: http://solidity.readthedocs.io/en/v0.4.21/miscellaneous.html
 */
public class SolidityLexer: SourceCodeRegexLexer {
    
    public init() {
        
    }
    
    lazy var generators: [TokenGenerator] = {
        
        var generators = [TokenGenerator?]()
        
        // Functions
        
        generators.append(regexGenerator("(?<=(\\s|\\[|,|:))\\d+", tokenType: .number))
        
        generators.append(regexGenerator("\\.\\w+", tokenType: .identifier))
        
        // Global Variables
        let globalVariables = "block msg tx this super".components(separatedBy: " ")
        generators.append(keywordGenerator(globalVariables, tokenType: .identifier))
        
        let globalFunctions = "assert require revert keccak256 sha3 sha256 ripemd160 ecrecover addmod mulmod selfdestruct suicide now gasleft".components(separatedBy: " ")
        generators.append(keywordGenerator(globalFunctions, tokenType: .identifier))
        
        // Function Visibility Specifiers
        let functionVisibilitySpecifiers = "public private external internal".components(separatedBy: " ")
        
        generators.append(keywordGenerator(functionVisibilitySpecifiers, tokenType: .identifier))
        
        // Modifiers
        let modifiers = "pure view payable constant anonymous indexed".components(separatedBy: " ")
        
        generators.append(keywordGenerator(modifiers, tokenType: .keyword))
        
        // Keywords
        let reservedKeywords = "abstract after case catch default final in inline let match null of relocatable static switch try type typeof function contract pragma solidity import using mapping return".components(separatedBy: " ")
        
        generators.append(keywordGenerator(reservedKeywords, tokenType: .keyword))
                
        // Line comment
        generators.append(regexGenerator("//(.*)", tokenType: .comment))
        
        // Block comment
//        generators.append(regexGenerator("(/\\*)(.*)(\\*/)", options: [.dotMatchesLineSeparators], tokenType: .comment))
        generators.append(regexGenerator("/\\*([^*]|\\*+[^/])*\\*+/", options: [.dotMatchesLineSeparators], tokenType: .comment))
        
        
        // Single-line string literal
        generators.append(regexGenerator("(\"|@\")[^\"\\n]*(@\"|\")", tokenType: .string))
        
        // Editor placeholder
        var editorPlaceholderPattern = "(<#)[^\"\\n]*"
        editorPlaceholderPattern += "(#>)"
        generators.append(regexGenerator(editorPlaceholderPattern, tokenType: .editorPlaceholder))
        
        return generators.compactMap( { $0 })
    }()
    
    public func generators(source: String) -> [TokenGenerator] {
        return generators
    }
    
}
