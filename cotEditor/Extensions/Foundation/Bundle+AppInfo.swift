//
//  Bundle+AppInfo.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2018-10-13.
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

import Foundation

extension Bundle {
    
    /// application name
    var bundleName: String {
        
        return self.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
    }
    
    
    /// human-friendly version expression (semantic versioning)
    var shortVersion: String {
        
        return self.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    
    /// build number
    var bundleVersion: String {
        
        return self.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    
    /// help book name
    var helpBookName: String? {
        
        return self.object(forInfoDictionaryKey: "CFBundleHelpBookName") as? String
    }
    
    
    /// Is the running app a pre-release version?
    var isPrerelease: Bool {
        
        let digitSet = CharacterSet(charactersIn: "0123456789.")
        
        // pre-release version contains non-digit letter
        return (self.shortVersion.rangeOfCharacter(from: digitSet.inverted) != nil)
    }
    
}
