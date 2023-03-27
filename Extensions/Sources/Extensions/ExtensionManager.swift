//
//  ExtensionManager.swift
//  Orion
//
//  Created by Kai Quan Tay on 23/3/23.
//

import Cocoa
import Combine

public class ExtensionManager {
    /// The shared instance of `ExtensionManager`
    public static var shared: ExtensionManager = .init()
    private init() { loadExtensions() }

    /// An array of ``FirefoxExtension``s representing the extensions
    @Published
    public var extensions: [FirefoxExtension] = []

    /// Loads an XPI firefox extension
    public func loadXPI(url: URL) {
        guard let unzippedFilePath = FirefoxExtension.unzipXPI(url: url, deleteOnFail: true) else {
            print("Could not unzip XPI")
            return
        }
        loadExtension(extensionDirectory: unzippedFilePath)
    }

    public func loadExtension(extensionDirectory: URL) {
        let manifestURL = extensionDirectory.appendingPathComponent("manifest.json")
        guard let ffExtension = FirefoxExtension.decodeFromManifest(manifestURL: manifestURL) else {
            print("Could not load extension")
            return
        }

        // TODO: do smth with the extension
        extensions.append(ffExtension)
    }

    public func loadExtensions() {
        let fileManager = FileManager.default
        let extensionsDirectory = fileManager.getDocumentsDirectory().appendingPathComponent("extensions/")
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

    public func getToolbarIdentifiers() -> [NSToolbarItem.Identifier] {
        print("Getting toolbar identifiers from \(extensions.count) extensions")
        return extensions.map({ $0.toolbarItem })
    }
}
