//
//  ExtensionManager.swift
//  Orion
//
//  Created by Kai Quan Tay on 23/3/23.
//

import Foundation

class ExtensionManager {
    static var shared: ExtensionManager = .init()
    private init() {}

    /// Loads an XPI firefox extension
    func loadXPI(url: URL) {
        guard let unzippedFilePath = FirefoxExtension.unzipXPI(url: url, deleteOnFail: true) else {
            print("Could not unzip XPI")
            return
        }
        loadExtension(extensionDirectory: unzippedFilePath)
    }

    func loadExtension(extensionDirectory: URL) {
        let manifestURL = extensionDirectory.appending(component: "manifest.json")
        print("Loading manifest \(manifestURL)")
        let ffExtension = FirefoxExtension.decodeFromManifest(manifestURL: manifestURL)

        // TODO: do smth with the extension
    }

    func loadExtensions() {
        let fileManager = FileManager.default
        let extensionsDirectory = fileManager.getDocumentsDirectory().appending(component: "extensions/")
        print("Directory: \(extensionsDirectory)")
        guard let extensions = try? fileManager.contentsOfDirectory(atPath: extensionsDirectory.path) else {
            print("Could not get extensions")
            return
        }
        for extensionName in extensions {
            print("Loading \(extensionName)")
            loadExtension(extensionDirectory: extensionsDirectory.appending(component: extensionName))
        }
    }
}
