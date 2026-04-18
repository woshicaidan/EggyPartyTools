//
//  DebugLogger.swift
//  party
//
//  调试日志工具 - 用于 TrollStore 签名后的调试
//

import Foundation

class DebugLogger {
    static let shared = DebugLogger()
    
    private let logFileURL: URL = {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("debug_log.txt")
    }()
    
    private init() {
        // 每次启动时清空旧日志
        try? "=== 新的调试会话开始 ===\n\(Date())\n\n".write(to: logFileURL, atomically: true, encoding: .utf8)
    }
    
    func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "[\(timestamp)] [\(fileName):\(line)] \(function) - \(message)\n"
        
        // 打印到控制台
        print(logMessage)
        
        // 写入文件
        if let handle = try? FileHandle(forWritingTo: logFileURL) {
            handle.seekToEndOfFile()
            if let data = logMessage.data(using: .utf8) {
                handle.write(data)
            }
            try? handle.close()
        } else {
            try? logMessage.write(to: logFileURL, atomically: true, encoding: .utf8)
        }
    }
    
    func logError(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        log("错误: \(error.localizedDescription)", file: file, function: function, line: line)
    }
    
    func getLogContent() -> String {
        return (try? String(contentsOf: logFileURL, encoding: .utf8)) ?? "无法读取日志文件"
    }
    
    func clearLog() {
        try? "=== 日志已清空 ===\n\(Date())\n\n".write(to: logFileURL, atomically: true, encoding: .utf8)
    }
    
    func getLogFilePath() -> String {
        return logFileURL.path
    }
}

// 简化调用
func debugLog(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    DebugLogger.shared.log(message, file: file, function: function, line: line)
}

func debugLogError(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
    DebugLogger.shared.logError(error, file: file, function: function, line: line)
}

