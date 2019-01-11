//
//  Template.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/13/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation
import Cocoa

struct TemplateCategory: Codable {
    let category: String
    let command: String         // E.g. init (%..)
    let templates: [Template]?
}

struct Template: Codable {
    
    /// E.g. "Basic Token"
    let name: String
    
    /// E.g. "basictoken" (name used by Truffle)
    let templateName: String
    
    /// Verbose description of the template
    let description: String?
    
    /// Path to more info
    let moreInfoUrl: String
    
    /// E.g. ERC-20
    let standard: String
    
    /// Files to copy during instalation
    let copyFiles: [CopyFile]?
    
    /// File to open in editor by default. E.g. ["contracts", "TutorialToken.sol"]
    let openFile: String?
    
    /// Either initEmpty, initTemplate, or initExample
    let initType: InitType
    
    let detailViewType: String?
    
    let imageName: String
    
    var image: NSImage {
        let name = imageName.isEmpty ? "Doc" : imageName
        return NSImage(named: NSImage.Name(rawValue: name)) ?? NSImage()
    }
}

enum InitType: String, Codable {
    
    case initEmpty, initTemplate, initExample
    
    func commands(_ frameworkCommands: FrameworkCommands) -> FrameworkInit? {
        switch self {
        case .initEmpty:
            return frameworkCommands.commands.initEmpty
        case .initTemplate:
            return frameworkCommands.commands.initTemplate
        case .initExample:
            return frameworkCommands.commands.initExample
        }
    }
}
