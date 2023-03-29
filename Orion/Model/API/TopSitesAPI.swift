//
//  TopSitesAPI.swift
//  Orion
//
//  Created by Kai Quan Tay on 23/3/23.
//

import Foundation

enum TopSitesAPI {
    /// A struct that contains information about a Top Site
    struct SiteData: Codable {
        /// The number of visits to that site
        var visitCount: Int
        /// The title of that site
        var title: String

        init(visitCount: Int, title: String) {
            self.visitCount = visitCount
            self.title = title
        }
    }

    private static var topSites: [URL: SiteData] {
        get { // note: this may have poor performance if the file gets too large
            do {
                let data = try Data(contentsOf: FileManager.default.getDocumentsDirectory()
                    .appendingPathComponent("extensions/topSites.json"))
                return try JSONDecoder().decode([URL: SiteData].self, from: data)
            } catch {
                return [:]
            }
        }
        set {
            let filePath = FileManager.default.getDocumentsDirectory()
                .appendingPathComponent("extensions/topSites.json")
            do {
                try JSONEncoder().encode(newValue).write(to: filePath)
            } catch {
                print("Could not save \(newValue): \(error.localizedDescription)")
            }
        }
    }

    /// Registers a site visit
    /// - Parameters:
    ///   - url: The URL of the page that was visited
    ///   - title: The ttile of the page that was visited
    static func addSiteVisit(url: URL, title: String) {
        // make sure that the URL doesn't have a ending extension
        // this is to avoid file downloads from being counted as common sites
        guard url.pathExtension.isEmpty else { return }
        topSites[url] = .init(visitCount: (topSites[url]?.visitCount ?? 0) + 1,
                              title: title)
    }

    /// Update the title of a site.
    ///
    /// Sometimes, when ``addSiteVisit(url:title:)`` is called, the title isn't fully loaded.
    /// When ``WKNavigationDelegatePlus/webView(_:titleChange:)`` is triggered, this function
    /// can be run.
    /// - Parameters:
    ///   - url: The URL to update
    ///   - newTitle: The title to use
    static func updateSiteTitle(url: URL, title newTitle: String) {
        guard var siteData = topSites[url] else { return }
        siteData.title = newTitle
        topSites[url] = siteData
    }

    /// Gets the n number of top sites
    /// - Parameter number: The number of top sites to get
    /// - Returns: An array of tuples containing the URL and the site's ``SiteData``
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
