//
//  JSAPIFunctions+WebAPI.swift
//  
//
//  Created by Kai Quan Tay on 27/3/23.
//

import Foundation

extension JSAPIFunctions {
    /// Injects `browser.topSites.get`
    /// Permission required: `topSites`
    static let getTopSites: String = """
function getTopSites() {
    const topSites = eval(queryNativeCode("getTopSites", {}));
    const resolvingPromise = Promise.resolve(topSites);
    return resolvingPromise
}

browser.topSites = {};
browser.topSites.get = getTopSites;
"""

    /// Injects `browser.storage.local.get`
    /// Permission required: `storage`
    static let getStorageLocal: String = """
function getStorageLocal(params) {
    const isNewTab = eval(queryNativeCode("isNewTab", {}));
    return Promise.resolve({"new_tab": isNewTab});
}
browser.storage = {};
browser.storage.local = {};
browser.storage.local.get = getStorageLocal;
"""

    /// Injects `browser.tabs.create` and `browser.tabs.update`
    /// No permissions required
    static var createUpdateTab: String {
        [
            JSAPIFunctions.openNewTab,
            JSAPIFunctions.updateCurrentTab
        ].joined(separator: "\n")
    }

    /// Injects `browser.tabs.create`
    static let openNewTab: String = """
function createTab(params) {
    queryNativeCode("createTab", params);
}
browser.tabs = {};
browser.tabs.create = createTab;
"""

    /// Injects `browser.tabs.update`
    static let updateCurrentTab: String = """
function updateCurrentTab(params) {
    queryNativeCode("updateCurrentTab", params)
}
browser.tabs.update = updateCurrentTab;
"""
}
