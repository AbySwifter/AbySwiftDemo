//
//  SocketProtocl.swift
//  AbysSwift
//
//  Created by aby on 2018/3/26.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation
import SwiftyJSON
import DTTools

/// Socket链接状态描述
///
/// - loginError: 登陆出错
/// - loginSuccess: 登录成功
/// - socketLose: 链接丢失
/// - socketPingOut: 心跳丢失
/// - socketDisconnect: 断开链接
/// - socketReconnect: 重新链接
enum ABYSocketStatus: Int {
	case loginError = 0
	case loginSuccess = 1
	case socketLose = 2
	case socketPingOut = 3
	case socketDisconnect = 4
	case socketReconnect = 5
}


/// ABYSocket的协议代理
protocol ABYSocketDelegate {
	func onMessage(message: JSON) -> Void
	func statusChange(status: ABYSocketStatus) -> Void
}

extension ABYSocketDelegate {
	func statusChange(status: ABYSocketStatus) -> Void {
		DTLog(String.init(format: "%@状态：%@", "默认状态改变的方法", status.rawValue))
	}
}
