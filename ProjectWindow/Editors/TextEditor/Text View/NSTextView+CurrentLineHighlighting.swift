//
//  NSTextView+CurrentLineHighlighting.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2018-08-18.
//
//  ---------------------------------------------------------------------------
//
//  © 2018 CotEditor Project
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

protocol CurrentLineHighlighting: AnyObject {
    
    var needsUpdateLineHighlight: Bool { get set }
    var lineHighLightRect: NSRect? { get set }
    var lineHighLightColor: NSColor? { get }
}



extension CurrentLineHighlighting where Self: NSTextView {
    
    // MARK: Public Methods
    
    /// draw current line highlight
    func drawCurrentLine(in dirtyRect: NSRect) {
        
        if self.needsUpdateLineHighlight {
            self.lineHighLightRect = self.calcurateLineHighLightRect()
            self.needsUpdateLineHighlight = false
        }
        
        guard
            let rect = self.lineHighLightRect,
            let color = self.lineHighLightColor,
            rect.intersects(dirtyRect)
            else { return }
        
        // draw highlight
        NSGraphicsContext.saveGraphicsState()
        
        color.setFill()
        rect.fill()
        
        NSGraphicsContext.restoreGraphicsState()
    }
    
    
    
    // MARK: Private Methods
    
    /// update lineHighLightRect
    private func calcurateLineHighLightRect() -> NSRect {
        
        let lineRange = (self.string as NSString).lineRange(for: self.selectedRange, excludingLastLineEnding: true)
        
        guard
            let textContainer = self.textContainer,
            let rect = self.boundingRect(for: lineRange)
            else { assertionFailure(); return .zero }
        
        return NSRect(x: 0,
                      y: rect.minY,
                      width: textContainer.size.width,
                      height: rect.height)
            .insetBy(dx: textContainer.lineFragmentPadding, dy: 0)
            .integral
    }
    
}
