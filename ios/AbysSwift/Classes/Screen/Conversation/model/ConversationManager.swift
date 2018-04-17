//
//  ConversationManager.swift
//  AbysSwift
//
//  Created by aby on 2018/3/14.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import SwiftyJSON

let MSG_NOTIFICATION = "msg_event_notification"
/// 会话管理类: 用来管理整个APP会话的生命周期与各个会话的消息分发
class ConversationManager: ABYSocketDelegate {
	static let distance = ConversationManager.init()
	private init() {
		ABYSocket.manager.delegate = self
	}
	// 网络管理类
	let networkManager: ABYNetworkManager = {
		return ABYNetworkManager.shareInstance
	}()

	// 直接跟数据有关的属性
	var notificationArray: Array<Conversation> = [] // 存放通知消息的Array
	var conversations: Dictionary<Int16, Conversation> = [:] // 存放会话信息的Array
	var dataSource: ConversationManagerDeleagate?
	var waitCount: Int = 0 {
		didSet {
			if oldValue != waitCount {
				self.dataSource?.waitNumberUpdata(number: waitCount)
			}
		}
	}
	// 这是一个获取数据的方法
	func initData() -> Void {
		getList() // 获取真数据
	}

	func updataConversationList(_ message: Message) -> Void {
		guard let room_id = message.room_id else { return }
		let isHanve = conversations.keys.contains(room_id)
		if isHanve {
			// 已经存在房间
			let conversation = self.conversations[room_id]
			//加入房间的聊天列表去
			conversation?.lastMessage = message
			conversation?.message_list.append(message)
		} else {
			// 不存在房间，创建房间并添加到房间的字典中去
			createConversation(width: message)
			self.dataSource?.conversationListUpdata()
		}
	}

	// 通过消息创建会话（场景：新来会话的时候）
	func createConversation(width message: Message) -> Void {
		let conversation: Conversation = Conversation.init(width: message)
		conversation.message_list.append(message)
		conversations[conversation.room_id] = conversation
	}

	// MARK: -网络请求数据方法

	/// 获取当前会话列表
	func getList() -> Void {
		guard let current_id = Account.share.user?.id else { return  }
		self.networkManager.aby_request(request: UserRouter.chatList(params: ["current_id": current_id])) { (result: JSON?) -> (Void) in
			if let res = result {
//				ABYPrint(message: res)
				guard res["state"].int == 200 else {
					self.dataSource?.updateFail(nil, res["message"].string)
					return
				}
				if let waitCount = res["data"]["wait_count"].int {
					self.waitCount = waitCount
				}
				if let conversationList = res["data"]["service_list"].array {
					self.conversations.removeAll()
					for conversationJSON in conversationList {
						let jsonStr = conversationJSON.rawString(.utf8, options: .prettyPrinted)
						let conversation = Conversation.deserialize(from: jsonStr)
						conversation?.lastMessage = conversation?.message_list.last
						if let room_id = conversation?.room_id {
							self.conversations[room_id] = conversation
						}
					}
					self.dataSource?.conversationListUpdata()
				}
			} else {
				self.dataSource?.updateFail(nil, "网络请求失败")
			}
		}
	}

	// MARK: -Message listener FIXME: -这部分代码需要解耦出去
	/// 消息监听的代理方法，直接从Socket中处理消息
	///
	/// - Parameter message: JSON格式的消息体
	func onMessage(message: JSON) {
		// 处理有关房间会话的业务
		guard let dictionary = message.dictionaryObject else { return }
		ABYPrint(message: "收到消息:\(dictionary)")
		guard let msgModel = Message.deserialize(from: dictionary) else { return }
		if (msgModel.messageType == .sys) {
			// 处理超时退出会话
			if (msgModel.content?.type == .sysServiceTimeout) {

				return
			}
			// 处理等待服务队列消息
			if (msgModel.content?.type == .sysServiceWaitCount) {

				return
			}
		}
		// TODO: 其次处理房间消息，优先级#2
		if msgModel.room_id != nil && msgModel.room_id != 0 {
			updataConversationList(msgModel)
		}
		// 暂时用通知中心去处理消息的全局分发
		NotificationCenter.default.post(name: .init(MSG_NOTIFICATION), object: nil, userInfo: [0: msgModel])
	}


	func statusChange(status: ABYSocketStatus) {

	}
}


/// 用来处理会话列表视图更新事件的代理方法
protocol ConversationManagerDeleagate {
	func conversationListUpdata() -> Void
	func waitNumberUpdata(number: Int) -> Void
	func updateFail(_ error: Error?, _ message: String?) -> Void
}
