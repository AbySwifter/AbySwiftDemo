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
}
