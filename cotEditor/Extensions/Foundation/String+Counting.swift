//
//  String+Counting.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2014-05-04.
//
//  ---------------------------------------------------------------------------
//
//  © 2014-2019 1024jp
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

extension StringProtocol where Self.Index == String.Index {
    
    /// number of lines in the whole string ignoring the last new line character
    var numberOfLines: Int {
        
        return self.numberOfLines(in: self.startIndex..<self.endIndex, includingLastLineEnding: false)
    }
    
    
    /// count the number of lines at the character index (1-based).
    func lineNumber(at index: Self.Index) -> Int {
        
        guard !self.isEmpty, index > self.startIndex else { return 1 }
        
        return self.numberOfLines(in: self.startIndex..<index, includingLastLineEnding: true)
    }
    
    
    /// count the number of lines in the range
    func numberOfLines(in range: Range<String.Index>? = nil, includingLastLineEnding: Bool) -> Int {
        
        let range = range ?? self.startIndex..<self.endIndex
        
        guard !self.isEmpty, !range.isEmpty else { return 0 }
        
        var count = 0
        self.enumerateSubstrings(in: range, options: [.byLines, .substringNotRequired]) { (_, _, _, _) in
            count += 1
        }
        
        if includingLastLineEnding,
            let last = self[range].unicodeScalars.last,
            CharacterSet.newlines.contains(last)
        {
            count += 1
        }
        
        return count
    }
    
}



// MARK: NSRange based

extension String {
    
    /// count the number of lines at the character index (1-based).
    func lineNumber(at location: Int) -> Int {
        
        guard !self.isEmpty, location > 0 else { return 1 }
        
        return self.numberOfLines(in: NSRange(0..<location), includingLastLineEnding: true)
    }
    
    
    /// count the number of lines in the range
    func numberOfLines(in range: NSRange, includingLastLineEnding: Bool) -> Int {
        
        guard let characterRange = Range(range, in: self) else { return 0 }
        
        return self.numberOfLines(in: characterRange, includingLastLineEnding: includingLastLineEnding)
    }
    
}
