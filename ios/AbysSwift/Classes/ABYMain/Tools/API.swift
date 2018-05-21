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
    case changePassword = "change_password" // 修改该密码接口
	// 会话接口
	case endService = "end_service" // 结束服务
	case setReadCount = "set_room_read_message" // 上报未读消息
	// 会话列表接口
	case chatList = "chat_list" //会话列表
    case historyList = "history_message" // 历史消息列表
    case switchServiceStatus = "switch_service_status"
    // 获取客户信息
    case getCustomerInfo = "customer_info"
    case updateCustomRemark = "update_customer_remark"
    
    // 转接客服列表
    case switchServiceList = "switch_service_list"
    case switchService = "switch_service"
    
    case upLoadFile = "upload_file" // 上传文件的接口

	// 计算属性，根据不同枚举值计算当前API的信息
	var info: APIInfo {
		switch self {
		case .code:
			return (self.rawValue, .post, false)
		case .auth:
			return (self.rawValue, .post, false)
		case .userInfo:
			return (self.rawValue, .post, false)
		case .setReadCount:
			return (self.rawValue, .post, false)
        case .upLoadFile:
            return (self.rawValue, .post, false)
		// 默认为POST方法、需要授权
		default:
			return (self.rawValue, .post, true)
		}
	}
}

enum UploadRouter: URLConvertible {
    func asURL() throws -> URL {
        let baseUrl = try URLinfo.baseURL.rawValue.asURL()
        switch self {
        case .request(api: let api):
            return baseUrl.appendingPathComponent(api.info.url)
        }
    }
    case request(api: UserAPI)
}
// 登录注册接口路由
enum UserRouter: URLRequestConvertible {

	case userInfo(token: String)
	case request(api: UserAPI, params: Parameters?)

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
				// FIXME: 处理授权不存在的问题
			}
		}
		urlRequest.httpMethod = apiInfo.info.method.rawValue
		urlRequest.setValue("*/*", forHTTPHeaderField: "Accept")
		urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
		urlRequest = try encodingParams(urlRequest: urlRequest) // 处理请求参数
		return urlRequest
	}
}

extension UserRouter {
	var apiInfo: UserAPI {
		switch self {
		case .userInfo(token: _):
			return UserAPI.userInfo
		case .request(api: let api, params: _):
			return api
		}
	}
	func encodingParams(urlRequest: URLRequest) throws -> URLRequest {
		switch self {
		case .userInfo(token: let token):
			return try JSONEncoding.default.encode(urlRequest, with: ["token": token])

		case .request(api: _, params: let params):
			if let p = params {
				switch self.apiInfo.info.method {
				case .get:
					return try URLEncoding.default.encode(urlRequest, with: p)
				default:
					return try JSONEncoding.default.encode(urlRequest, with: p)
				}
			}
			return urlRequest
		}
	}
}
