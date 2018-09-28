//
//  FileManager.swift
//  AbysSwift
//
//  Created by aby on 2018/5/3.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import DTTools


/// 文件管理者
class KKFileManager {
    /// 文件管理者单例实例
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
    /// 用户语音缓存目录
    lazy var accountAudioPath: String = {
        return cachePath
    }()
    

    /// 检测文件路径是否存在
    ///
    /// - Parameter path: 需要检测的文件路径
    /// - Returns: 是否x存在的结果
    func isPathExist(path: String) -> Bool {
        let isDir: UnsafeMutablePointer<ObjCBool> = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 8)
        let isExist = self.fileManager.fileExists(atPath: path, isDirectory: isDir)
        let result = isDir.pointee.boolValue && isExist
        return result
    }
    /// 给指定路径z创建文件件
    ///
    /// - Parameter path: 需要创建的路径
    /// - Returns: 是否创建成功
    func createDir(path: String) -> Bool {
        guard !isPathExist(path: path) else { return true }
        do {
            try self.fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            DTLog(error)
            return false
        }
    }
    /// 在cache文件夹下创建目录，按照父到子文件夹的顺序
    ///
    /// - Parameter dirs: 文件夹名称
    /// - Returns: 返回创建的路径
    func createDirInCache(dirs: [String]) -> String? {
        var path = self.cachePath
        for items in dirs {
             path = path.appending("/\(items)")
        }
        DTLog("当前路径：\(path)")
        if self.createDir(path: path) {
            return path
        } else {
            return nil
        }
    }
    /// 删除指定路径的文件或文件夹
    ///
    /// - Parameter path: 要删除的文件路径
    /// - Returns: 是否操作成功
    func removeFileIn(path: String) -> Bool {
        var result = true
        do {
            try self.fileManager.removeItem(atPath: path)
        } catch  {
            DTLog("删除文件的错误:\(error)")
            result = false
        }
        return result
        
    }
    /// TODO: - 清理缓存
}
