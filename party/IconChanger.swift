//
//  IconChanger.swift
//  party
//
//  SuperIcons 的 MyAction.swift
//

import Foundation
import UIKit

class IconChanger {
    
    private static var cpBinaryURL: URL {
        if #available(iOS 16.0, *) {
            return Bundle.main.url(forResource: "cp", withExtension: nil)!
        } else {
            return Bundle.main.url(forResource: "cp-15", withExtension: nil)!
        }
    }
    
    private static var mvBinaryURL: URL {
        if #available(iOS 16.0, *) {
            return Bundle.main.url(forResource: "mv", withExtension: nil)!
        } else {
            return Bundle.main.url(forResource: "mv-15", withExtension: nil)!
        }
    }
    
    private static var rmBinaryURL: URL {
        return Bundle.main.url(forResource: "rm", withExtension: nil)!
    }
    
    static func changeIcon(mainpath: String, iconPath: String, iconName: String, completion: @escaping (Bool, String) -> Void) {
        let fileManager = FileManager.default
        let tempDirectoryURL = URL(fileURLWithPath: "/tmp").appendingPathComponent(UUID().uuidString)
        
        do {
            try fileManager.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            completion(false, "创建临时目录失败: \(error.localizedDescription)")
            return
        }
        
        let infoPlistURL = URL(fileURLWithPath: mainpath)
        let backupPlistURL = infoPlistURL.deletingLastPathComponent().appendingPathComponent("Info.plist.bak")
        let tempInfoPlistURL = tempDirectoryURL.appendingPathComponent("Info.plist")
        let iconDestinationURL = infoPlistURL.deletingLastPathComponent().appendingPathComponent(iconName)
        
        var convertIconURL = URL(fileURLWithPath: iconPath)
        
        // 如果是 JPEG 格式，转换为 PNG
        if iconPath.lowercased().hasSuffix(".jpeg") || iconPath.lowercased().hasSuffix(".jpg") {
            let pngIconPath = tempDirectoryURL.appendingPathComponent("\(UUID().uuidString).png").path
            guard let jpegData = FileManager.default.contents(atPath: iconPath),
                  let image = UIImage(data: jpegData),
                  let pngData = image.pngData() else {
                completion(false, "JPEG 转 PNG 失败")
                return
            }
            do {
                try pngData.write(to: URL(fileURLWithPath: pngIconPath))
                convertIconURL = URL(fileURLWithPath: pngIconPath)
            } catch {
                completion(false, "写入 PNG 文件失败: \(error.localizedDescription)")
                return
            }
        }
        
        var success = false
        var errorMessage = ""
        
        do {
            // 1. 备份原 Info.plist
            try copyURL(infoPlistURL, to: backupPlistURL)
            // 2. 复制到临时目录
            try copyURL(infoPlistURL, to: tempInfoPlistURL)
            // 3. 复制新图标
            try copyURL(convertIconURL, to: iconDestinationURL)
            // 4. 更新 Info.plist
            try updateInfoPlist(at: tempInfoPlistURL, withIconName: iconName)
            // 5. 替换 Info.plist
            try copyURL(tempInfoPlistURL, to: infoPlistURL)
            success = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        completion(success, success ? "图标更换成功" : "图标更换失败: \(errorMessage)")
    }
    
    static func restoreIcon(mainpath: String, completion: @escaping (Bool, String) -> Void) {
        let fileManager = FileManager.default
        let infoPlistURL = URL(fileURLWithPath: mainpath)
        let backupURL = infoPlistURL.deletingLastPathComponent().appendingPathComponent("Info.plist.bak")
        
        if !fileManager.fileExists(atPath: backupURL.path) {
            completion(false, "未找到备份文件，请先更换图标")
            return
        }
        
        var success = false
        var errorMessage = ""
        
        do {
            try removeURL(infoPlistURL)
            try removeURL(infoPlistURL.deletingLastPathComponent().appendingPathComponent("AppIcon_AA.png"))
            try moveURL(backupURL, to: infoPlistURL)
            success = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        completion(success, success ? "图标恢复成功" : "图标恢复失败: \(errorMessage)")
    }
    
    private static func copyURL(_ src: URL, to dst: URL) throws {
        let retCode = try Execute.rootSpawnWithOutputs(binary: cpBinaryURL.path, arguments: ["-rfp", src.path, dst.path])
        guard case .exit(let code) = retCode.terminationReason, code == 0 else {
            throw NSError(domain: "IconChanger", code: 1, userInfo: [NSLocalizedDescriptionKey: "cp 命令失败"])
        }
    }
    
    private static func removeURL(_ url: URL) throws {
        let retCode = try Execute.rootSpawnWithOutputs(binary: rmBinaryURL.path, arguments: ["-rf", url.path])
        guard case .exit(let code) = retCode.terminationReason, code == 0 else {
            throw NSError(domain: "IconChanger", code: 2, userInfo: [NSLocalizedDescriptionKey: "rm 命令失败"])
        }
    }
    
    private static func moveURL(_ src: URL, to dst: URL) throws {
        let retCode = try Execute.rootSpawnWithOutputs(binary: mvBinaryURL.path, arguments: ["-f", src.path, dst.path])
        guard case .exit(let code) = retCode.terminationReason, code == 0 else {
            throw NSError(domain: "IconChanger", code: 3, userInfo: [NSLocalizedDescriptionKey: "mv 命令失败"])
        }
    }
    
    private static func updateInfoPlist(at url: URL, withIconName iconName: String) throws {
        guard let plist = NSMutableDictionary(contentsOf: url) else {
            throw NSError(domain: "IconChanger", code: 4, userInfo: [NSLocalizedDescriptionKey: "无法读取 Info.plist"])
        }
        
        replaceAppIconNames(in: plist, with: iconName)
        
        if !plist.write(to: url, atomically: true) {
            throw NSError(domain: "IconChanger", code: 5, userInfo: [NSLocalizedDescriptionKey: "无法写入 Info.plist"])
        }
    }
    
    private static func replaceAppIconNames(in dict: NSMutableDictionary, with iconName: String) {
        for (key, value) in dict {
            if let keyString = key as? String, keyString.hasPrefix("CFBundleIcon") || keyString.hasPrefix("AppIcon") {
                dict[key] = iconName
            } else if let subDict = value as? NSMutableDictionary {
                replaceAppIconNames(in: subDict, with: iconName)
            } else if let array = value as? [Any] {
                let newArray = array.map { item -> Any in
                    if let subDict = item as? NSMutableDictionary {
                        replaceAppIconNames(in: subDict, with: iconName)
                        return subDict
                    }
                    return item
                }
                dict[key] = newArray
            }
        }
    }
}

