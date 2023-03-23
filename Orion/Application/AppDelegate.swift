//
//  AppDelegate.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        let fileManager = FileManager.default
        var url = fileManager.getDocumentsDirectory().appending(component: "extensions/")
        // ensure the extensions directory exists
        if !fileManager.exists(file: url.description) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
