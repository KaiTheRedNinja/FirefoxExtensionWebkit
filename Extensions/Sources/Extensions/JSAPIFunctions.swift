//
//  JSAPIFunctions.swift
//  Orion
//
//  Created by Kai Quan Tay on 24/3/23.
//

import Foundation
import WebKit

/// An enum that manages functions to inject certain javascript functions into a WKWebView
public enum JSAPIFunctions {
    /// Sets up a WKWebView with
    /// - Two way JS-Swift communication
    /// - The `topSites` web API
    /// - Parameters:
    ///   - webView: The web view to set up
    ///   - uiDelegate: The `WKUIDelegate` for the web view
    ///   - messageHandler: The `WKScriptMessageHandler` for the web view
    public static func setUp<UIDelegate: WKUIDelegate,
                      MessageHandler: WKScriptMessageHandler>(webView: WKWebView,
                                                              uiDelegate: UIDelegate,
                                                              messageHandler: MessageHandler) {
        // inject JS to capture console.log output and send to iOS
        let source = [setupString, APIFunctions].joined(separator: "\n")

        let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(script)
        // register the bridge script that listens for the output
        webView.configuration.userContentController.add(messageHandler, name: "logHandler")
        webView.uiDelegate = uiDelegate
    }

    /// Turns a prompt message into a tuple of the function name and parameters, if any.
    /// - Parameter prompt: The `prompt` string
    /// - Returns: A tuple of the function name and any parameters, or nil if invalid
    public static func serializeAPIRequest(prompt: String) -> (String, Any?)? {
        if let dataFromString = prompt.data(using: .utf8, allowLossyConversion: false) {
            guard let json = try? JSONSerialization.jsonObject(with: dataFromString) as? [String: Any],
                  let type = json["type"] as? String,
                  type == "SJbridge",
                  let functionName = json["functionName"] as? String else {
                return nil
            }

            return (functionName, json["data"])
        } else {
            print("Unhandled data")
            return nil
        }
    }

    static var setupString: String {
        [
            JSAPIFunctions.captureLog,
            JSAPIFunctions.defineBrowser,
            JSAPIFunctions.queryNativeCode
        ].joined(separator: "\n")
    }

    static let captureLog: String = """
function captureLog(msg) {
    window.webkit.messageHandlers.logHandler.postMessage(msg);
}
window.console.log = captureLog;
window.console.error = captureLog;
"""

    static let queryNativeCode: String = """
function queryNativeCode(funcName, data) {
    console.log('querying native app: ' + funcName);
    try {
        var type = "SJbridge";
        var payload = {type: type, functionName: funcName, data: data};

        var res = prompt(JSON.stringify (payload));

        return res
    } catch(err) {
        console.log('The native context does not exist yet');
    }
}
"""

    static let defineBrowser: String = "browser = {};"
}

// MARK: Web APIs
extension JSAPIFunctions {
    static var APIFunctions: String {
        [
            getTopSites,
            getStorageLocal,
            openNewTab,
            updateCurrentTab
        ].joined(separator: "\n")
    }

    static let getTopSites: String = """
function getTopSites() {
    const topSites = eval(queryNativeCode("getTopSites", {}));
    const resolvingPromise = Promise.resolve(topSites);
    console.log("Top sites promise made")
    return resolvingPromise
}

browser.topSites = {};
browser.topSites.get = getTopSites;
"""
    static let getStorageLocal: String = """
function getStorageLocal(params) {
    // in the future, this would link to the browser to check if its a new tab
    return Promise.resolve({"new_tab": true});
}
browser.storage = {};
browser.storage.local = {};
browser.storage.local.get = getStorageLocal;
"""
    static let openNewTab: String = """
function createTab(params) {
    console.log("Creating tab " + params.url)
    queryNativeCode("createTab", params);
}
browser.tabs = {};
browser.tabs.create = createTab;
"""
    static let updateCurrentTab: String = """
function updateCurrentTab(params) {
    console.log("Updating tabs")
    queryNativeCode("updateCurrentTab", params)
}
browser.tabs.update = updateCurrentTab;
"""
}
