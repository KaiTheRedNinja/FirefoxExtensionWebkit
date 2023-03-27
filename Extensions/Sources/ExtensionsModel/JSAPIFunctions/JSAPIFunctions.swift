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
    public static func setUp<UIDelegate: WKUIDelegate, MessageHandler: WKScriptMessageHandler>(
        webView: WKWebView,
        for ext: FirefoxExtension,
        uiDelegate: UIDelegate,
        messageHandler: MessageHandler
    ) {
        // inject JS to capture console.log output and send to iOS
        let source = jsToInject(for: ext)

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

    /// Determines the javascript needed to inject the web APIs for a given firefox extension
    private static func jsToInject(for ext: FirefoxExtension) -> String {
        var injectionMethods = [setupString]
        injectionMethods.append(contentsOf: ext.permissions.compactMap { permission in
            switch permission {
            case "topSites": return getTopSites
            case "storage": return getStorageLocal
            case "activeTab": return createUpdateTab
            default: return nil
            }
        })
        return injectionMethods.joined(separator: "\n")
    }
}
