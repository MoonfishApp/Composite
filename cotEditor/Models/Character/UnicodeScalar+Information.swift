//
//  UnicodeScalar+Information.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2016-07-26.
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

extension UnicodeScalar {
    
    /// code point string in format like `U+000F`
    var codePoint: String {
        
        return String(format: "U+%04tX", self.value)
    }
    
    
    /// code point pair in UTF-16 surrogate pair
    var surrogateCodePoints: [String]? {
        
        guard self.isSurrogatePair else { return nil }
        
        return [String(format: "U+%04X", UTF16.leadSurrogate(self)),
                String(format: "U+%04X", UTF16.trailSurrogate(self))]
    }
    
    
    /// if character becomes a surrogate pair in UTF-16
    var isSurrogatePair: Bool {
        
        return (UTF16.width(self) == 2)
    }
    
    
    /// Unicode name
    var name: String? {
        
        return UTF32Char(self.value).unicodeName
    }
    
    
    /// Unicode block name
    var blockName: String? {
        
        return UTF32Char(self.value).blockName
    }
    
    
    /// Localized and sanitized unicode block name
    var localizedBlockName: String? {
        
        guard let blockName = self.blockName else { return nil }
        
        return sanitize(blockName: blockName).localized(tableName: "Unicode")
    }
    
}



// MARK: -

// Implemented Unicode functions at UTF32Char level in order to cover single surrogate character that is not allowed by UnicodeScalar

extension UTF32Char {
    
    /// get Unicode name
    var unicodeName: String? {
        
        // get control character name from special table
        if let name = self.controlCharacterName {
            return name
        }
        
        // get unicode name from CFStringTransform API
        if let scalar = Unicode.Scalar(self) {
            // -> Avoid using `String(scalar).applyingTransform(.toUnicodeName, reverse: false)`
            //    because it cannot name simple digit number (2018-08 macOS 10.13).
            let mutable = NSMutableString(string: String(scalar))
            CFStringTransform(mutable as CFMutableString, nil, "Any-Name" as CFString, false)
            
            return mutable
                .replacingOccurrences(of: "\\N{", with: "")
                .replacingOccurrences(of: "}", with: "")
        }
        
        // create single surrogate character by ownself
        if let codeUnit = UTF16.CodeUnit(exactly: self) {
            if UTF16.isLeadSurrogate(codeUnit) {
                return "<lead surrogate-" + String(format: "%04X", self) + ">"
            }
            if UTF16.isTrailSurrogate(codeUnit) {
                return "<tail surrogate-" + String(format: "%04X", self) + ">"
            }
        }
        
        return nil
    }
    
    
    /// Unicode block name
    var blockName: String? {
        
        return UTF32Char.blockNameTable.first { $0.key.contains(self) }?.value
    }
    
}



// MARK: - Block Name Sanitizing

/// sanitize block name for localization
private func sanitize(blockName: String) -> String {
    
    // -> This is actually a dirty workaround to make the block name the same as the Apple's block naming rule.
    //    Otherwise, we cannot localize block name correctly. (2015-11 by 1024jp)
    
    return blockName
        .replacingOccurrences(of: " ([A-Z])$", with: "-$1", options: .regularExpression)
        .replacingOccurrences(of: "Extension-", with: "Ext. ")
        .replacingOccurrences(of: " And ", with: " and ")
        .replacingOccurrences(of: " For ", with: " for ")
        .replacingOccurrences(of: " Mathematical ", with: " Math ")
        .replacingOccurrences(of: "Supplementary ", with: "Supp. ")
        .replacingOccurrences(of: "Latin 1", with: "Latin-1")  // only for "Latin-1
}


/// check which block names will be lozalized (only for test use)
private func testUnicodeBlockNameLocalization(for language: String = "ja") {
    
    let bundleURL = Bundle.main.url(forResource: language, withExtension: "lproj")!
    let bundle = Bundle(url: bundleURL)
    
    for blockName in UTF32Char.blockNameTable.values {
        let sanitizedBlockName = sanitize(blockName: blockName)
        let localizedBlockName = bundle?.localizedString(forKey: sanitizedBlockName, value: nil, table: "Unicode")
        
        print((localizedBlockName == blockName) ? "⚠️" : "  ", sanitizedBlockName, localizedBlockName!, separator: "\t")
    }
}
