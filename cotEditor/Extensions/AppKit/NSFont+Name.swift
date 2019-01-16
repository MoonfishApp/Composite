//
//  NSFont+SystemFont.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2018-11-05.
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

import AppKit.NSFont

extension NSFont {
    
    enum Name: String {
        
        case lucidaGrande = "LucidaGrande"
        case menlo = "Menlo"
        case avenirNextCondensed = "AvenirNextCondensed"
        case hiraginoSans = "HiraginoSans"
    }
    
    
    convenience init?(named name: Name, weight: Weight = .regular, size: CGFloat) {
        
        guard let postScriptName = name.postScriptName(weight: weight) else { return nil }
        
        self.init(name: postScriptName, size: size)
    }
    
    
    /// return the font used for line number views, in the specified size.
    static func lineNumberFont(ofSize size: CGFloat = 0, weight: NSFont.Weight = .regular) -> NSFont {
        
        return NSFont(named: .avenirNextCondensed, weight: weight, size: size)
            ?? .monospacedDigitSystemFont(ofSize: size, weight: weight)
    }
    
    
    /// Core Graphics font object corresponding to the font
    var cgFont: CGFont {
        
        return CTFontCopyGraphicsFont(self, nil)
    }
    
}



private extension NSFont.Name {
    
    func postScriptName(weight: NSFont.Weight) -> String? {
        
        guard let weightName = self.weightName(of: weight) else { return nil }
        guard !weightName.isEmpty else { return self.rawValue }
        
        return self.rawValue + "-" + weightName
    }
    
    
    private func weightName(of weight: NSFont.Weight) -> String? {
        
        switch self {
        case .lucidaGrande:
            switch weight {
            case .regular: return ""
            case .bold: return "Bold"
            default: return nil
            }
            
        case .menlo:
            switch weight {
            case .regular: return "Regular"
            case .bold: return "Bold"
            default: return nil
            }
            
        case .avenirNextCondensed:
            switch weight {
            case .ultraLight: return "UltraLight"
            case .regular: return "Regular"
            case .medium: return "Medium"
            case .semibold: return "DemiBold"
            case .bold: return "Bold"
            case .heavy: return "Heavy"
            default: return nil
            }
            
        case .hiraginoSans:
            switch weight {
            case .ultraLight: return "W0"
            case .thin: return "W1"
            case .light: return "W2"
            case .regular: return "W3"
            case .medium: return "W4"
            case .semibold: return "W5"
            case .bold: return "W6"
            case .heavy: return "W7"
            case .black: return "W8"
            default: return nil
            }
        }
    }
    
}
