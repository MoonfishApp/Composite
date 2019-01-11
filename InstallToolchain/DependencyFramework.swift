//
//  DependencyFramework.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/15/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation


/// Framework or toolchain
struct DependencyFramework: Codable {
    
    /// Name of the framework, e.g. Truffle or EtherLime
    let name: String
    
    /// Array of dependencies required to use the framework
    let dependencies: [Dependency]
    
    /// Text to display to user explaining what the framework is
    let description: String
    
    /// Framework project Github url
    let projectUrl: String
    
    /// Framework documation url
    let documentationUrl: String
    
    /// True if is this is the default framework for the platform
    let defaultFramework: Bool

    // TODO: Can we add a filter or regex or something that will scan and recognize an
    // existing project as a project created in this framework? E.g. to recognize if
    // a project was created by EtherLime or Truffle?
}
