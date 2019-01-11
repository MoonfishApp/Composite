//
//  DependencyFrameworkViewModel.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/21/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

class DependencyFrameworkViewModel {

    private let framework: DependencyFramework
    
    private (set) var name: String
    
    var version: String {
        for dependency in dependencies {
            if dependency.isFrameworkVersion == true {
                return dependency.version
            }
        }
        return ""
    }
    
    var displayName: String { return state.display(name: framework.name) }
    
    let projectUrl: String
    
    let documentationUrl: String
    
    var description: String { return framework.description }
    
    let dependencies: [DependencyViewModel]
    
    var state: DependencyState {
        
        if dependencies.isEmpty { return .unknown }
        
        // Platform installing
        if dependencies.filter({ $0.state == .installing }).isEmpty == false {
            return .installing
        }
        
        // All required dependencies are up to date
        if dependencies.filter({ $0.state == .uptodate && $0.required == true }).count == dependencies.filter({ $0.required == true }).count {
            return .uptodate
        }
        
        //            print(frameworks.filter({ $0.state == .notInstalled && $0.required == true }))
        // Not all required dependencies are installed
        if dependencies.filter({ $0.state == .notInstalled && $0.required == true }).isEmpty == false {
            return .notInstalled
        }
        
        // Not all required dependencies are up to date
        if dependencies.filter({ $0.state == .outdated && $0.required == true }).isEmpty == false {
            return .outdated
        }
        
        return .unknown
    }
    
    init(_ framework: DependencyFramework) {
        self.framework = framework
        name = framework.name
        projectUrl = framework.projectUrl
        documentationUrl = framework.documentationUrl
        dependencies = framework.dependencies.map { DependencyViewModel($0) }
    }
}
