//
//  Conversation.swift
//  AbysSwift
//
//  Created by aby on 2018/3/16.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import HandyJSON

/// Conversation的类型
///
/// - NotificationType: 站内信
/// - NormalType: 会话
enum ConversationType: Int {
	case NotificationType = 1
	case NormalType = 0
}


/// 会话
class Conversation: HandyJSON {
	// MARK: -网络接口下拉的属性，主要用来处理JSON
	var headImgUrl: String?
	var room_id: Int16 = 0
	var joinTime: UInt64 = 0
	var name: String = ""
	var message_read_count = 0
	var message_list: Array<Message> = [] // 当前会话的消息列表

    var timeOffset: Int = 0 // 时间偏移量(只存储在本地)
    
	// MARK: -本地属性，用于处理本地的一些任务
	// 代理方法，用来改变Cell的东西
	var delegate: ConversationDelegate?
	var nativeReadCount: Int = 0 // 记录本地已读数
	var lastMessage: Message? {
		didSet {
			if lastMessage != nil {
				self.delegate?.lastMessageChange(text: lastMsgContent, atttributeText: contentAttributedStr)
			}
		}
	}
	var time: String = ""
	var activeTime: Int = 0 // 客服开始恢复的时间
	var type: ConversationType = .NormalType // 会话类型
	var inService: Bool = false; // 是否正在服务中
    // 存储管理员
    let store: ABYRealmManager = {
        return ABYRealmManager.instance
    }()
    
	// MARK: -Computed property
	/// 会话消息总数
	var totalCount: Int {
		return message_list.count
	}
	// 未读消息数
	var unreadCount: Int {
		get {
			let count = totalCount - message_read_count
			return count < 0 ? 0 : count
		}
	}
	// 返回最后一条消息的内容
	var lastMsgContent: String {
		var string = ""
		guard let type = lastMessage?.content?.type else { return "" }
		switch type {
		case .image:
			string = "[图片消息]"
		case .voice:
			string = "[语音消息]"
		case .text:
			string = lastMessage?.content?.text ?? ""
        case .sysAlertMessage:
            string = lastMessage?.content?.text ?? ""
		default:
//            string = "[未知消息类型]" // 避免未出现的消息类型
            string = lastMessage?.content?.text ?? "[未知类型的消息]"
		}
		return string
	}
	// 返回应该显示的内容
	var contentAttributedStr: NSMutableAttributedString {
		var unReadStr = "[\(unreadCount)条] "
		if self.unreadCount == 0 {
			unReadStr = ""
		}
		let contentStr = lastMsgContent
		let resultStr = unReadStr + contentStr
		let content = resultStr.range(of: contentStr)
		let unRead = resultStr.range(of: unReadStr)
		let result = resultStr.range(of: resultStr)
		let attributeString = NSMutableAttributedString.init(string: resultStr)
		guard let resultRange = result else { return attributeString }
		if let unReadRange = unRead {
			let unReadRange_ns = resultStr.nsRange(from: unReadRange)
			attributeString.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.init(hexString: "333333") ], range: unReadRange_ns)
		}
		if let contentRange = content {
			let contentRange_ns = resultStr.nsRange(from: contentRange)
			attributeString.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.init(hexString: "999999")], range: contentRange_ns)
		}
		let resultRange_ns = resultStr.nsRange(from: resultRange)
		attributeString.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: W750(26))], range: resultRange_ns)
		return attributeString
	}
	// 返回计时的时间字符串
	var tickTock: String {
		let date = Date.init()
		let join = TimeInterval.init(joinTime)
		let duration = date.timeIntervalSince1970 - join/1000 + Double.init(self.timeOffset)
//        ABYPrint("joinTime: \(join) duration: \(date.timeIntervalSince1970)")
		let hour = floor(duration / 3600) // 小时数
		let min = floor(duration / 60).truncatingRemainder(dividingBy: 60) // 分钟数
		let sec = floor(duration.truncatingRemainder(dividingBy: 60)) // 秒数
//        ABYPrint("hour \(hour) min\(min) sec \(sec)")
		if hour != 0 {
			return "\(Int(hour))h\(Int(min))m\(Int(sec))s"
		} else if min != 0 {
			return "\(Int(min))m\(Int(sec))s"
		} else {
			return "\(Int(sec))s"
		}
	}

	// MARK: -初始化方法
	// 指定构造器
	required init() {}
	// 便利构造器
	convenience init(type: ConversationType) {
		self.init()
		self.type = type
		switch type {
		case .NormalType:
			ABYPrint(message: "这是一个正常的会话")
		case .NotificationType:
			self.name = "通知消息"
		}
	}
	// 根据消息创建Item
	convenience init (width message: Message) {
		self.init()
		self.type = .NormalType
		self.headImgUrl = message.sender?.headImgUrl
		self.name = message.sender?.name ?? ""
		self.room_id = message.room_id ?? 0
		self.joinTime = message.msg_timestamp ?? 0
		self.lastMessage = message
        self.message_list = [message]
        if let time = message.msg_timestamp {
            let duration = TimeInterval.init(time)
            let offset = ceil(duration/1000 - Date.init().timeIntervalSince1970)
            self.timeOffset = Int(offset)
        }
	}
    
    /// 从数据库初始化对象
    convenience init(object: ConversationObject) {
        self.init()
        self.type = .NormalType // 正常会话
        self.activeTime = object.activeTime
        self.headImgUrl = object.headImgUrl
        self.name = object.nickname
        self.message_read_count = object.message_read_count
        self.joinTime = UInt64(object.join_time)
        self.lastMessage = Message.init(messageObject: object.lastMessage)
        self.message_list = object.messages // 通过计算属性返回
        self.room_id = Int16(object.room_id)
        self.timeOffset = object.timeOffset // 读取时间差
    }

	// MARK: -自定义消息格式
	func mapping(mapper: HelpingMapper) {
		mapper.specify(property: &name, name: "nickname")
		mapper.specify(property: &joinTime, name: "join_time")
		// 排除指定属性
		mapper >>> self.type
		mapper >>> self.lastMessage
		mapper >>> self.activeTime
		mapper >>> self.delegate
		mapper >>> self.inService
		mapper >>> self.time
		mapper >>> self.nativeReadCount
        mapper >>> self.timeOffset // 排除时间差的属性
	}
    
    /// 转化为数据库存储对象
    func toObject() -> ConversationObject {
        let obj = ConversationObject.init()
        obj.nickname = self.name
        obj.join_time = Int(self.joinTime)
        obj.headImgUrl = self.headImgUrl ?? ""
        obj.activeTime = Int(self.activeTime)
        obj.lastMessage = self.lastMessage?.toObject()
        obj.message_read_count = self.message_read_count
        obj.room_id = Int(self.room_id)
        obj.timeOffset = self.timeOffset
        for msg in self.message_list {
            // 根据MessageID进行筛选
            if !obj.message_list.contains(where: { (obj) -> Bool in
                return obj.messageID == msg.messageID
            }) {
                 obj.message_list.append(msg.toObject())
            }
        }
        return obj
    }
}

extension Conversation {
	func endService(complete: @escaping (_ result: Bool, _ message: String?) -> ()) -> Void {
		let params: [String: Any] = [
			"room_id": self.room_id,
			"current_id": Account.share.user?.id ?? 0,
			"session_id": Account.share.session_id,
		]
		ABYNetworkManager.shareInstance.aby_request(request: UserRouter.request(api: UserAPI.endService, params: params), callBack: { (result) -> (Void) in
			if let res = result {
				ABYPrint("\(res)")
                complete(true, nil)
            } else {
                complete(false, nil)
            }
		}) { (error) -> (Void) in
			ABYPrint("\(error)")
			
		}
	}
}

protocol ConversationDelegate {
	func lastMessageChange(text: String,atttributeText:NSMutableAttributedString) -> Void
	func unReadCountChange(count: Int) -> Void
}

