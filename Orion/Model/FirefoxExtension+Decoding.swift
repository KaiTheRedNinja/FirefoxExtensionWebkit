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
        guard url.description.hasSuffix(".xpi") else { return }
        var filename = url.lastPathComponent
        // remove the trailing .xpi
        filename = String(filename.dropLast(4))
        let unzippedFilePath = url.deletingLastPathComponent().appending(component: filename)

        do {
            // unzip the item
            try FileManager.default.unzipItem(at: url, to: unzippedFilePath)
        } catch {
            print("Unzipping failed with error \(error.localizedDescription)")
        }

        // TODO: Decode

//        guard let contents = try? Data(contentsOf:
//                                        unzippedFilePath.appending(component: "test")) as NSData
//        else { return }

//        guard let json = try? JSONSerialization.jsonObject(with: contents) as? [String: Any] else {
//            print("Could not decode XPI")
//            return
//        }
    }
}
