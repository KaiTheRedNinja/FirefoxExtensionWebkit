//
//  TopSitesAPI.swift
//  Orion
//
//  Created by Kai Quan Tay on 23/3/23.
//

import Foundation

enum TopSitesAPI {
    private static var topSites: [URL: Int] {
        get {
            do {
                let data = try Data(contentsOf: FileManager.default.getDocumentsDirectory()
                    .appending(component: "extensions/topSites.json"))
                return try JSONDecoder().decode([URL: Int].self, from: data)
            } catch {
                return [:]
            }
        }
        set {
            let filePath = FileManager.default.getDocumentsDirectory()
                .appending(component: "extensions/topSites.json")
            do {
                try JSONEncoder().encode(newValue).write(to: filePath)
                print("Saved to disk")
            } catch {
                print("Could not save \(newValue): \(error.localizedDescription)")
            }
        }
    }

    static func addSiteVisit(url: URL) {
        topSites[url] = (topSites[url] ?? 0) + 1
    }

    static func getTopSites(number: Int) -> [URL] {
        let topSites = self.topSites
        var topInts = [(key: URL, value: Int)]()

        // runs in pretty much O(n) time
        var count = 0
        for (key, value) in topSites {
            if count < 10 {
                topInts.append((key, value))
                count += 1
            } else {
                let smallestTopInt = topInts.min { $0.value < $1.value }!
                if value > smallestTopInt.value {
                    topInts[topInts.firstIndex(where: { $0.value == smallestTopInt.value })!] = (key, value)
                }
            }
        }
        return topInts.sorted(by: { $0.value > $1.value }).map { $0.key }
    }
}
