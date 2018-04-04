//
//  MessageBus.swift
//  AbysSwift
//  将消息接收的逻辑从ConversationManger里面进行解耦
//
//  Created by aby on 2018/4/3.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation
import SwiftyJSON

/// 消息管理分发类
class MessageBus: ABYSocketDelegate {
	static let distance = MessageBus.init()
	private init() {
		ABYSocket.manager.delegate = self
	}

	func onMessage(message: JSON) {

	}

	func statusChange(status: ABYSocketStatus) {

	}
}
