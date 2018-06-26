//
//  RealmManagerOperator.swift
//  AbysSwift
//
//  Created by aby on 2018/5/17.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation
import DTTools

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
            let conv = Conversation.init(object: obj)
            for item in messagesResult {
                let isContain = conv.message_list.contains { (msg) -> Bool in
                    return msg.messageID == item.messageID
                }
                if !isContain {
                     conv.message_list.append(Message.init(messageObject: item))
                } else {
                    try? realm.write {
                        item.isSendSuccess = true
                    }
                }
            }
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
            // 首先过滤本地属性（包括发送失败的消息和未播放的音频消息）
            let messages = realm.objects(MessageObject.self).filter("isPlayed == %@ OR isSendSuccess == %@", false, false)
            var temp: [[String: Any]] = []
            for msg in messages {
                temp.append(msg.simpleUpdateValue)
            }
            // 其次过滤本地会话存储的时间差
            let conversations = realm.objects(ConversationObject.self).filter("timeOffset!=0")
            var tempC: [[String: Any]] = []
            for conv in conversations {
               tempC.append(conv.simpleUpdateValue)
            }
            // 开始存列表
            for conv in list {
                let conObj = realm.object(ofType: ConversationObject.self, forPrimaryKey: Int(conv.room_id))
                let obj = conv.toObject()
                if let readCont = conObj?.message_read_count {
                    obj.message_read_count = readCont > obj.message_read_count ? readCont : obj.message_read_count
                }
                tempList.append(obj)
            }
            try realm.write {
                realm.add(tempList, update: true)
                for item in temp {
                    realm.create(MessageObject.self, value: item, update: true)
                }
                for item in tempC {
                    realm.create(ConversationObject.self, value: item, update: true)
                }
            }
        } catch let error as NSError {
            DTLog("保存会话列表时出错\(error)")
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
            DTLog(error)
        }
    }
    
    /// 根据Room_ID删除会话的房间
    func removeConversation(roomID: Int16) -> Void {
        guard let realm = self.realm else { return }
        do {
            let conversation = realm.object(ofType: ConversationObject.self, forPrimaryKey: Int(roomID))
            if let obj = conversation {
                try realm.write {
                    realm.delete(obj.message_list)
                    realm.delete(obj)
                }
            }
        } catch let error as NSError {
            DTLog("删除会话出错\(error)")
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
                let con = Conversation.init(width: message) // 创建会话的时候去处理时间差
                conversation = con.toObject()
                DTLog("会话的时间差为：\(con.timeOffset)")
            } else {
                let msgObj = message.toObject()
                realm.add(msgObj, update: true)
                // 如果不包含这条消息, 包含这条消息的意义是更新了消息的状态
                let isExist = conversation!.message_list.contains { (obj) -> Bool in
                    return obj.messageID == msgObj.messageID
                }
                if !isExist {
                    conversation!.message_list.append(msgObj)
                    conversation!.lastMessage = msgObj
                }
            }
            if conversation!.room_id == Int(ConversationManager.distance.atService) {
                conversation!.message_read_count = conversation!.message_list.count
            }
            realm.add(conversation!, update: true)
            try realm.commitWrite()
        } catch let error as NSError {
            DTLog("更新消息出错\(error)")
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
            DTLog("简单更新消息\(error)")
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
    
    /// 更新会话已读数
    func updateConversation(room_id: Int, count: Int) -> Void {
        guard let realm = self.realm else { return }
        let convObj = realm.object(ofType: ConversationObject.self, forPrimaryKey: room_id)
        guard let obj = convObj else { return }
        do {
            try realm.write {
                obj.message_read_count = count
            }
        } catch let error as NSError {
            DTLog("更改会话已读数有误：\(error)")
        }
        
    }
    /// 获取当前会话列表的消息数
    func getConversationListCount(room_id: Int) -> Int? {
        guard let realm = self.realm else { return nil }
        let convObj = realm.object(ofType: ConversationObject.self, forPrimaryKey: room_id)
        guard let obj = convObj else { return nil }
        let result = obj.message_list.filter("isSendSuccess==true")
        return result.count
    }
}
