//
//  ABYPackage.swift
//  AbysSwift
//
//
//  Created by aby on 2018/6/5.
//Copyright © 2018年 Aby.wang. All rights reserved.
//
// @class ABYPackage
// @abstract rn热更新管理分发的类
// @discussion 热更新管理
//

import UIKit
import SSZipArchive // 负责解压
import Alamofire // 负责下载更新

/// 记录更新状态的枚举值
enum PackageLoadingStatus {
    case startDownload
    case downloading(progress: Progress)
    case downloadSuccess
    case downloadFailed(error: Error)
    case zipArchiving(progress: Double)
    case zipArchivingResult(path: String, successed: Bool, error: Error?)
}


protocol ABYPackageDelegate {
    func updateStatusChange(_ status: PackageLoadingStatus) -> Void
}


class ABYPackage {
    var resourceName: String = "main" // jsbundle的默认值
    var cachesPath: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] // 存放bundle的路径(在Caches文件夹下)
    var remoteURL: String = ""
    var version: String = "1.0"
    var bundleZipName = "JSAssect.zip"
    var delegate: ABYPackageDelegate?
    var bundleFile: String {
        let bundleFile = bundlePath + "/" + resourceName + ".jsbundle" // RN的文件路径
        return bundleFile
    }
    
    var bundlePath: String {
        return cachesPath + "/RNBundle"
    }
    
    private var _zipFile: String = ""
    //MARK: Initial Methods
    
    
    //MARK: Internal Methods

    
    //MARK: Public Methods
    /// 检查是否需要更新
    func isNeedUpdate(complete:@escaping (Bool)->(Void)) -> Void {
        // 文件不存在需要更新
        guard fileExist(in: bundleFile) else {
            complete(true)
            return
        }
        // 这里由接口决定是否加载
        // 文件存在，则检查版本，决定是否需要跟新
        self.request(url: "http://0.0.0.0:8888/api/filePath") { (data, response, error) -> (Void) in
            if let jsonDat = data {
                let dic = try? JSONSerialization.jsonObject(with:jsonDat , options: JSONSerialization.ReadingOptions.allowFragments)
                ABYPrint(dic)
                complete(true)
            } else {
                complete(false)
            }
        }
        return
    }
    /// 返回用于加载的URL
    func bundleURL() -> URL? {
        return URL.init(string: bundleFile)
    }
    
    func downLoadBundle() -> Void {
        guard verifyURL(url: remoteURL) else {
            ABYPrint("下载地址有误！")
            return
        }
        let bundleLocation = URL.init(fileURLWithPath: cachesPath, isDirectory: true)
        let fileURL = bundleLocation.appendingPathComponent(bundleZipName)
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        } // 存储路径
        self.delegate?.updateStatusChange(.startDownload) // 开始下载
        Alamofire.download(remoteURL, to: destination).downloadProgress { (progress: Progress) in
            self.delegate?.updateStatusChange(.downloading(progress: progress))
            }.responseData { (response) in
                if let err = response.error {
                    self.delegate?.updateStatusChange(.downloadFailed(error: err))
                } else {
                    self.delegate?.updateStatusChange(.downloadSuccess)
                    self._zipFile = fileURL.path // 保存全局路径
                    self.archiveZipFile()
                }
        }
    }
    //MARK: Privater Methods
    /// 开始解压
    private func archiveZipFile() -> Void {
        // 首先检查并创建文件路径
        var isDirectory: ObjCBool = ObjCBool.init(true)
        let exists = FileManager.default.fileExists(atPath: bundlePath, isDirectory: &isDirectory)
        if !(exists&&isDirectory.boolValue) {
            do {
                try FileManager.default.createDirectory(atPath: bundlePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                ABYPrint("创建文件夹失败")
                // FIXME: 这里需要传出去做UI提示
            }
        }
        SSZipArchive.unzipFile(atPath: self._zipFile, toDestination: bundlePath, progressHandler: { (entry: String, info: unz_file_info, entryNumber: Int, total: Int) in
            let progress = Double(entryNumber)/Double(total)
            self.delegate?.updateStatusChange(.zipArchiving(progress: progress))
        }) { (path: String, successed: Bool, error: Error?) in
            self.delegate?.updateStatusChange(.zipArchivingResult(path: path, successed: successed, error: error))
        }
    }
    
    /// 检查文件是否存在
    private func fileExist(in filePath: String) -> Bool {
        return FileManager.default.fileExists(atPath: filePath)
    }
    
    /// 移除某个文件
    private func removeFile(in filePath: String) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: filePath)
            return true
        } catch let error {
            ABYPrint("\(error)")
            return false
        }
    }
    
    /// 判断一个链接是不是网址
    private func verifyURL(url: String) -> Bool {
        do {
            let dataDetector = try NSDataDetector.init(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let res = dataDetector.matches(in: url, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSRange.init(location: 0, length: url.count))
            if res.count == 1 && res[0].range.location == 0 && res[0].range.length == url.count {
                return true
            }
        } catch  {
            ABYPrint("\(error)")
        }
        return false
    }
}

extension ABYPackage {
    func request(url: String, completionHander: @escaping (Data?, URLResponse?, Error?) -> (Void)) -> Void {
        guard let requestURL = URL.init(string: url) else {
            completionHander(nil, nil, nil)
            return
        }
        var request = URLRequest.init(url: requestURL)
        request.httpMethod = "POST" // 请求为POST
        request.httpBody = "current_id=\(Account.share.current_id)&version=1".data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                completionHander(data, response, error)
            }
        }
        task.resume() // 执行任务
    }
}
