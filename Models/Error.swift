//
//  Error.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/16/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

enum CompositeError: Error {
    case fileNotFound(String)
    case directoryNotFound(String)
    case platformNotFound(String)
    case frameworkNotFound(String)
    case bashScriptFailed(String)
}
