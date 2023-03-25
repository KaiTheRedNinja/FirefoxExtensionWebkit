//
//  TopSitesAPI.swift
//  Orion
//
//  Created by Kai Quan Tay on 23/3/23.
//

import Foundation

enum TopSitesAPI {
    struct SiteData: Codable {
        var visitCount: Int
        var title: String
    }

    private static var topSites: [URL: SiteData] {
        get {
            do {
                let data = try Data(contentsOf: FileManager.default.getDocumentsDirectory()
                    .appending(component: "extensions/topSites.json"))
                return try JSONDecoder().decode([URL: SiteData].self, from: data)
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

    static func addSiteVisit(url: URL, title: String) {
        topSites[url] = .init(visitCount: (topSites[url]?.visitCount ?? 0) + 1,
                              title: title)
    }

    static func getTopSites(number: Int) -> [(URL, SiteData)] {
        let topSites = self.topSites
        var topInts = [(key: URL, value: SiteData)]()

        // runs in pretty much O(n) time
        var count = 0
        for (key, value) in topSites {
            if count < 10 {
                topInts.append((key, value))
                count += 1
            } else {
                let smallestTopInt = topInts.min { $0.value.visitCount < $1.value.visitCount }!
                if value.visitCount > smallestTopInt.value.visitCount {
                    topInts[topInts.firstIndex(where: {
                        $0.value.visitCount == smallestTopInt.value.visitCount
                    })!] = (key, value)
                }
            }
        }
        return topInts.sorted(by: { $0.value.visitCount > $1.value.visitCount })
    }
}
