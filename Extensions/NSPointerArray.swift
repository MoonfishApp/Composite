//
//  NSPointerArray.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 2/25/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

extension NSPointerArray {
    func addObject(_ object: AnyObject?) {
        
        guard let strongObject = object else { return }
        
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        addPointer(pointer)
    }
    
    func addObjects(_ objects: [AnyObject?]) {
        
        _ = objects.compactMap{ addObject($0) }
    }
    
    func insertObject(_ object: AnyObject?, at index: Int) {
        
        guard index < count, let strongObject = object else { return }
        
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        insertPointer(pointer, at: index)
    }
    
    func replaceObject(at index: Int, withObject object: AnyObject?) {
        
        guard index < count, let strongObject = object else { return }
        
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        replacePointer(at: index, withPointer: pointer)
    }
    
    func object(at index: Int) -> AnyObject? {
        
        guard index < count, let pointer = self.pointer(at: index) else { return nil }
        return Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue()
    }
    
    func removeObject(at index: Int) {
        
        guard index < count else { return }
        
        removePointer(at: index)
    }
}
