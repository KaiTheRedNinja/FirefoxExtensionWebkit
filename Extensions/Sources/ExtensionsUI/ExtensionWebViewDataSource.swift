//
//  ExtensionWebViewDataSource.swift
//  
//
//  Created by Kai Quan Tay on 27/3/23.
//

import Foundation

/// Provides data to an ``ExtensionWebViewController``
public protocol ExtensionWebViewDataSource {
    /// Gets the user's most visited sites. Structured most visited to least visited.
    ///
    /// Each item in the array should have this structure:
    /// ```json
    /// {
    ///     "url": "https://www.kagi.com", // the url here, including scheme
    ///     "title": "Kagi Search" // the title here
    /// }
    /// ```
    func getTopSites(number: Int) -> [[String: String]]

    /// Determines if the current tab is a newtab
    func isNewTab() -> Bool

    /// Creates a new tab with a given URL
    func createTab(url: URL)

    /// Updates the current tab to a given URL
    func updateTab(url: URL)
}
