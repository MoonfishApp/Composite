//
//  EditWindowRestoration.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 10/15/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class EditWindowRestoration: NSObject, NSWindowRestoration {
    
    // See https://developer.apple.com/videos/play/wwdc2016/239/ @ 36:00
    static func restoreWindow(withIdentifier identifier: NSUserInterfaceItemIdentifier, state: NSCoder, completionHandler: @escaping (NSWindow?, Error?) -> Void) {
        
    }
}
