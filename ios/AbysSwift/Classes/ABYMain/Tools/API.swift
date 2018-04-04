//
//  Const.swift
//  AbysSwift
//
//  Created by aby on 2018/2/6.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation
import Alamofire

// 请求参数信息
typealias APIInfo = (url: String, method: HTTPMethod, needAuth: Bool)

// 接口参数
enum UserAPI: String {
	case code = "captcha" // 验证码接口
	case auth = "authenticate" // 登录授权接口
	case userInfo = "user_info" // 获取用户信息接口
	case stats = "stats" // 获取报表信息
	// 会话接口
	case endService = "end_service" // 结束服务
	// 会话列表接口
	case chatList = "chat_list" //会话列表

	// 计算属性，根据不同枚举值计算当前API的信息
	var info: APIInfo {
		switch self {
		case .code:
			return (self.rawValue, .post, false)
		case .auth:
			return (self.rawValue, .post, false)
		case .userInfo:
			return (self.rawValue, .post, false)
		case .stats:
			return (self.rawValue, .post, true)
		case .endService:
			return (self.rawValue, .post, true)
		case .chatList:
			return (self.rawValue, .post, true)
//		default:
//			return ("", .get, false)
		}
	}
}

// 登录注册接口路由
enum UserRouter: URLRequestConvertible {
	case code
	case auth(params: Parameters)
	case userInfo(token: String)
	case stats(params: Parameters)
	case chatList(params: Parameters)

	case endService(params: Parameters)
	// FIXME: 每次添加接口时，都进行处理
	var apiInfo: UserAPI {
		switch self {
		case .code:
			return UserAPI.code
		case .auth(params: _):
			return UserAPI.auth
		case .userInfo(token: _):
			return UserAPI.userInfo
		case .stats(params: _):
			return .stats
		case .endService(params: _):
			return .endService
		case .chatList(params: _):
			return .chatList
		}
	}
	// 协议的方法实现
	func asURLRequest() throws -> URLRequest {
		let url = try URLinfo.baseURL.rawValue.asURL()
		let request = URLRequest(url: url.appendingPathComponent(apiInfo.info.url))
		var urlRequest = try URLEncoding.default.encode(request, with: ["platform": "ios"])
		if apiInfo.info.needAuth {
			// 在这里判断token是否存在
			if Account.share.isLogin {
				let params: Parameters = ["token": Account.share.token]
				urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
			} else {
				// 处理授权不存在的问题
			}
		}
		urlRequest.httpMethod = apiInfo.info.method.rawValue
		urlRequest.setValue("*/*", forHTTPHeaderField: "Accept")
		urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
		urlRequest = try encodingParams(urlRequest: urlRequest) // 处理请求参数
		return urlRequest
	}
	// 根据请求拼接参数 FIXME: 每次不同的请求对参数进行不同的处理
	func encodingParams(urlRequest: URLRequest) throws -> URLRequest {
		switch self {
		case .auth(params: let params):
			switch self.apiInfo.info.method {
			case .get:
				return try URLEncoding.default.encode(urlRequest, with: params)
			default:
				return try JSONEncoding.default.encode(urlRequest, with: params)
			}
		case .userInfo(token: let token):
			return try JSONEncoding.default.encode(urlRequest, with: ["token": token])
		case .stats(params: let params):
			return try JSONEncoding.default.encode(urlRequest, with: params)
		case .endService(params: let params):
			return try JSONEncoding.default.encode(urlRequest, with: params)
		case .chatList(params: let params):
			return try JSONEncoding.default.encode(urlRequest, with: params)
		default:
			return urlRequest
		}
	}
}

