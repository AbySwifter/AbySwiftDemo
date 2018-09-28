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
import DTTools


/// 向会话页面分发消息的代理方法
protocol MessageBusDelegate {
    /// 更新房间消息，只有会话页面需要实现该方法
    ///
    /// - Parameters:
    ///   - message: 消息
    ///   - sendStatus: 消息的发送状态
    /// - Returns: 无返回值
	func messageBus(_ message: Message, sendStatus: DeliveryStatus) -> Void // 更新room消息的状态
    /// 从MessageBus过来的消息处理，主要分发聊天消息
    ///
    /// - Parameter message: 要分发的消息
    /// - Returns: 无返回值
	func messageBus(on message: Message) -> Void
    /// 分发事件消息
    ///
    /// - Parameter message: 事件消息
    /// - Returns: 无返回值
    func messageBus(onEvent message: Message) -> Void
    /// 分发自定义消息
    ///
    /// - Parameter message: 自定义消息
    /// - Returns: 无返回值
    func messageBus(onCustom message: Message) -> Void
}

// MARK: - MessageBus代理的默认实现
extension MessageBusDelegate {
	func messageBus(_ message: Message, sendStatus: DeliveryStatus) {
		DTLog("更新消息的默认实现")
	}
    func messageBus(onEvent message: Message) -> Void {
        DTLog("事件消息分发的默认实现")
    }
    func messageBus(onCustom message: Message) -> Void {
        DTLog("收到自定义消息的默认实现")
    }
}

/// 消息管理分发类
class MessageBus: ABYSocketDelegate {
    /// 消息分发类单例实例
	static let distance = MessageBus.init()
	private init() {}
    /// 消息分发代理
	var delegate: MessageBusDelegate? // 针对会话处理的代理
    /// 会话管实例
	var convManager: ConversationManager {
		return ConversationManager.distance
	}
    /// 数据库管理实例
    let store: ABYRealmManager = {
        return ABYRealmManager.instance
    }()
    /// 正在服务的房间
    var atService: Int16 {
        return self.convManager.atService
    }
    /// 从Socket接受数据的唯一接口
	func onMessage(message: JSON) {
		guard let dictionary = message.dictionaryObject else { return }
		guard let msgModel = Message.deserialize(from: dictionary) else { return }
        DTLog("收到了消息:\(message)")
		// 特殊消息的处理(首先处理超时，服务队列更新的消息#1)
		if msgModel.messageType == MessageType.sys {
			if msgModel.content?.type == .sysServiceTimeout || msgModel.content?.type ==  .sysChatTimeout {
                self.delegate?.messageBus(onEvent: msgModel)
				// 会话超时，更改数据库
                self.convManager.removeConversation(room_id: msgModel.room_id ?? 0)
			}
			if msgModel.content?.type == MSG_ELEM.sysServiceWaitCount {
				// 发送等待队列长度改变的事件
                self.convManager.waitCount = msgModel.content?.count ?? 0
			}
		}
		// 处理房间的消息(公共业务： 保存消息，更新消息总数#2)
		if msgModel.room_id != nil && msgModel.room_id != 0 {
            // 先过滤消息，再分发消息
			if msgModel.content?.type == MSG_ELEM.sysServiceEnd {
				// 排除掉服务结束的消息，收到结束服务的消息，需要让回话弹出并结束
                self.delegate?.messageBus(onEvent: msgModel)
                DTLog("收到服务结束的消息：\(msgModel.toJSON() ?? ["msg":"空的json转化"])")
                self.convManager.removeConversation(room_id: msgModel.room_id ?? 0)
            } else if msgModel.messageType == MessageType.custom {
                self.delegate?.messageBus(onCustom: msgModel)
                // FIXME: 需要在会话中处理。收到的是自定义消息， 需要过滤(1、不需要存储。2、不需要展示？看下产品信息的状态)
                if msgModel.content?.type == MSG_ELEM.customBotReply {
                    if let roomID = msgModel.room_id {
                        self.convManager.recommendReply[roomID] = msgModel
                    }
                }
            } else {
                // 存储时机要对，先存储，再更新
                self.store.update(message: msgModel) // 来的消息存起来
				// 区分是否为自己发出去的消息
				if msgModel.isKH == 0 && msgModel.sender?.sessionID == self.session_id {
					// 自己发出去的消息需要更新发送状态
					msgModel.deliveryStatus = .delivered
                    // 更新消息状态
					delegate(message: msgModel, status: .delivered)
				} else {
					// FIXME:这里需要进一步添加过滤逻辑
                    if msgModel.content?.type == .voice {
                        msgModel.isPlayed = false // 刚进入的消息自动设置为未播放
                    }
                    // 向当前代理发送消息
                    delegate(on: msgModel) // 分发除了结束服务之外的消息
				}
                // 每次来消息，先在MessageBus里处理一番，然后传递给ConversationManager去处理
                self.convManager.messageBus(on: msgModel) // 将所有消息分发到会话列表，由会话列表进行进一步处理
			}
		}
	}
    /// ssocket状态的改变
    ///
    /// - Parameter status: socketsStatus的改变
	func statusChange(status: ABYSocketStatus) {
        // 完成socket状态改变的回调
	}

	private func delegate(message: Message, status: DeliveryStatus) -> Void {
		self.delegate?.messageBus(message, sendStatus: status)
	}

	/// 负责向代理分发消息
	///
	/// - Parameters:
	///   - message: 分发的消息
	private func delegate(on message: Message) -> Void {
        if let room_id = message.room_id {
            guard room_id == self.atService else { return }
            self.delegate?.messageBus(on: message) // 分发给其他的代理者（只有一个，同一时期）
        }
	}
}

// MARK: - 发送消息、加入房间的方法
extension MessageBus {
    /// 发送消息的方法
    ///
    /// - Parameter message: 要发送的消息
	func send(message: Message) -> Void {
        // 首先简单存储消息，暂时不与会话关联，然后等到消息发送成功了以后，再与会话关联
        // 存储的时候需要过滤custom类型的消息
        if message.messageType != .custom {
             self.store.simpleUpdate(message: message)
        }
		ABYSocket.manager.send(message: message)
	}
    /// 加入房间
    ///
    /// - Parameter room_id: 房间id
	func joinRoom(_ room_id:Int16) -> Void {
        // FIXME: 提示加入房间失败
		ABYSocket.manager.join(room: room_id)
	}
    /// 添加代理
    ///
    /// - Parameter delegate: 代理
    /// - Returns: 返回整型（没有意义 ）
	func addDelegate(_ delegate: MessageBusDelegate) -> Int {
		self.delegate = delegate
//        self.delegates.append(delegate)
//        return self.delegates.count
        return 0
	}


    /// 移除代理
    ///
    /// - Parameter index: 参数暂无意义
    func removeDelegate(index: Int) -> Void {
//        if index>=0 && index < self.delegates.count {
//            self.delegates.remove(at: index)
//        } else {
//            DTLog("移除代理失败")
//        }
        self.delegate = nil
	}
}

// 存放计算属性
extension MessageBus {
    /// 返回当前用户的Session id
	var session_id: String {
		return Account.share.session_id// 返回当前用户的session_id
	}
}

