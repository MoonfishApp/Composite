//
//  NSViewController.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/14/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

extension NSViewController {
    
    func findViewControllers<T: NSViewController>(subclassOf: T.Type) -> [T] {
        
        return recursiveChildren.compactMap { $0 as? T }
    }
    
    var recursiveChildren: [NSViewController] {
        
        return children + children.flatMap { $0.recursiveChildren }
    }
}
