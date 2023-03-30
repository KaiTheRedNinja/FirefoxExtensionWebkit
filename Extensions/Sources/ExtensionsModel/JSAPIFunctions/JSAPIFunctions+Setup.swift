//
//  JSAPIFunctions+Setup.swift
//  
//
//  Created by Kai Quan Tay on 27/3/23.
//

import Foundation

extension JSAPIFunctions {
    static var setupString: String {
        [
            JSAPIFunctions.captureLog,
            JSAPIFunctions.defineBrowser,
            JSAPIFunctions.queryNativeCode
        ].joined(separator: "\n")
    }

    /// Redefines `console.log` and `console.error`, sending it to the message handler
    static let captureLog: String = """
function captureLog(msg) {
    window.webkit.messageHandlers.logHandler.postMessage(msg);
}
window.console.log = captureLog;
window.console.error = captureLog;
"""

    /// Defines a function to ask the native app to run a function with optional parameters
    static let queryNativeCode: String = """
function queryNativeCode(funcName, data) {
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

    /// Defines the `browser` object
    static let defineBrowser: String = "browser = {};"
}
