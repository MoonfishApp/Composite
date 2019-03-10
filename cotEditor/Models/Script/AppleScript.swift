//
//  AppleScript.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2017-10-28.
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

final class AppleScript: Script {
    
    // MARK: Script Properties
    
    let descriptor: ScriptDescriptor
    
    
    
    // MARK: -
    // MARK: Lifecycle
    
    init(descriptor: ScriptDescriptor) {
        
        self.descriptor = descriptor
    }
    
    
    
    // MARK: Script Methods
    
    /// run script
    ///
    /// - Throws: Error by `NSUserScriptTask`
    func run(completionHandler: (() -> Void)? = nil) throws {
        
        try self.run(withAppleEvent: nil, completionHandler: completionHandler)
    }
    
    
    /// Execute the AppleScript script by sending it the given Apple event.
    ///
    /// Any script errors will be written to the console panel.
    ///
    /// - Parameter event: The apple event.
    ///
    /// - Throws: `ScriptFileError` and any errors by `NSUserScriptTask.init(url:)`
    func run(withAppleEvent event: NSAppleEventDescriptor?, completionHandler: (() -> Void)? = nil) throws {
        
        guard self.descriptor.url.isReachable else {
            throw ScriptFileError(kind: .existance, url: self.descriptor.url)
        }
        
        let task = try NSUserAppleScriptTask(url: self.descriptor.url)
        let scriptName = self.descriptor.name
        
        task.execute(withAppleEvent: event) { (result: NSAppleEventDescriptor?, error: Error?) in
            if let error = error {
                writeToConsole(message: error.localizedDescription, scriptName: scriptName)
            }
            
            completionHandler?()
        }
    }
    
}
