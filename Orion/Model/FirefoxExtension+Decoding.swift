//
//  FirefoxExtension+Decoding.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Foundation
import ZIPFoundation

extension FirefoxExtension {

    /// Decodes a `manifest.json` into a ``FirefoxExtension``
    /// - Parameter manifestURL: The URL of the `manifest.json`
    /// - Returns: The firefox extension, or nil if unsuccessful
    public static func decodeFromManifest(manifestURL: URL) -> FirefoxExtension? {
        guard let contents = try? Data(contentsOf: manifestURL) else {
            print("Could not find manifest.json")
            return nil
        }

        guard let json = try? JSONSerialization.jsonObject(with: contents) as? [String: Any] else {
            print("Could not decode XPI")
            return nil
        }

        guard let author: String = json["author"] as? String,
              let name: String = json["name"] as? String,
              let description: String = json["description"] as? String,
              let optionsUIPage: String = (json["options_ui"] as? [String: Any])?["page"] as? String,
              let permissions: [String] = json["permissions"] as? [String] else {
            print("Could not decode")
            return nil
        }

        guard let iconsRaw = json["icons"] as? [String: String] else { return nil }
        var icons = [Int: String]()
        for (key, value) in iconsRaw {
            guard let size = Int(key) else {
                print("Could not get icon size")
                return nil
            }
            icons[size] = value
        }

        let ffExtension = FirefoxExtension(author: author,
                                           icons: icons,
                                           name: name,
                                           path: manifestURL.deletingLastPathComponent(),
                                           description: description,
                                           optionsUIPage: optionsUIPage,
                                           permissions: permissions)

        return ffExtension
    }

    /// Unzips a firefox extension XPI file
    /// - Parameters:
    ///   - url: the url of the XPI file
    ///   - deleteOnSuccess: If the XPI should be deleted upon successful unzipping (true by default)
    ///   - deleteOnFail: If the XPI should be deleted upon unsuccessful unzipping (false by default)
    /// - Returns: The URL representing a directory produced by unzipping the XPI file, or nil if unsuccessful
    public static func unzipXPI(url: URL,
                                deleteOnSuccess: Bool = true,
                                deleteOnFail: Bool = false) -> URL? {
        guard url.description.hasSuffix(".xpi") else { return nil }
        var filename = url.lastPathComponent
        // remove the trailing .xpi
        filename = String(filename.dropLast(4))
        let unzippedFilePath = url.deletingLastPathComponent().appending(component: filename)
        let fileManager = FileManager.default
        do {
            // unzip the item, then delete the original
            try fileManager.unzipItem(at: url, to: unzippedFilePath)
            if deleteOnSuccess {
                try fileManager.removeItem(at: url)
            }
        } catch {
            print("Unzipping failed with error \(error.localizedDescription)")
            if deleteOnFail {
                try? fileManager.removeItem(at: url)
            }
            return nil
        }

        return unzippedFilePath
    }
}
