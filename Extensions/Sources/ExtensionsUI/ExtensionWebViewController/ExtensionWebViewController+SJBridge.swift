//
//  ExtensionWebViewController+SJBridge.swift
//  
//
//  Created by Kai Quan Tay on 29/3/23.
//

import WebKit
import ExtensionsModel

extension ExtensionWebViewController: WKUIDelegate, WKScriptMessageHandler {
    public func webView(_ webView: WKWebView,
                        runJavaScriptTextInputPanelWithPrompt prompt: String,
                        defaultText: String?,
                        initiatedByFrame frame: WKFrameInfo,
                        completionHandler: @escaping (String?) -> Void) {

        guard let (funcName, paramData) = JSAPIFunctions.serializeAPIRequest(prompt: prompt) else {
            completionHandler("could not serialize data")
            return
        }

        switch funcName {
        case "getTopSites":
            let topSites = dataSource.getTopSites(number: 10)
            if let stringValue = encode(topSites) {
                completionHandler(stringValue)
                return
            }
        case "createTab", "updateCurrentTab":
            guard let params = paramData as? [String: String],
                  let urlString = params["url"],
                  let url = URL(string: urlString)
            else { break }
            if funcName == "createTab" {
                dataSource.createTab(url: url)
            } else if funcName == "updateCurrentTab" {
                dataSource.updateTab(url: url)
            }
        case "isNewTab":
            // new_tab is the opposite of isNewTab
            completionHandler(String(!dataSource.isNewTab()))
            return
        default: break
        }

        completionHandler(nil)
    }

    /// Encodes an encodable into a string
    func encode<T: Encodable>(_ toEncode: T) -> String? {
        if let encodedData = try? JSONEncoder().encode(toEncode),
           let stringValue = String(data: encodedData, encoding: .utf8) {
            return stringValue
        }
        return nil
    }

    /// A function usually used to print `console.log` statements to the Xcode console
    public func userContentController(_ userContentController: WKUserContentController,
                                      didReceive message: WKScriptMessage) {
        #if DEBUG
        print("[JAVASCRIPT] \(message.name): \(message.body)")
        #endif
    }
}
