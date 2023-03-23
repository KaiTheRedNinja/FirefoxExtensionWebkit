//
//  AppDelegate.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // load extensions
        ExtensionManager.shared.loadExtensions()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
