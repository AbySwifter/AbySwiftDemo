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
}

class MsgSender: HandyJSON {

	var name: String?
	var headImgUrl: String?
	var sessionID: String?

	required init() {}
}


/// 消息结构
class Message: HandyJSON {
	// 需要转化的属性
	var messageID: String?
	var messageType: MessageType?
	var sender: MsgSender?
	var timestamp: UInt64? // 消息发送的时间戳
	var room_id: Int16?
	var isKH: Int?
	var msg_timestamp: UInt64? // 服务器的时间戳
	var content: MessageElem?
	// 不需要转化的属性
	required init() {}
}
