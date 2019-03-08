//
//  ImportManager.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/7/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

final class ImportManager: NSObject {
    
    private let document: NSDocument
    
    private let platforms: [DependencyPlatformViewModel]
    
    init(document: NSDocument) throws {
    
        self.document = document
        
        // Search for frameworks that support the file extension of document
        platforms = try DependencyPlatformViewModel.loadPlatforms() //(forExtension: document.fileExtension)
        
    }
}

extension ImportManager: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? DependencyPlatformViewModel {
            return item.frameworks.count
        } else if item == nil {
            // Root
            return self.platforms.count
        } else {
            assertionFailure()
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? DependencyPlatformViewModel, item.frameworks.count > 0 {
            return true
        }
        return false
    }
    
    //    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    //
    //    }
}
