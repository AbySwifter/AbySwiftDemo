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

protocol MessageBusDelegate {
	func messageBus(_ message: Message, sendStatus: DeliveryStatus) -> Void
	func messageBus(on message: Message) -> Void
}

/// 消息管理分发类
class MessageBus: ABYSocketDelegate {
	static let distance = MessageBus.init()
	private init() {}
	var delegate: MessageBusDelegate?
	func onMessage(message: JSON) {
		guard let dictionary = message.dictionaryObject else { return }
		guard let msgModel = Message.deserialize(from: dictionary) else { return }
	    // 处理房间的消息
		if msgModel.room_id != nil && msgModel.room_id != 0 {
			// 说明是房间消息开始处理
			if msgModel.isKH == 0 && msgModel.sender?.sessionID == self.session_id {
				// 说明是自己发送的消息， 此时，需要更新新视图
				msgModel.deliveryStatus = .delivered
				delegate(message: msgModel, status: .delivered)
			} else {
				delegate(on: msgModel)
			}
		}

	}

	func statusChange(status: ABYSocketStatus) {

	}

	private func delegate(message: Message, status: DeliveryStatus) -> Void {
//		for (_, item) in self.delegate {
//			item.messageBus(message, sendStatus: status)
//		}
		self.delegate?.messageBus(message, sendStatus: status)
	}

	private func delegate(on message: Message) -> Void {
//		for (_, item) in self.delegate {
//			item.messageBus(on: message)
//		}
		self.delegate?.messageBus(on: message)
	}
}

extension MessageBus {
	// 发送消息
	func send(message: Message) -> Void {
		ABYSocket.manager.send(message: message)
	}

	func addDelegate(_ delegate: MessageBusDelegate) -> Int {
		self.delegate = delegate
		return 0
	}

	func removeDelegate(index: Int?) -> Void {
		self.delegate = nil
	}
}

// 存放计算属性
extension MessageBus {
	var session_id: String {
		return ABYSocket.manager.session_id // 返回当前用户的session_id
	}
}
