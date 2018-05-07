//
//  MessageBus.swift
//  AbysSwift
//  主要负责消息的分发、存储等逻辑
//
//  Created by aby on 2018/4/3.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//  下文注释中：#1 表示处理的优先级，1~9 优先级由高到低
//

import Foundation
import SwiftyJSON

protocol MessageBusDelegate {
	// 只有会话页面需要实现的消息
	func messageBus(_ message: Message, sendStatus: DeliveryStatus) -> Void // 更新room消息的状态

	func messageBus(on message: Message) -> Void
}

extension MessageBusDelegate {
	func messageBus(_ message: Message, sendStatus: DeliveryStatus) {
		ABYPrint("更新消息的默认实现")
	}
}

/// 消息管理分发类
class MessageBus: ABYSocketDelegate {
	static let distance = MessageBus.init()
	private init() {}
	var delegate: MessageBusDelegate?

	var convManager: MessageBusDelegate {
		return ConversationManager.distance
	}

	func onMessage(message: JSON) {
		guard let dictionary = message.dictionaryObject else { return }
		guard let msgModel = Message.deserialize(from: dictionary) else { return }
		// 特殊消息的处理(首先处理超时，服务队列更新的消息#1)
		if msgModel.messageType == MessageType.sys {
			if msgModel.content?.type == .sysServiceTimeout || msgModel.content?.type ==  .sysChatTimeout {
				// 发送超时事件
			}
			if msgModel.content?.type == MSG_ELEM.sysServiceWaitCount {
				// 发送等待队列长度改变的事件
			}
		}
		// 处理房间的消息(公共业务： 保存消息，更新消息总数#2)
		if msgModel.room_id != nil && msgModel.room_id != 0 {
			if msgModel.content?.type == MSG_ELEM.sysServiceEnd {
				// 排除掉服务结束的消息
			} else {
				// 区分是否为自己发出去的消息
				if msgModel.isKH == 0 && msgModel.sender?.sessionID == self.session_id {
					// 自己发出去的消息需要更新发送状态
					msgModel.deliveryStatus = .delivered
					delegate(message: msgModel, status: .delivered)
				} else {
					// FIXME:这里需要进一步添加过滤逻辑
					delegate(on: msgModel)
				}
			}
		}

	}

	func statusChange(status: ABYSocketStatus) {

	}

	private func delegate(message: Message, status: DeliveryStatus) -> Void {
		self.delegate?.messageBus(message, sendStatus: status)
	}

	/// 负责向代理分发消息
	///
	/// - Parameters:
	///   - message: 分发的消息
	private func delegate(on message: Message) -> Void {
		self.convManager.messageBus(on: message) // 分发给会话列表
		self.delegate?.messageBus(on: message) // 分发给其他的代理者（只有一个，同一时期）
	}
}

extension MessageBus {
	// 发送消息
	func send(message: Message) -> Void {
		ABYSocket.manager.send(message: message)
	}
	// 加入房间
	func joinRoom(_ room_id:Int16) -> Void {
		ABYSocket.manager.join(room: room_id)
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
		return Account.share.session_id// 返回当前用户的session_id
	}
}

