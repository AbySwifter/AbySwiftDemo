//
//  ConversationObject.swift
//  AbysSwift
//
//  Created by aby on 2018/5/17.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//
import RealmSwift


/// 会话表
class ConversationObject: Object {
    @objc dynamic var room_id: Int = 0
    @objc dynamic var nickname: String = ""
    @objc dynamic var join_time: Int = 0
    @objc dynamic var message_read_count: Int = 0
    @objc dynamic var headImgUrl: String = ""
    @objc dynamic var activeTime: Int = 0
    
    @objc dynamic var isEnded: Bool = false // 标记会话是否结束的字段,目前暂时只在本地存储
    @objc dynamic var atService: Int = -1 // 默认不在服务
    @objc dynamic var timeOffset: Int = 0 // 会话时间差，只存储在本地
    
    @objc dynamic var lastMessage: MessageObject?
    let message_list = List<MessageObject>.init()
     // 会话id，主键
    override static func primaryKey() -> String? {
        return "room_id"
    }
    
    // 可以用来索引的键
    override static func indexedProperties() -> [String] {
        return ["room_id"]
    }
}

extension ConversationObject {
    var messages: [Message] {
        var list = [Message]()
        for msgObj in self.message_list {
            list.append(Message.init(messageObject: msgObj))
        }
        return list
    }
    
    var simpleUpdateValue: [String: Any] {
        return ["room_id": self.room_id, "timeOffset": self.timeOffset]
    }
}
