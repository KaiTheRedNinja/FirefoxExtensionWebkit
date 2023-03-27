//
//  ExtensionWebViewDataSource.swift
//  
//
//  Created by Kai Quan Tay on 27/3/23.
//

import Foundation

/// Provides data to an ``ExtensionWebViewController``
public protocol ExtensionWebViewDataSource {
    /// Gets the user's most visited sites
    func getTopSites(number: Int) -> [(URL, SiteData)]
}

public struct SiteData: Codable {
    public var visitCount: Int
    public var title: String

    public init(visitCount: Int, title: String) {
        self.visitCount = visitCount
        self.title = title
    }
}
