//
//  JSAPIFunctions.swift
//  Orion
//
//  Created by Kai Quan Tay on 24/3/23.
//

import Foundation
import WebKit

enum JSAPIFunctions {
    static func setUp<UIDelegate: WKUIDelegate,
                      MessageHandler: WKScriptMessageHandler>(webView: WKWebView,
                                                              uiDelegate: UIDelegate,
                                                              messageHandler: MessageHandler) {
        // inject JS to capture console.log output and send to iOS
        let source = [JSAPIFunctions.setupString,
                      JSAPIFunctions.getTopSites].joined(separator: "\n")

        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(script)
        // register the bridge script that listens for the output
        webView.configuration.userContentController.add(messageHandler, name: "logHandler")
        webView.uiDelegate = uiDelegate
    }

    static func serializeAPIRequest(prompt: String) -> (String, Any?)? {
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
            JSAPIFunctions.queryNativeCode,
            "console.log('doing stuff');"
        ].joined(separator: "\n")
    }

    static let captureLog: String = """
function captureLog(msg) {
    window.webkit.messageHandlers.logHandler.postMessage(msg);
}
window.console.log = captureLog;
"""

    static let queryNativeCode: String = """
function queryNativeCode(funcName, data) {
    console.log('querying native app');
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

// MARK: Top sites API
extension JSAPIFunctions {
    static let getTopSites: String = """
function getTopSites() {
    return eval(queryNativeCode("getTopSites", {}))
}

browser.topSites = {}
browser.topSites.get = getTopSites;
"""
}
