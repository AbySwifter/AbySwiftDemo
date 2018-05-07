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
		sessionID = Account.share.session_id
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

    var delegate: MessageStatusChangeDelegate? // 更新Cell的状态
	var deliveryStatus: DeliveryStatus = DeliveryStatus.delivered // 默认发送成功
	var cellHeight: CGFloat = 0
	var showTime: Bool = false
    /// 网络管理员
    lazy var networkManager: ABYNetworkManager = {
        return ABYNetworkManager.shareInstance
    }()
	// 排除指定属性的方法
	func mapping(mapper: HelpingMapper) {
		mapper >>> self.cellHeight // 消息的高度，只在本地存储
		mapper >>> self.deliveryStatus // 消息发送的状态，只在本地存储
		mapper >>> self.showTime // 是否需要显示时间
        mapper >>> self.networkManager // 排除网管
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

	/// 发送时间的处理
	var timeStr: String {
		guard let timeSt = self.timestamp else { return "" }
		let time = TimeInterval.init(timeSt/1000)
		let str = KKChatMsgDataHelper.shared.chatTimeString(with: time)
		return str
	}
}

// MARK: - 各种消息的初始化方法
extension Message {
	/// 初始化文本消息
	convenience init(text: String, room_id: Int16, isKH: Bool = false) {
		self.init()
		self.messageID = newGUID()
		self.messageType = MessageType.chat
		self.sender = MsgSender.init(isKH: isKH)
		let timeNum = (Date.init().timeIntervalSince1970) * 1000
		self.timestamp = UInt64.init(timeNum)
		self.room_id = room_id
		self.isKH = isKH ? 1 : 0 //自己发送的为0
		self.content = MessageElem.init(text: text)
	}
    
    /// 初始化语音消息
    convenience init(elem: MessageElem, room_id: Int16, messageID: String, isKH: Bool = false) {
        self.init()
        self.messageID = messageID
        self.messageType = MessageType.chat
        self.sender = MsgSender.init(isKH: isKH)
        let timeNum = (Date.init().timeIntervalSince1970) * 1000 // 时间戳
        self.timestamp = UInt64.init(timeNum)
        self.room_id = room_id
        self.isKH = isKH ? 1 : 0 // 自己发送的为0
        self.content = elem
    }
}

// MARK: -处理语音消息，图片消息的上传，以及消息的发送
extension Message {
    func uploadeVoice() -> Void {
        guard let url = self.content?.voice else { return }
        if url.contains("http") {
            // 不需要上传，直接发送
            return
        } else {
//             开始上传，上传完毕后进行发送
            self.networkManager.aby_upload(path: url, fileName: "voice.aac", type: .audio) { (json) -> (Void) in
                ABYPrint(Thread.current)
                if let result = json {
                    ABYPrint("上传成功：\(result)")
                    // 上传成功后就发送消息
                    self.content?.voice = result["data"]["file"].string
                    if self.content?.voice != nil {
                        self.send()
                    } else {
                        // 上传失败
                        self.deliveryStatus = .failed // 上传失败就说明发送失败咯
                        self.delegate?.messageStatusChange(self.deliveryStatus)
                    }
                } else {
                    // 上传失败
                    self.deliveryStatus = .failed // 上传失败就说明发送失败咯
                    self.delegate?.messageStatusChange(self.deliveryStatus)
                }
            }
        }
    }
    
    func deliver() -> Void {
        guard let type = self.content?.type else { return }
        self.deliveryStatus = .delivering
        self.delegate?.messageStatusChange(self.deliveryStatus)
        switch type {
        case .text:
            self.send()
        case .voice:
            self.uploadeVoice()
        default:
            break
        }
        let timeout = DispatchTime.now() + 5.0
        DispatchQueue.main.asyncAfter(deadline: timeout) {
            // 5秒后还在发送，就默认为发送失败
            if self.deliveryStatus == .delivering {
                self.deliveryStatus = .failed
                self.delegate?.messageStatusChange(self.deliveryStatus)
            }
        }
    }

    private func send() -> Void {
        ABYSocket.manager.send(message: self)
    }
}

protocol MessageStatusChangeDelegate {
    func messageStatusChange(_ status: DeliveryStatus) -> Void
}
