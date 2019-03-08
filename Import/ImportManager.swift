//
//  ImportManager.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/7/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

final class ImportManager {
    
    let document: NSDocument
    
    init(document: NSDocument) {
        self.document = document
        
        // Search for frameworks that support the file extension of document
        
    }
}

// TODO: Can we add a filter or regex or something that will scan and recognize an
// existing project as a project created in this framework? E.g. to recognize if
// a project was created by EtherLime or Truffle?

