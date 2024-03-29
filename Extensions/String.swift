//
//  String.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/5/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

extension String {
    
    func capitalizedFirstChar() -> String {
        return self.prefix(1).capitalized + self.dropFirst()
    }
}

// Source: https://github.com/DragonCherry/VersionCompare
extension String {
    
    /// Inner comparison utility to handle same versions with different length. (Ex: "1.0.0" & "1.0")
    private func compare(toVersion targetVersion: String) -> ComparisonResult {
        
        let versionDelimiter = "."
        var result: ComparisonResult = .orderedSame
        var versionComponents = components(separatedBy: versionDelimiter)
        var targetComponents = targetVersion.components(separatedBy: versionDelimiter)
        let spareCount = versionComponents.count - targetComponents.count
        
        if spareCount == 0 {
            result = compare(targetVersion, options: .numeric)
        } else {
            let spareZeros = repeatElement("0", count: abs(spareCount))
            if spareCount > 0 {
                targetComponents.append(contentsOf: spareZeros)
            } else {
                versionComponents.append(contentsOf: spareZeros)
            }
            result = versionComponents.joined(separator: versionDelimiter)
                .compare(targetComponents.joined(separator: versionDelimiter), options: .numeric)
        }
        return result
    }
    
    public func isVersion(equalTo targetVersion: String) -> Bool { return compare(toVersion: targetVersion) == .orderedSame }
    public func isVersion(greaterThan targetVersion: String) -> Bool { return compare(toVersion: targetVersion) == .orderedDescending }
    public func isVersion(greaterThanOrEqualTo targetVersion: String) -> Bool { return compare(toVersion: targetVersion) != .orderedAscending }
    public func isVersion(lessThan targetVersion: String) -> Bool { return compare(toVersion: targetVersion) == .orderedAscending }
    public func isVersion(lessThanOrEqualTo targetVersion: String) -> Bool { return compare(toVersion: targetVersion) != .orderedDescending }
    
    
    /// Replaces occurrences of <#__project_name#> and $(PROJECT_NAME) in string with the project name
    ///
    /// - Parameter with: project name
    /// - Returns: New string with projectname placeholders replaced by project name
    public func replaceOccurrencesOfProjectName(with name: String) -> String {

        //        let name = name.replacingOccurrences(of: " ", with: "-")
        return replacingOccurrences(of: "<#__project_name#>", with: name).replacingOccurrences(of: "$(PROJECT_NAME)", with: name)
    }
    
    public func replaceOccurrencesOfFileName(with name: String) -> String {
        
        return replacingOccurrences(of: "<#__file_name#>", with: name).replacingOccurrences(of: "$(FILE_NAME)", with: name)
    }
    
    /// Replaces occurences of <#__user_name#> and ($USER_NAME) in string with the
    /// user name as returned my MacOS (e.g. "John Appleseed")
    ///
    /// - Returns: New string with placeholders replaced by the user name
    public func replaceOccurrencesOfUserName() -> String {
        
        return replacingOccurrences(of:"<#__user_name#>", with: NSFullUserName()).replacingOccurrences(of: "$(USER_NAME)", with: NSFullUserName())
    }
    
    public func replaceOccurrencesDate() -> String {

        let date = Date().shortDate
        return replacingOccurrences(of:"<#__date#>", with: date).replacingOccurrences(of: "$(DATE)", with: date)
    }
    public var escapedSpaces: String {
 
        return replacingOccurrences(of: " ", with: "\\ ")
    }
}
