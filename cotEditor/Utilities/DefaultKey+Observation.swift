//
//  DefaultKey+Observation.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2018-12-25.
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

extension UserDefaults {
    
    func observe<Value>(key: DefaultKey<Value>, options: NSKeyValueObservingOptions = [], changeHandler: @escaping (UserDefaultsObservation.Change<Value>) -> Void) -> UserDefaultsObservation {
        
        let observation = UserDefaultsObservation(object: self, key: key.rawValue) { (change) in
            
            let typedChange = UserDefaultsObservation.Change(kind: change.kind,
                                                             new: change.new as? Value,
                                                             old: change.old as? Value,
                                                             indexes: change.indexes,
                                                             isPrior: change.isPrior)
            
            changeHandler(typedChange)
        }
        observation.startObservation(options)
        
        return observation
    }
    
    
    func observe(keys: [DefaultKeys], options: NSKeyValueObservingOptions = [], changeHandler: @escaping (DefaultKeys, UserDefaultsObservation.Change<Any>) -> Void) -> [UserDefaultsObservation] {
        
        let observations = keys.map { key in
            UserDefaultsObservation(object: self, key: key.rawValue) { changeHandler(key, $0) }
        }
        observations.forEach { $0.startObservation(options) }
        
        return observations
    }
    
}



final class UserDefaultsObservation: NSObject {
    
    struct Change<Value> {
        
        var kind: NSKeyValueChange
        var new: Value?
        var old: Value?
        var indexes: IndexSet?
        var isPrior: Bool
    }
    
    
    
    // MARK: Private Properties
    
    private weak var object: UserDefaults?
    private let changeHandler: (Change<Any>) -> Void
    private let key: String
    
    
    
    // MARK: -
    // MARK: Lifecycle
    
    init(object: UserDefaults, key: String, changeHandler: @escaping (Change<Any>) -> Void) {
        
        self.object = object
        self.key = key
        self.changeHandler = changeHandler
    }
    
    
    deinit {
        self.object?.removeObserver(self, forKeyPath: self.key, context: nil)
    }
    
    
    
    // MARK: KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        guard
            keyPath == self.key,
            let change = change,
            object as? NSObject == self.object
            else { return }
        
        let typedChange = Change(kind: NSKeyValueChange(rawValue: change[.kindKey] as! UInt)!,
                                 new: change[.newKey],
                                 old: change[.oldKey],
                                 indexes: change[.indexesKey] as! IndexSet?,
                                 isPrior: change[.notificationIsPriorKey] as? Bool ?? false)
        
        self.changeHandler(typedChange)
    }
    
    
    
    // MARK: Public Methods
    
    /// invalidate
    func invalidate() {
        
        self.object?.removeObserver(self, forKeyPath: self.key, context: nil)
        self.object = nil
    }
    
    
    // MARK: Private Methods
    
    fileprivate func startObservation(_ options: NSKeyValueObservingOptions) {
        
        self.object?.addObserver(self, forKeyPath: self.key, options: options, context: nil)
    }
    
}
