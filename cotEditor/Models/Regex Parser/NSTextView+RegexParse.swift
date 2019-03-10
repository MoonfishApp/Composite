//
//  NSTextView+RegexParse.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2018-12-24.
//
//  ---------------------------------------------------------------------------
//
//  © 2018 1024jp
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

import AppKit

extension NSTextView {
    
    /// Invalidate content string as a reguler expression pattern and highlight them.
    ///
    /// - Parameters:
    ///   - mode: Parse mode of reguler expression.
    ///   - enabled: If false, just remove current highlight, otherwise parse and highlight.
    func highlightAsRegularExpressionPattern(mode: RegularExpressionParseMode, enabled: Bool = true) {
        
        assert(Thread.isMainThread)
        
        guard let layoutManager = self.layoutManager else { return assertionFailure() }
        
        // clear the last highlight anyway
        layoutManager.removeTemporaryAttribute(.foregroundColor, forCharacterRange: self.string.nsRange)
        
        guard enabled else { return }
        
        // validate regex pattern
        switch mode {
        case .search:
            guard (try? NSRegularExpression(pattern: self.string)) != nil else { return }
        case .replacement:
            break
        }
        
        // highlight
        for type in RegularExpressionSyntaxType.priority.reversed() {
            for range in type.ranges(in: string, mode: mode) {
                layoutManager.addTemporaryAttribute(.foregroundColor, value: type.color, forCharacterRange: range)
            }
        }
    }
    
}
