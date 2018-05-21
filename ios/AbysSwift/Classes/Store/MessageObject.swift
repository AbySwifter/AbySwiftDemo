//
//  MessageObject.swift
//  AbysSwift
//
//  Created by aby on 2018/5/17.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import RealmSwift

class MessageObject: Object {
    // 主键
    @objc dynamic var messageID: String = ""
    @objc dynamic var room_id: Int = 0
    let isKH = RealmOptional<Int>()
    @objc dynamic var sender: SenderObject?
    @objc dynamic var timestamp: Int = 0
    @objc dynamic var messageType: String = MessageType.chat.rawValue
    
    @objc dynamic var content: ContentObject?
    // 仅仅在本地存储的数据
    @objc dynamic var isPlayed: Bool = true // 语音消息是否播放
    @objc dynamic var isSendSuccess: Bool = true // 是否发送成功
   
    // 连接键
    let room = LinkingObjects.init(fromType: ConversationObject.self, property: "message_list")
    
    // 定义主键
    override static func primaryKey() -> String? {
        return "messageID"
    }
    
    var simpleUpdateValue: [String: Any] {
        return ["messageID": self.messageID, "isPlayed": isPlayed, "isSendSuccess": isSendSuccess]
    }
}
