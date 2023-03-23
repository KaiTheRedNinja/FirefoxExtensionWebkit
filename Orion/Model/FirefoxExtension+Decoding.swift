//
//  FirefoxExtension+Decoding.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Foundation
import ZIPFoundation

extension FirefoxExtension {
    static func decodeFromXPI(url: URL) {
        guard let unzippedFilePath = unzipXPI(url: url),
              let contents = try? Data(contentsOf: unzippedFilePath.appending(component: "manifest.json")) else {
            print("Could not find manifest.json")
            return
        }

        guard let json = try? JSONSerialization.jsonObject(with: contents) as? [String: Any] else {
            print("Could not decode XPI")
            return
        }

        guard let author: String = json["author"] as? String,
              let name: String = json["name"] as? String,
              let description: String = json["description"] as? String,
              let optionsUIPage: String = (json["options_ui"] as? [String: Any])?["page"] as? String,
              let permissions: [String] = json["permissions"] as? [String] else {
            print("Could not decode")
            return
        }

        guard let iconsRaw = json["icons"] as? [String: String] else { return }
        var icons = [Int: String]()
        for (key, value) in iconsRaw {
            guard let size = Int(key) else {
                print("Could not get icon size")
                return
            }
            icons[size] = value
        }

        let ffExtension = FirefoxExtension(author: author,
                                           icons: icons,
                                           name: name,
                                           description: description,
                                           optionsUIPage: optionsUIPage,
                                           permissions: permissions)

        print("Successfully created firefox extension")
    }

    private static func unzipXPI(url: URL) -> URL? {
        guard url.description.hasSuffix(".xpi") else { return nil }
        var filename = url.lastPathComponent
        // remove the trailing .xpi
        filename = String(filename.dropLast(4))
        let unzippedFilePath = url.deletingLastPathComponent().appending(component: filename)

        do {
            // unzip the item, then delete the original
            let fileManager = FileManager.default
            try fileManager.unzipItem(at: url, to: unzippedFilePath)
            try fileManager.removeItem(at: url)
        } catch {
            print("Unzipping failed with error \(error.localizedDescription)")
            return nil
        }

        return unzippedFilePath
    }
}
