//
//  DependencyPlatformViewModel.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 1/9/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

class DependencyPlatformViewModel {
    
    let platform: Platform
    
    // URL path to more info, usually project site. E.g. https://ethereum.org
    let projectUrl: String
    
    // URL path to documenation, e.g. http://www.ethdocs.org/en/latest/
    let documentationUrl: String
    
    var name: String
    
    let frameworks: [DependencyFrameworkViewModel]
    
    
    init(platform: DependencyPlatform) {
        self.platform = platform.platform
        projectUrl = platform.projectUrl
        documentationUrl = platform.documentationUrl
        name = platform.name
        frameworks = platform.frameworks.map{ DependencyFrameworkViewModel($0) }
    }
    
    static func loadPlatforms() throws -> [DependencyPlatformViewModel] {        
        let platforms = try DependencyPlatform.loadPlatforms()
        return platforms.map { DependencyPlatformViewModel(platform: $0) }
    }
}
