//
//  ConversationManager.swift
//  AbysSwift
//
//  Created by aby on 2018/3/14.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import SwiftyJSON
import DTRequest
import DTTools

/// 会话管理类: 用来管理整个APP会话的生命周期与各个会话的消息分发
class ConversationManager : NSObject {
	static let distance = ConversationManager.init()
    private override init() {
        super.init()
        self.refreshList() // 初始化的时候刷新列表
    }
	// 网络管理类
    var net: DTNetworkManager {
        return DTNetworkManager.share
    }
    let store: ABYRealmManager  = {
        return ABYRealmManager.instance
    }()
    
	// 直接跟数据有关的属性
	var notificationArray: Array<Conversation> = [] // 存放通知消息的Array
	var conversations: Dictionary<Int16, Conversation> = [:] // 存放会话信息的Array
    var recommendReply: Dictionary<Int16, Message> = [:] // 记录推荐回复的话术
	var dataSource: ConversationManagerDeleagate?
	var waitCount: Int = 0 {
		didSet {
			if oldValue != waitCount {
				self.dataSource?.waitNumberUpdata(number: waitCount)
			}
		}
	}
    
    /// 总的未读计数
    var unreadTotal: Int {
        var totalCount: Int = 0
        for (key, item) in self.conversations {
            if key != self.atService {
                totalCount += item.unreadCount
            }
        }
        return totalCount
    }
    
	// MessageBus的实例，用来发送消息
	var bus: MessageBus {
		return MessageBus.distance
	}
    
    // 在这里记录了是不是正在服务的会话
	var atService: Int16 = -1 // 记录当前正在服务的会话ID

	// 这是一个获取数据的方法
	func initData() -> Void {
		getList() // 获取真数据
	}

	func updataConversationList(_ message: Message) -> Void {
		guard let room_id = message.room_id else { return }
        // 根据消息更新数据库
        self.conversations[room_id] = self.store.getConversation(room_id: Int(room_id))
        self.dataSource?.conversationListUpdata()
        // 每次更新会话列表的时候，跟新相关信息
        NotificationCenter.default.post(name: Notification.Name.init(LIST_UPDATE), object: nil)
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
        self.net.dt_request(request: DTRequest.request(api: Api.chatList, params: ["current_id": current_id])) { (error, result) -> (Void) in
            if let res = result {
                //                DTLog(message: res)
                guard res["state"].int == 200 else {
                    self.dataSource?.updateFail(nil, res["message"].string)
                    return
                }
                if let waitCount = res["data"]["wait_count"].int {
                    self.waitCount = waitCount
                }
                if let conversationList = res["data"]["service_list"].array {
                    //                    self.conversations.removeAll()
                    var array = [Conversation]()
                    for conversationJSON in conversationList {
                        let jsonStr = conversationJSON.rawString(.utf8, options: .prettyPrinted)
                        let conversation = Conversation.deserialize(from: jsonStr)
                        conversation?.lastMessage = conversation?.message_list.last
                        if let conv = conversation {
                            array.append(conv)
                        }
                    }
                    // 存入数据库
                    self.store.saveConversationList(array)
                    // 刷新数据
                    self.refreshList()
                }
            } else {
                self.dataSource?.updateFail(nil, "网络请求失败")
            }
        }
	}
    
}

// MARK: -处理服务相关的东西
extension ConversationManager {
	/// 修改当前正在服务的会话
	func change(atService roomID: Int16, status: Bool) -> Void {
		// 预防会话已经结束的情况
		guard let current = self.conversations[roomID] else { return }
		if status {
			// 服务房间： 1、本地已读数为 全部。2 、会话未读数为 0
			self.atService = roomID
			// 发送加入房间的消息
			bus.joinRoom(roomID)
            // 先更新本地会话已读数量
            let count = self.store.getConversationListCount(room_id: Int(current.room_id)) ?? current.totalCount
            current.message_read_count = count
            // 更新本地已读会话数量
            self.store.updateConversation(room_id: Int(current.room_id), count: count)
            reportRead(count: count, room_id: current.room_id) // 然后上报
		} else {
			// 上报已读数量
            let count = self.store.getConversationListCount(room_id: Int(current.room_id)) ?? current.totalCount
			current.message_read_count = count
            // 更新本地已读会话数量
            self.store.updateConversation(room_id: Int(current.room_id), count: count)
			reportRead(count: count, room_id: current.room_id)
			self.atService = -1
		}
	}
	/// 结束服务
	///
	/// - Parameters:
	///   - room_id: 结束的房间id
	func endService(room_id: Int16) {
        self.removeConversation(room_id: room_id)
		self.dataSource?.conversationListUpdata()
	}

    /// 上报未读消息
	func reportRead(count: Int, room_id: Int16) -> Void {
		let param: [String: Any] = ["room_id": "\(room_id)", "num": "\(count)"]
        self.net.dt_request(request: DTRequest.request(api: Api.setReadCount, params: param)) { (error, result) -> (Void) in
            if let res = result {
                DTLog("上报已读数结果：\(res)")
            }
        }
	}
    
    /// 删除会话
    func removeConversation(room_id: Int16) -> Void {
        if self.atService == room_id {
            //FIXME: 如果要删除的房间正在服务中，必须退出房间再删除
            DTLog("正在服务中的用户收到了会话超时的消息")
        }
        self.conversations[room_id] = nil
        self.store.removeConversation(roomID: room_id)
    }
}

// MARK: -数据库操作
extension ConversationManager {
    func refreshList() -> Void {
        // 取数据
       let list = self.store.getConversationList()
        // 将数据放到cnversatios里去
        self.conversations.removeAll()
        for item in list {
            self.conversations[item.room_id] = item
        }
        self.dataSource?.conversationListUpdata()
    }
}

/// MessageBus的消息分发
extension ConversationManager {
	/// 从messageBus过来的消息， 只有房间消息
	func messageBus(on message: Message) {
		let msgModel = message
		if msgModel.room_id != nil && msgModel.room_id != 0 {
			updataConversationList(msgModel)
            if msgModel.room_id! == self.atService {
                self.conversations[self.atService]?.message_read_count += 1
                self.store.updateConversation(room_id: Int(self.atService), count:  (self.conversations[self.atService]?.message_read_count)!)
            }
		}
	}
}

/// 用来处理会话列表视图更新事件的代理方法
protocol ConversationManagerDeleagate {
	func conversationListUpdata() -> Void
	func waitNumberUpdata(number: Int) -> Void
	func updateFail(_ error: Error?, _ message: String?) -> Void
    
}

