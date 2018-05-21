//
//  RealmManagerOperator.swift
//  AbysSwift
//
//  Created by aby on 2018/5/17.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation

// MARK: - 会话列表的存、取、改
extension ABYRealmManager {
    // 取出在数据库中的所有会话
    func getConversationList() -> [Conversation] {
        var list: [Conversation] = []
        guard let realm = self.realm else { return list }
        let result = realm.objects(ConversationObject.self)
        // 将所查到的结果转化为列表
        for obj in result {
            let messagesResult = realm.objects(MessageObject.self).filter("isSendSuccess == %@ AND room_id == %@", false, obj.room_id)
            var messageList: [Message] = []
            for item in messagesResult {
                messageList.append(Message.init(messageObject: item))
            }
            let conv = Conversation.init(object: obj)
            conv.message_list = conv.message_list + messageList
            conv.message_list.sort { (m1, m2) -> Bool in
                return m1.timestamp ?? 0 < m2.timestamp ?? 0
            }
            list.append(conv)
        }
        return list
    }
    
    // 存入会话列表
    func saveConversationList(_ list: [Conversation]) -> Void {
        guard let realm = self.realm else { return }
        do {
            var tempList = [ConversationObject]()
            let messages = realm.objects(MessageObject.self).filter("isPlayed == %@ OR isSendSuccess == %@", false, false)
            var temp: [[String: Any]] = []
            for msg in messages {
                temp.append(msg.simpleUpdateValue)
            }
            for conv in list {
                let obj = conv.toObject()
                tempList.append(obj)
            }
            try realm.write {
                realm.add(tempList, update: true)
                for item in temp {
                    realm.create(MessageObject.self, value: item, update: true)
                }
            }
        } catch let error as NSError {
            ABYPrint("保存会话列表时出错\(error)")
        }
    }
    
    /// 保存会话
    func save(conversation: Conversation) -> Void {
        guard let realm = self.realm else {
            return
        }
        do {
            let obj = conversation.toObject()
            realm.beginWrite()
            realm.add(obj, update: true)
            try realm.commitWrite()
        } catch let error as NSError {
            ABYPrint(error)
        }
    }
    
    /// 根据Room_ID删除会话的房间
    func removeConversation(roomID: Int16) -> Void {
        guard let realm = self.realm else { return }
        do {
            let conversation = realm.object(ofType: ConversationObject.self, forPrimaryKey: Int(roomID))
            if let obj = conversation {
                try realm.write {
                    realm.delete(obj)
                }
            }
        } catch let error as NSError {
            ABYPrint("删除会话出错\(error)")
        }
    }
    /// 更新消息并更新消息列表
    func update(message: Message) -> Void {
        guard let realm = self.realm else { return }
        do {
            let roomid = Int(message.room_id ?? -1)
            guard roomid != -1 else { return }
            // 获取该更新的会话
            realm.beginWrite()
            var conversation = realm.object(ofType: ConversationObject.self, forPrimaryKey: roomid)
            // 如果会话不存在，就创建会话
            if conversation == nil {
                let con = Conversation.init(width: message)
                conversation = con.toObject()
            } else {
                let msgObj = message.toObject()
                conversation!.message_list.append(msgObj)
                conversation!.lastMessage = msgObj
            }
            realm.add(conversation!, update: true)
            try realm.commitWrite()
        } catch let error as NSError {
            ABYPrint("更新消息出错\(error)")
        }
    }
        
    /// 简单更新消息（主要是更新消息的发送状态，以及消息的播放状态）
    func simpleUpdate(message: Message) -> Void {
        guard let realm = self.realm else { return }
        do {
            try realm.write {
                realm.add(message.toObject(), update: true)
            }
        } catch let error as NSError {
            ABYPrint("简单更新消息\(error)")
        }
    }
    
    /// 根据房间号获取会话
    func getConversation(room_id: Int) -> Conversation? {
        guard let realm = self.realm else { return nil }
        let conObj = realm.object(ofType: ConversationObject.self, forPrimaryKey: room_id)
        guard let obj = conObj else { return nil }
        let conversation = Conversation.init(object: obj)
        return conversation
    }
}
