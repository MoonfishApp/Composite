//
//  ImportDatasource.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/7/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

final class ImportDatasource: NSObject {
    
    var document: NSDocument? = nil {
        didSet {
            if let fileExtension = document?.fileURL?.pathExtension {
                self.fileExtension = fileExtension
                if let platforms = try? DependencyPlatformViewModel.loadPlatforms(forExtension: fileExtension) {
                    self.platforms = platforms
                }
            } else {
                self.fileExtension = nil
                self.platforms = nil
                print("No compatible platforms")
            }
        }
    }
    
    private (set) var platforms: [DependencyPlatformViewModel]? = nil
    
    private (set) var fileExtension: String? = nil

    // Called by Storyboard
    override init() {
    }
}

extension ImportDatasource: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? DependencyPlatformViewModel {
            return item.frameworks.count
        } else if item == nil {
            // Root
            return self.platforms?.count ?? 0
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
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        
        if let item = item as? DependencyPlatformViewModel {
            return item.name
        } else if let item = item as? DependencyFrameworkViewModel {
            return item.displayName
        } else {
            return "unknown"
        }
    }
    
//        func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
//
//        }
}
