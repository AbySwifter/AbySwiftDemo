//
//  SocketProtocl.swift
//  AbysSwift
//
//  Created by aby on 2018/3/26.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Socket链接状态描述
///
/// - loginError: 登陆出错
/// - loginSuccess: 登录成功
/// - socketLose: 链接丢失
/// - socketPingOut: 心跳丢失
/// - socketDisconnect: 断开链接
/// - socketReconnect: 重新链接
enum ABYSocketStatus {
	case loginError
	case loginSuccess
	case socketLose
	case socketPingOut
	case socketDisconnect
	case socketReconnect
}


/// ABYSocket的协议代理
protocol ABYSocketDelegate {
	func onMessage(message: JSON) -> Void
	func statusChange(status: ABYSocketStatus) -> Void
}
