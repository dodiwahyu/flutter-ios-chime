//
//  FlutterLogger.swift
//  tmchime-sdk
//
//  Created by TMLIJKTMAC08 on 14/10/22.
//

import Foundation
import AmazonChimeSDK

class FlutterLogger: NSObject {
    
    var chimeLogger: ConsoleLogger
    
    @objc init(name: String, level: AmazonChimeSDK.LogLevel = .INFO) {
        self.chimeLogger = ConsoleLogger(name: name, level: level)
    }

    /// Emits any message if the log level is equal to or lower than default level.
    func `default`(msg: String) {
        self.chimeLogger.default(msg: msg)
    }

    /// Calls `debugFunction` only if the log level is debug and emits the
    /// resulting string. Use the debug level to dump large or verbose messages
    /// that could slow down performance.
    func debug(debugFunction: () -> String) {
        self.chimeLogger.debug(debugFunction: debugFunction)
    }

    /// Emits an info message if the log level is equal to or lower than info level.
    func info(msg: String) {
        self.chimeLogger.info(msg: msg)
    }

    /// Emits a fault message if the log level is equal to or lower than fault level.
    func fault(msg: String) {
        self.chimeLogger.fault(msg: msg)
    }

    /// Emits an error message if the log level is equal to or lower than error level.
    func error(msg: String) {
        self.chimeLogger.error(msg: msg)
    }

    /// Sets the log level.
    func setLogLevel(level: AmazonChimeSDK.LogLevel) {
        self.chimeLogger.setLogLevel(level: level)
    }

}
