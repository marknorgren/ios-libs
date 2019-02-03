#!/usr/bin/env xcrun swift
//
//  main.swift
//  markdown-generator
//
//  Created by Mark Norgren on 2/2/19.
//  Copyright © 2019 Marked Systems. All rights reserved.
//


import Foundation

var jsonFilename: String?


struct LibraryList: Codable {
    var sections: [Section]
}

struct Section: Codable {
    var name: String
    var libraries: [Library]
}

struct Library: Codable {
    var githubPath: String
    var name: String
}

private func getJSONFilenameFromArg() {
    guard CommandLine.arguments.count == 2 else {
            print("Usage: main.swift [jsonFilename]")
            exit(1)
    }
    jsonFilename = CommandLine.arguments[1]
}


private func getScriptWorkingPath() -> String {
    let path = FileManager.default.currentDirectoryPath
    print("script run from:\n" + path)
    return path
}


private func getLibraryListFromFile(named: String, atPath path: String) -> LibraryList? {
    let pathURL = URL(fileURLWithPath: path, isDirectory: true)
    let fileURL = URL(fileURLWithPath: named, relativeTo: pathURL)
        do {
            let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            return try JSONDecoder().decode(LibraryList.self, from: data)
        } catch {
            print("getJSONFile Error: \(error)")
            exit(1)
        }
    print("Error with file path")
    exit(1)
}

getJSONFilenameFromArg()
guard let jsonFilename = jsonFilename else {
    print("Filename not set.")
    exit(1)
}
print("Opening \(jsonFilename)")

let path = getScriptWorkingPath()
var libList = getLibraryListFromFile(named: jsonFilename, atPath: path)

print(libList.debugDescription)



var markdownTemplate = """
    # iOS Libs

    """

guard let sections = libList?.sections else {
    print("No sections.")
    exit(1)
}
for section in sections {
    let line = "\n## \(section.name)\n\n"
    markdownTemplate.append(line)
    for library in section.libraries {
        let line = """
          * [\(library.name)](https://github.com\(library.githubPath))
            * ![GitHub stars](https://img.shields.io/github/stars\(library.githubPath).svg?style=social)\t
              ![GitHub release](https://img.shields.io/github/release\(library.githubPath).svg?style=social)\t
              ![codecov](https://img.shields.io/codecov/c/github\(library.githubPath).svg?style=social)\t
              ![GitHub release](https://img.shields.io/cocoapods/p/\(library.name).svg?style=social)\t

        """

        markdownTemplate.append(line)
    }
}

print(markdownTemplate)



