//
//  DefaultInitializable.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2018-02-14.
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

protocol DefaultInitializable {
    
    static var defaultValue: Self { get }
}


extension DefaultInitializable where Self: RawRepresentable {
    
    /// non-optional initializer by setting the defaultValue if failed
    init(_ rawValue: RawValue?) {
        
        self = Self(rawValue: rawValue ?? Self.defaultValue.rawValue) ?? Self.defaultValue
    }
    
}
