//
//  CopyFile.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 1/4/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation


struct CopyFile: Codable {
    let filename: String
    let destination: String
    let renameFileToProjectName: Bool
}

extension CopyFile {
    
    /// Returns (new) filename 
    func copy(projectName: String?, projectDirectory: URL) throws -> String {
        
        guard let source = Bundle.main.url(forResource: filename, withExtension: nil) else {
            throw CompositeError.fileNotFound(filename)
        }
        
        // Rename file to project name
        let newFilename: String
        if let projectName = projectName, renameFileToProjectName == true {
            let ext = (filename as NSString).pathExtension
            newFilename = projectName + "." + ext
        } else {
            newFilename = filename
        }
        
        // Copy file
        let destinationURL = projectDirectory.appendingPathComponent(destination).appendingPathComponent(newFilename)
        try FileManager.default.copyItem(at: source, to: destinationURL)
        
        // Open file and replace all instances of <#__project_name#> with the project name
        if let projectName = projectName {
            let content = try String(contentsOf: destinationURL)
            let updatedContent = content.replaceOccurrencesOfProjectName(with: projectName)
            try updatedContent.write(to: destinationURL, atomically: true, encoding: .utf8)
        }
        
        return newFilename
    }

}

