//
//  Script.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2016-10-22.
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

protocol Script: AnyObject {
    
    // MARK: Properties
    
    /// A script descriptor the receiver was created from.
    var descriptor: ScriptDescriptor { get }
    
    
    // MARK: Methods
    
    /// Execute the script with the default way.
    func run(completionHandler: (() -> Void)?) throws
    
    
    /// Execute the script by sending it the given Apple event.
    ///
    /// Events the script cannot handle must be ignored with no errors.
    func run(withAppleEvent event: NSAppleEventDescriptor?, completionHandler: (() -> Void)?) throws
    
}



extension Script {
    
    func run(withAppleEvent event: NSAppleEventDescriptor?, completionHandler: (() -> Void)? = nil) throws {
        
        // ignore every request with an event by default
    }
    
}




// MARK: - Error

struct ScriptFileError: LocalizedError {
    
    enum ErrorKind {
        case existance
        case read
        case open
        case permission
    }
    
    let kind: ErrorKind
    let url: URL
    
    
    var errorDescription: String? {
        
        switch self.kind {
        case .existance:
            return String(format: "The script “%@” does not exist.".localized, self.url.lastPathComponent)
        case .read:
            return String(format: "The script “%@” couldn’t be read.".localized, self.url.lastPathComponent)
        case .open:
            return String(format: "The script file “%@” couldn’t be opened.".localized, self.url.path)
        case .permission:
            return String(format: "The script “%@” can’t be executed because you don’t have the execute permission.".localized, self.url.lastPathComponent)
        }
    }
    
    
    var recoverySuggestion: String? {
        
        switch self.kind {
        case .permission:
            return "Check permission of the script file.".localized
        default:
            return "Check the script file.".localized
        }
    }
    
}



// MARK: - Private Functions

func writeToConsole(message: String, scriptName: String) {
    
    let log = Console.Log(message: message, title: scriptName)
    
    DispatchQueue.main.async {
        Console.shared.panelController.showWindow(nil)
        Console.shared.append(log: log)
    }
}
