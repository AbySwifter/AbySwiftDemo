//
//  FileManager.swift
//  AbysSwift
//
//  Created by aby on 2018/5/3.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit


class KKFileManager {
    static let distance = KKFileManager.init()
    private init() {}
    /// 返回缓存路径
    lazy var cachePath: String = {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let path = paths.first
        return path!
    }()
    /// 返回文件管理者
    private lazy var fileManager: FileManager = {
        return FileManager.default
    }()
    lazy var accountAudioPath: String = {
        return cachePath
    }()
    
    /// 检测文件夹是否存在
    func isPathExist(path: String) -> Bool {
        let isDir: UnsafeMutablePointer<ObjCBool> = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 8)
        let isExist = self.fileManager.fileExists(atPath: path, isDirectory: isDir)
        let result = isDir.pointee.boolValue && isExist
        return result
    }
    /// 创建文件夹在指定路径
    func createDir(path: String) -> Bool {
        guard !isPathExist(path: path) else { return true }
        do {
            try self.fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            ABYPrint(error)
            return false
        }
    }
    /// 在Cache文件夹下创建目录, 传入目录名，按照父 -> 子的顺序
    func createDirInCache(dirs: [String]) -> String? {
        var path = self.cachePath
        for items in dirs {
             path = path.appending("/\(items)")
        }
        ABYPrint("当前路径：\(path)")
        if self.createDir(path: path) {
            return path
        } else {
            return nil
        }
    }
    /// 删除文件
    func removeFileIn(path: String) -> Bool {
        var result = true
        do {
            try self.fileManager.removeItem(atPath: path)
        } catch  {
            ABYPrint("删除文件的错误:\(error)")
            result = false
        }
        return result
        
    }
    /// 清理缓存
}
