//
//  String+Additions.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2016-05-27.
//
//  ---------------------------------------------------------------------------
//
//  © 2016-2018 1024jp
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

private let kMaxEscapesCheckLength = 8

extension String {
    
    /// return copied string to make sure the string is not a kind of NSMutableString.
    var immutable: String {
        
        return NSString(string: self) as String
    }
    
    
    /// unescape backslashes
    var unescaped: String {
        
        // -> According to the following sentence in the Swift 3 documentation, these are the all combinations with backslash.
        //    > The escaped special characters \0 (null character), \\ (backslash), \t (horizontal tab), \n (line feed), \r (carriage return), \" (double quote) and \' (single quote)
        let entities = ["\0": "0",
                        "\t": "t",
                        "\n": "n",
                        "\r": "r",
                        "\"": "\"",
                        "\'": "'",
                        ]
        
        return entities
            .mapValues { try! NSRegularExpression(pattern: "(?<!\\\\)(?:\\\\\\\\)*(\\\\" + $0 + ")") }
            .reduce(self) { (string, entity) in
                entity.value.matches(in: string, range: string.nsRange)
                    .map { $0.range(at: 1) }
                    .compactMap { Range($0, in: string) }
                    .reversed()
                    .reduce(string) { $0.replacingCharacters(in: $1, with: entity.key) }
            }
    }
    
}



extension StringProtocol where Self.Index == String.Index {
    
    /// range of the line containing a given index
    func lineRange(at index: Index, excludingLastLineEnding: Bool = false) -> Range<Index> {
        
        return self.lineRange(for: index..<index, excludingLastLineEnding: excludingLastLineEnding)
    }
    
    
    /// line range adding ability to exclude last line ending character if exists
    func lineRange(for range: Range<Index>, excludingLastLineEnding: Bool) -> Range<Index> {
        
        let lineRange = self.lineRange(for: range)
        
        guard excludingLastLineEnding,
            let index = self.index(lineRange.upperBound, offsetBy: -1, limitedBy: lineRange.lowerBound),
            self[index] == "\n" else { return lineRange }
        
        return lineRange.lowerBound..<self.index(before: lineRange.upperBound)
    }
    
    
    /// Find the range in the String of the character sequence of a given character set contains a given index found in a given range.
    ///
    /// - Parameters:
    ///   - aSet: A character set to find.
    ///   - index: The index of character to be contained to the result range. `index` must be within `aRange`.
    ///   - aRange: The range in which to search. `aRange` must not exceed the bounds of the receiver.
    /// - Returns: The range in the receiver of the first character found from aSet within aRange. Or `nil` if none of the characters in `aSet` are found.
    func rangeOfCharacters(from aSet: CharacterSet, at index: Index, range aRange: Range<Index>? = nil) -> Range<Index>? {
        
        let range = aRange ?? self.startIndex..<self.endIndex
        
        guard range.contains(index) else { return nil }
        
        let characterSet = aSet.inverted
        
        let lowerBound = self.rangeOfCharacter(from: characterSet, options: .backwards, range: range.lowerBound..<index)?.upperBound ?? range.lowerBound
        let upperBound = self.rangeOfCharacter(from: characterSet, range: index..<range.upperBound)?.lowerBound ?? range.upperBound
        
        return lowerBound..<upperBound
    }
    
    
    /// check if character at the index is escaped with backslash
    func isCharacterEscaped(at index: Index) -> Bool {
        
        let escapes = self[..<index].suffix(kMaxEscapesCheckLength).reversed().prefix { $0 == "\\" }
        
        return (escapes.count % 2 == 1)
    }
    
}



// MARK: NSRange based

extension String {
    
    /// check if character at the location in UTF16 is escaped with backslash
    func isCharacterEscaped(at location: Int) -> Bool {
        
        guard let locationIndex = String.UTF16Index(encodedOffset: location).samePosition(in: self) else { return false }
        
        return self.isCharacterEscaped(at: locationIndex)
    }
    
}
