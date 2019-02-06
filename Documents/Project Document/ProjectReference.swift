//
//  ProjectReference.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 2/1/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

private struct SerializationKey {
    
    static let workDirectory = "workDirectory"
    static let projectFileURL = "projectFileURL"
}

class ProjectReference: NSObject { //}, NSCoding {
    
    /// E.g. ~/Projects/ProjectName
    @objc let workDirectory: String?
    
    // URL of project file
    @objc let projectFileURL: String?
    
    init(workDirectory: String?, projectFileURL: String?) {
        self.workDirectory = workDirectory
        self.projectFileURL = projectFileURL
        super.init()
    }
    
    convenience init(project: ProjectDocument) {
        self.init(workDirectory: project.workDirectory.path, projectFileURL: project.fileURL?.path)
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        self.workDirectory = aDecoder.decodeObject(forKey: SerializationKey.workDirectory) as? String
//        self.projectFileURL = aDecoder.decodeObject(forKey: SerializationKey.projectFileURL) as? String
//    }
//
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(self.workDirectory, forKey: SerializationKey.workDirectory)
//        aCoder.encode(self.projectFileURL, forKey: SerializationKey.projectFileURL)
//    }

}
