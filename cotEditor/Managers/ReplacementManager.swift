//
//  ReplacementManager.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2017-03-18.
//
//  ---------------------------------------------------------------------------
//
//  © 2017-2018 1024jp
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

final class ReplacementManager: SettingFileManaging {
    
    typealias Setting = MultipleReplacement
    
    
    // MARK: Public Properties
    
    static let shared = ReplacementManager()
    
    
    // MARK: Setting File Managing Properties
    
    static let directoryName: String = "Replacements"
    let filePathExtensions: [String] = DocumentType.replacement.extensions
    let settingFileType: SettingFileType = .replacement
    
    private(set) var settingNames: [String] = []
    let bundledSettingNames: [String] = []
    var cachedSettings: [String: Setting] = [:]
    
    
    
    // MARK: -
    // MARK: Lifecycle
    
    private init() {
        
        self.checkUserSettings()
    }
    
    
    
    // MARK: Public Methods
    
    /// save setting file
    func save(setting: Setting, name: String, completionHandler: @escaping (() -> Void) = {}) throws {
        
        // create directory to save in user domain if not yet exist
        try self.prepareUserSettingDirectory()
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        if #available(macOS 10.13, *) {
            encoder.outputFormatting.formUnion(.sortedKeys)
        }
        
        let data = try encoder.encode(setting)
        let fileURL = self.preparedURLForUserSetting(name: name)
        
        try data.write(to: fileURL, options: .atomic)
        
        self.cachedSettings[name] = setting
        
        self.updateCache { [weak self] in
            self?.notifySettingUpdate(oldName: name, newName: name)
            
            completionHandler()
        }
    }
    
    
    /// create a new untitled setting
    func createUntitledSetting(completionHandler: @escaping ((_ settingName: String) -> Void) = { _ in }) throws {
        
        let name = self.savableSettingName(for: "Untitled".localized)
        
        try self.save(setting: MultipleReplacement(), name: name) {
            completionHandler(name)
        }
    }
    
    
    
    // MARK: Setting File Managing
    
    /// load setting from the file at given URL
    func loadSetting(at fileURL: URL) throws -> Setting {
        
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: fileURL)
        
        return try decoder.decode(MultipleReplacement.self, from: data)
    }
    
    
    /// load settings in the user domain
    func checkUserSettings() {
        
        // get user setting names if exists
        self.settingNames = self.userSettingFileURLs
            .filter { (try? self.loadSetting(at: $0)) != nil }  // just try loading but not store
            .map { self.settingName(from: $0) }
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }
    
}
