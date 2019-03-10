//
//  UnixScript.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2017-10-28.
//
//  ---------------------------------------------------------------------------
//
//  © 2004-2007 nakamuxu
//  © 2014-2018 1024jp
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

import Cocoa

final class UnixScript: Script {
    
    // MARK: Script Properties
    
    let descriptor: ScriptDescriptor
    
    
    
    // MARK: -
    // MARK: Lifecycle
    
    init(descriptor: ScriptDescriptor) {
        
        self.descriptor = descriptor
    }
    
    
    
    // MARK: Private Enum
    
    private enum OutputType: String, ScriptToken {
        
        case replaceSelection = "ReplaceSelection"
        case replaceAllText = "ReplaceAllText"
        case insertAfterSelection = "InsertAfterSelection"
        case appendToAllText = "AppendToAllText"
        case newDocument = "NewDocument"
        case pasteBoard = "Pasteboard"
        
        static var token = "CotEditorXOutput"
    }
    
    
    private enum InputType: String, ScriptToken {
        
        case selection = "Selection"
        case allText = "AllText"
        
        static var token = "CotEditorXInput"
    }
    
    
    
    // MARK: Script Methods
    
    /// run script
    ///
    /// - Throws: `ScriptFileError` or Error by `NSUserScriptTask`
    func run(completionHandler: (() -> Void)? = nil) throws {
        
        // check script file
        guard self.descriptor.url.isReachable else {
            throw ScriptFileError(kind: .existance, url: self.descriptor.url)
        }
        guard try self.descriptor.url.resourceValues(forKeys: [.isExecutableKey]).isExecutable ?? false else {
            throw ScriptFileError(kind: .permission, url: self.descriptor.url)
        }
        guard let script = self.content, !script.isEmpty else {
            throw ScriptFileError(kind: .read, url: self.descriptor.url)
        }
        
        // fetch target document
        weak var document = NSDocumentController.shared.currentDocument as? TextDocument
        
        // read input
        let input: String?
        if let inputType = InputType(scanning: script) {
            do {
                input = try self.readInputString(type: inputType, editor: document)
            } catch {
                writeToConsole(message: error.localizedDescription, scriptName: self.descriptor.name)
                return
            }
        } else {
            input = nil
        }
        
        // get output type
        let outputType = OutputType(scanning: script)
        
        // prepare file path as argument if available
        let arguments: [String] = [document?.fileURL?.path].compactMap { $0 }
        
        // create task
        let task = try NSUserUnixTask(url: self.descriptor.url)
        
        // set pipes
        let inPipe = Pipe()
        let outPipe = Pipe()
        let errPipe = Pipe()
        task.standardInput = inPipe.fileHandleForReading
        task.standardOutput = outPipe.fileHandleForWriting
        task.standardError = errPipe.fileHandleForWriting
        
        // set input data if available
        if let data = input?.data(using: .utf8) {
            inPipe.fileHandleForWriting.writeabilityHandler = { (handle: FileHandle) in
                // write input data chunk by chunk
                // -> to avoid freeze by a huge input data, whose length is more than 65,536 (2^16).
                for chunk in data.components(length: 65_536) {
                    handle.write(chunk)
                }
                handle.closeFile()
                
                // inPipe must avoid releasing before `writeabilityHandler` is invocated
                inPipe.fileHandleForWriting.writeabilityHandler = nil
            }
        }
        
        let scriptName = self.descriptor.name
        var isCancelled = false  // user cancel state
        
        // read output asynchronously for safe with huge output
        if let outputType = outputType {
            weak var observer: NSObjectProtocol?
            observer = NotificationCenter.default.addObserver(forName: .NSFileHandleReadToEndOfFileCompletion, object: outPipe.fileHandleForReading, queue: .main) { (note: Notification) in
                NotificationCenter.default.removeObserver(observer!)
                
                guard
                    !isCancelled,
                    let data = note.userInfo?[NSFileHandleNotificationDataItem] as? Data,
                    let output = String(data: data, encoding: .utf8)
                    else { return }
                
                do {
                    try UnixScript.applyOutput(output, editor: document, type: outputType)
                } catch {
                    writeToConsole(message: error.localizedDescription, scriptName: scriptName)
                }
            }
            outPipe.fileHandleForReading.readToEndOfFileInBackgroundAndNotify()
        }
        
        // execute
        task.execute(withArguments: arguments) { error in
            defer {
                completionHandler?()
            }
            
            // on user cancel
            if let error = error as? POSIXError, error.code == .ENOTBLK {
                isCancelled = true
                return
            }
            
            // put error message on the console
            let errorData = errPipe.fileHandleForReading.readDataToEndOfFile()
            if let message = String(data: errorData, encoding: .utf8), !message.isEmpty {
                writeToConsole(message: message, scriptName: scriptName)
            }
        }
    }
    
    
    // MARK: Private Methods
    
    /// read content of script file
    private lazy var content: String? = {
        
        guard let data = try? Data(contentsOf: self.descriptor.url) else { return nil }
        
        return EncodingManager.shared.defaultEncodings.lazy
            .compactMap { $0 }
            .compactMap { String(data: data, encoding: $0) }
            .first
    }()
    
    
    /// return document content conforming to the input type
    ///
    /// - Throws: `ScriptError`
    private func readInputString(type: InputType, editor: Editable?) throws -> String {
        
        guard let editor = editor else {
            throw ScriptError.noInputTarget
        }
        
        switch type {
        case .selection:
            return editor.selectedString
            
        case .allText:
            return editor.string
        }
    }
    
    
    /// apply results conforming to the output type to the frontmost document
    ///
    /// - Throws: `ScriptError`
    private static func applyOutput(_ output: String, editor: Editable?, type: OutputType) throws {
        
        if type == .pasteBoard {
            let pasteboard = NSPasteboard.general
            pasteboard.declareTypes([.string], owner: nil)
            guard pasteboard.setString(output, forType: .string) else {
                NSSound.beep()
                return
            }
            return
        }
        
        if type == .newDocument {
            let document = try NSDocumentController.shared.openUntitledDocumentAndDisplay(true) as! TextDocument
            document.insert(string: output)
            document.selectedRange = NSRange(location: 0, length: 0)
            return
        }
        
        guard let editor = editor else {
            throw ScriptError.noOutputTarget
        }
        
        DispatchQueue.main.async {
            switch type {
            case .replaceSelection:
                editor.insert(string: output)
                
            case .replaceAllText:
                editor.replaceAllString(with: output)
                
            case .insertAfterSelection:
                editor.insertAfterSelection(string: output)
                
            case .appendToAllText:
                editor.append(string: output)
                
            case .newDocument, .pasteBoard:
                assertionFailure()
            }
        }
    }
    
}




// MARK: - Error

private enum ScriptError: Error {
    
    case noInputTarget
    case noOutputTarget
    
    
    var localizedDescription: String {
        
        switch self {
        case .noInputTarget:
            return "No document to get input.".localized
        case .noOutputTarget:
            return "No document to put output.".localized
        }
    }
    
}




// MARK: - ScriptToken

private protocol ScriptToken {
    
    static var token: String { get }
}


private extension ScriptToken where Self: RawRepresentable, Self.RawValue == String {
    
    /// read type from script
    init?(scanning script: String) {
        
        let pattern = "%%%\\{" + Self.token + "=" + "(.+)" + "\\}%%%"
        let regex = try! NSRegularExpression(pattern: pattern)
        
        guard let result = regex.firstMatch(in: script, range: script.nsRange) else { return nil }
        
        let type = (script as NSString).substring(with: result.range(at: 1))
        
        self.init(rawValue: type)
    }
    
}
