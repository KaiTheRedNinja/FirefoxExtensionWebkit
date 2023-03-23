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

    var extensions: [FirefoxExtension] = []

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
        guard let ffExtension = FirefoxExtension.decodeFromManifest(manifestURL: manifestURL) else {
            print("Could not load extension")
            return
        }

        // TODO: do smth with the extension
        extensions.append(ffExtension)
    }

    func loadExtensions() {
        let fileManager = FileManager.default
        let extensionsDirectory = fileManager.getDocumentsDirectory().appending(component: "extensions/")
        guard let extensions = try? fileManager.contentsOfDirectory(atPath: extensionsDirectory.path) else {
            print("Could not get extensions")
            return
        }
        for extensionName in extensions {
            loadExtension(extensionDirectory: extensionsDirectory.appending(component: extensionName))
        }
    }
}
