//
//  ContentObject.swift
//  AbysSwift
//
//  Created by aby on 2018/5/17.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//
import RealmSwift

class ContentObject: Object {
    @objc dynamic var messageID: String = ""
    // 类型
    @objc dynamic var type: String = ""
    // 文本消息
    @objc dynamic var text: String?
    // 语音消息
    let duration = RealmOptional<Int>()
    @objc dynamic var voice: String?
    // product
    @objc dynamic var product: String?
    // image
    @objc dynamic var image: String?
    @objc dynamic var size: ImageSizeObject?
    
    let data = List<ArticlItemObject>.init()
    
    // linkObject 所属消息的对应关系
    let message = LinkingObjects.init(fromType: MessageObject.self, property: "content")
    
    override static func primaryKey() -> String {
        return "messageID"
    }
    
}

class ImageSizeObject: Object {
    @objc dynamic var width: Float = 0
    @objc dynamic var height: Float = 0
    let content = LinkingObjects.init(fromType: ContentObject.self, property: "size")
}

class SenderObject: Object {
    @objc dynamic var sessionID: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var headImageUrl: String = ""
    
    let message = LinkingObjects.init(fromType: MessageObject.self, property: "sender")
    
    override static func primaryKey() -> String? {
        return "sessionID"
    }
}

class ArticlItemObject: Object {
    @objc dynamic var descriptionTitle: String?
    @objc dynamic var title: String?
    @objc dynamic var image: String?
    @objc dynamic var url: String = ""
    
    let content = LinkingObjects.init(fromType: ContentObject.self, property: "data")
    
    override static func primaryKey() -> String? {
        return "url"
    }
}
