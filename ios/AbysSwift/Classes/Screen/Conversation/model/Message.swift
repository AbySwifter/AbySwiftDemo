//
//  Message.swift
//  AbysSwift
//
//  Created by aby on 2018/3/27.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import HandyJSON


/// 消息类型枚举
///
/// - sys: 系统消息
/// - chat: 聊天消息
/// - custom: 用户消息
enum MessageType: String, HandyJSONEnum {
	case sys = "SYS_TYPE"
	case chat = "CHAT_TYPE"
	case custom = "CUSTOM_TYPE"
	// 特殊模型，用来显示时间，服务器没有这个模型
	case time = "time"
}

enum DeliveryStatus: String {
	case failed = "SEND_FAIL"
	case delivering = "SENDING"
	case delivered = "SEND_SUCC"
}

class MsgSender: HandyJSON {

	var name: String?
	var headImgUrl: String?
	var sessionID: String?

	required init() {}

	convenience init(isKH: Bool = false) {
		self.init()
		guard !isKH else { return }
		guard let user = Account.share.user else {
			ABYPrint("waring: 消息发送的时候，用户信息无法获取")
			return
		}
		name = user.name
		headImgUrl = user.avatar
		sessionID = ABYSocket.manager.session_id
	}
}

/// 消息结构
class Message: HandyJSON {
	// 需要转化的属性
	var messageID: String? // 在发送的时候自己生成
	var messageType: MessageType? // 发送的时候自己定制咯
	var sender: MsgSender? // 消息来源
	var timestamp: UInt64? // 消息发送的时间戳
	var room_id: Int16?
	var isKH: Int?
	var msg_timestamp: UInt64? // 服务器的时间戳
	var content: MessageElem?
	// 不需要转化的属性
	required init() {}

	var deliveryStatus: DeliveryStatus = DeliveryStatus.delivered // 默认发送成功
	var cellHeight: CGFloat = 0
	var showTime: Bool = false
	// 排除指定属性的方法
	func mapping(mapper: HelpingMapper) {
		mapper >>> self.cellHeight // 消息的高度，只在本地存储
		mapper >>> self.deliveryStatus // 消息发送的状态，只在本地存储
		mapper >>> self.showTime // 是否需要显示时间
	}

}

extension Message {
	// 判断是否是自己发送的消息
	var isSelf: Bool {
		return isKH == 0
	}
	// 获取发送姓名
	var senderName: String {
		guard let name = sender?.name else { return "匿名用户" }
		guard name != "" else {
			return "匿名用户"
		}
		return name
	}

	// 发送时间的处理
	var timeStr: String {
		guard let timeSt = self.timestamp else { return "" }
		let time = TimeInterval.init(timeSt/1000)
		let str = KKChatMsgDataHelper.shared.chatTimeString(with: time)
		return str
	}
}

extension Message {

	// 初始化时间消息模型
	convenience init(time: UInt64) {
		self.init()
		self.messageType = MessageType.time
		self.messageID = newGUID()
		self.timestamp = time
	}

	// 初始化文本消息
	convenience init(text: String, room_id: Int16, isKH: Bool = false) {
		self.init()
		self.messageID = newGUID()
		self.messageType = MessageType.chat
		self.sender = MsgSender.init(isKH: false)
		let timeNum = (Date.init().timeIntervalSince1970) * 1000
		self.timestamp = UInt64.init(timeNum)
		self.room_id = room_id
		self.isKH = isKH ? 1 : 0 //自己发送的为0
		self.content = MessageElem.init(text: text)
	}
}


