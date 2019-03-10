//
//  String+Indentation.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2015-10-16.
//
//  ---------------------------------------------------------------------------
//
//  © 2015-2018 1024jp
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

enum IndentStyle {
    
    case tab
    case space
}


private struct DetectionLines {
    
    static let min = 5
    static let max = 100
    
    private init() { }
}


extension String {
    
    // MARK: Public Methods
    
    /// detect indent style
    var detectedIndentStyle: IndentStyle? {
        
        guard !self.isEmpty else { return nil }
        
        // count up indentation
        var tabCount = 0
        var spaceCount = 0
        var lineCount = 0
        self.enumerateLines { (line, stop) in
            guard lineCount < DetectionLines.max else {
                stop = true
                return
            }
            
            lineCount += 1
            
            guard let character = line.first else { return }
            
            // check first character
            switch character {
            case "\t":
                tabCount += 1
            case " ":
                spaceCount += 1
            default:
                break
            }
        }
        
        // no enough lines to detect
        guard tabCount + spaceCount >= DetectionLines.min else { return nil }
        
        // detect indent style
        if tabCount > spaceCount * 2 {
            return .tab
        }
        if spaceCount > tabCount * 2 {
            return .space
        }
        
        return nil
    }
    
    
    /// standardize indent style
    func standardizingIndent(to indentStyle: IndentStyle, tabWidth: Int) -> String {
        
        let spaces = String(repeating: " ", count: tabWidth)
        
        let indent: (before: String, after: String) = {
            switch indentStyle {
            case .space:
                return (before: "\t", after: spaces)
            case .tab:
                return (before: spaces, after: "\t")
            }
        }()
        
        let regex = try! NSRegularExpression(pattern: "(^|\\G)" + indent.before, options: .anchorsMatchLines)
        
        return regex.stringByReplacingMatches(in: self, range: self.nsRange, withTemplate: indent.after)
    }
    
    
    /// detect indent level of line at the location
    func indentLevel(at index: String.Index, tabWidth: Int) -> Int {
        
        assert(tabWidth > 0)
        
        let indentRange = self.rangeOfIndent(at: index)
        
        guard !indentRange.isEmpty else { return 0 }
        
        let indent = self[indentRange]
        let numberOfTabs = indent.components(separatedBy: "\t").count - 1
        
        return numberOfTabs + ((indent.count - numberOfTabs) / tabWidth)
    }
    
    
    /// calculate column number at location in the line expanding tab (\t) character
    func column(of location: Int, tabWidth: Int) -> Int {
        
        assert(tabWidth > 0)
        
        let index = String.UTF16Index(encodedOffset: location).samePosition(in: self)!
        
        let lineRange = self.lineRange(at: index)
        let column = self.distance(from: lineRange.lowerBound, to: index)
        
        // count tab width
        let beforeInsertion = self[lineRange.lowerBound..<index]
        let numberOfTabs = beforeInsertion.components(separatedBy: "\t").count - 1
        
        return column + numberOfTabs * (tabWidth - 1)
    }
    
    
    /// range of indent characters in line at the location
    func rangeOfIndent(at location: Int) -> NSRange {
        
        let lineRange = (self as NSString).lineRange(at: location)
        
        let range = (self as NSString).range(of: "^[ \\t]+", options: .regularExpression, range: lineRange)
        
        guard range.location != NSNotFound else {
            return NSRange(location: location, length: 0)
        }
        
        return range
    }
    
    
    /// range of indent characters in line at the location
    func rangeOfIndent(at index: String.Index) -> Range<String.Index> {
        
        let lineRange = self.lineRange(at: index)
        
        guard let indentRange = self.range(of: "^[ \\t]+", options: .regularExpression, range: lineRange) else {
            return index..<index
        }
        
        return indentRange
    }
    
    
    /// Range for deleting soft-tab or nil if the character to delete is not speace.
    ///
    /// - Parameters:
    ///   - range: The range of selection.
    ///   - tabWidth: The number of spaces for the soft tab.
    /// - Returns: Range to delete or nil if the caracter to delete is not soft-tab.
    func rangeForSoftTabDeletion(in range: NSRange, tabWidth: Int) -> NSRange? {
        
        assert(tabWidth > 0)
        assert(range.location != NSNotFound)
        
        guard
            range.length == 0,
            self.rangeOfIndent(at: range.location).upperBound >= range.location
            else { return nil }
        
        let column = self.column(of: range.location, tabWidth: tabWidth)
        let targetLength = tabWidth - (column % tabWidth)
        let targetRange = NSRange((range.location - targetLength)..<range.location)
        
        guard
            range.location >= targetLength,
            let range = Range(targetRange, in: self),
            self[range].allSatisfy({ $0 == " " })
            else { return nil }
        
        return targetRange
    }
    
    
    /// Soft-tab to add.
    ///
    /// - Parameters:
    ///   - location: The location of insertion point.
    ///   - tabWidth: The number of spaces for the soft tab.
    /// - Returns: String to insert as the tab.
    func softTab(at location: Int, tabWidth: Int) -> String {
        
        assert(tabWidth > 0)
        assert(location >= 0)
        
        let column = self.column(of: location, tabWidth: tabWidth)
        let length = tabWidth - (column % tabWidth)
        
        return String(repeating: " ", count: length)
    }
    
}
