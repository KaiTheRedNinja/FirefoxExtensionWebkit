//
//  ExtensionManager.swift
//  Orion
//
//  Created by Kai Quan Tay on 23/3/23.
//

import Cocoa
import Combine

class ExtensionManager {
    static var shared: ExtensionManager = .init()
    private init() {
        loadExtensions()
    }

    @Published
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
        guard let extensions = try? fileManager.contentsOfDirectory(at: extensionsDirectory,
                                                                    includingPropertiesForKeys: [.isDirectoryKey])
        else {
            print("Could not get extensions")
            return
        }
        for extensionURL in extensions where extensionURL.hasDirectoryPath {
            loadExtension(extensionDirectory: extensionURL)
        }
    }

    func getToolbarIdentifiers() -> [NSToolbarItem.Identifier] {
        print("Getting toolbar identifiers from \(extensions.count) extensions")
        return extensions.map({ $0.toolbarItem })
    }
}
