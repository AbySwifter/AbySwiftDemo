//
//  ApiConfig.swift
//  DTRequest_Example
//
//  Created by aby on 2018/6/25.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import Foundation
import DTRequest
import Alamofire

enum Api: String, DTAPIInfoConfig{
    case code = "captcha" // 验证码接口
    case auth = "authenticate" // 登录授权接口
    case userInfo = "user_info" // 获取用户信息接口
    case stats = "stats" // 获取报表信息
    case changePassword = "change_password" // 修改该密码接口
    // 会话接口
    case endService = "end_service" // 结束服务
    case sendEvaluate = "send_evaluate" // 发送评价消息
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

    
    /// 配置每个接口的信息
    ///
    /// - Returns: 返回每个接口的信息
    func getApi() -> APIInfo {
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
   
    func getHeader() -> HTTPHeaders {
        switch self {
        case .upLoadFile:
            return [ "Accept": "application/json", "Content-Type":"multipart/form-data;charset=utf-8"];
        default:
            return ["Accept": "*/*" , "content-Type": "application/json"];
        }
    }
}
