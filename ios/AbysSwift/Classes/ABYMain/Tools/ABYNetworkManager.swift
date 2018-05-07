//
//  ABYNetworkManager.swift
//  AbysSwift
//
//  Created by aby on 2018/2/2.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


/// 请求回调闭包定义
typealias ResponseBlock = (JSON?) -> (Void);
typealias ResponseErrorBlock = (Error) -> (Void);

enum UpLoadFileType: String {
    case audio = "voice"
    case image = "image"
}

class ABYNetworkManager: NSObject {
	static let shareInstance = ABYNetworkManager()
	lazy var sessionManager: SessionManager = {
		let configuration: URLSessionConfiguration = URLSessionConfiguration.default
		configuration.timeoutIntervalForRequest = 10.0 // 自定义超时时间（默认是30秒）
		let manager: SessionManager = SessionManager.init(configuration: configuration)
//		let manager: SessionManager = SessionManager.default
		// 自定的https证书需要配置验证（问题来了, 为什么Alamofire发起的请求就不需要呢）
		manager.delegate.sessionDidReceiveChallenge = { session, challenge in
			var disposition: URLSession.AuthChallengeDisposition = .cancelAuthenticationChallenge
			var credential: URLCredential?

			if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
				disposition = URLSession.AuthChallengeDisposition.useCredential
				credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
			} else {
				if challenge.previousFailureCount > 0 {
					disposition = .cancelAuthenticationChallenge
				} else {
					credential = manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
					if credential != nil {
						disposition = .useCredential
					}
				}
			}
			return (disposition, credential)
		}
		return manager
	}()

	private override init() {}

	/// 网络请求的方式
	///
	/// - Parameters:
	///   - request: 遵循URLRequsetConvertible协议的类型
	///   - callBack: 结果返回
	func aby_request(request: URLRequestConvertible, callBack: @escaping ResponseBlock) -> Void {
		sessionManager.request(request).responseJSON(completionHandler: { (data) in
			switch data.result {
			case .success(let value) :
				let json: JSON = JSON(value)
				callBack(json)
			case .failure(let error):
				print(error)
				callBack(nil)
			}
		})
	}



	/// 网络请求方式
	///
	/// - Parameters:
	///   - request: 遵循URLRequsetConvertible协议的类型
	///   - callBack: 结果返回
	///   - error: 错误返回
	func aby_request(request: URLRequestConvertible, callBack: @escaping ResponseBlock, error: @escaping ResponseErrorBlock) -> Void {
		sessionManager.request(request).responseJSON(completionHandler: { (data) in
			switch data.result {
			case .success(let value) :
				let json: JSON = JSON(value)
				callBack(json)
			case .failure(let err):
				print(err)
				error(err)
			}
		})
	}
    /// 上传文件的方法
    ///
    /// - Parameters:
    ///   - path: 文件路劲
    ///   - fileName: 文件名
    ///   - type: 文件类型
    func aby_upload(path: String, fileName: String, type: UpLoadFileType, callBack: @escaping ResponseBlock) -> Void {
        let url = URL.init(fileURLWithPath: path)
        let header: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type":"multipart/form-data;charset=utf-8"
        ]
        sessionManager.upload(multipartFormData: { (formData) in
            formData.append(type.rawValue.data(using: .utf8)!, withName: "file_type")
            formData.append(url, withName: "file", fileName: fileName, mimeType: "multipart/form-data'")
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,to: UploadRouter.request(api: UserAPI.upLoadFile),method: HTTPMethod.post, headers:header) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON(completionHandler: { (response) in
                    let result = response.result
                    switch result {
                    case .success(let value):
                        let json = JSON.init(rawValue: value)
                        callBack(json) // 返回json数据
                        break
                    case .failure(let error):
                        ABYPrint(error)
                        callBack(nil)
                    }
                });
            case .failure(let encodingError):
                print(encodingError)
                callBack(nil) // 错误的时候返回为空
            }
        }
    }
}
