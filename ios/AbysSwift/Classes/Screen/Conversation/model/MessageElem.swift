//
//  MessageElem.swift
//  AbysSwift
//
//  Created by aby on 2018/3/28.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import HandyJSON

enum MSG_ELEM: String, HandyJSONEnum {
	case text = "TEXT_MSG"
	case voice = "VOICE_MSG"
	case image = "IMG_MSG"
	// System
	case sysCustomerJoin = "SYS_CUSTOMER_JOIN"
	case sysServiceStart = "SYS_SERVICE_START"
	case sysEvaluateStart = "SYS_EVALUATE_START" // 评价消息
	case sysCustomerEvaluate = "SYS_CUSTOMER_EVALUATE" // 客户评价
	case sysServiceEnd = "SYS_SERVICE_END"
	case sysServiceSwitch = "SYS_SERVICE_SWITCH" // 切换客服
	case sysChatTimeout = "SYS_CHAT_TIMEOUT" // 会话超时消息
	case sysServiceTimeout = "SYS_SERVICE_TIMEOUT" // 服务超时
	case sysServiceWaitCount = "SYS_SERVICE_WAIT_COUNT" // 等待队列消息
    case sysAlertMessage = "SYS_ALERT_MESSAGE" // 该用户已经离开服务
    // custom
    case customBotReply = "BOT_REPLY_ELEM" // 自动回复的消息，无需保存，无需记录，过滤掉
    case customproductReply = "PRODUCT_PATTERN_REPLY_ELEM" // 自动回复的铲平推荐
    case h5Evaluate = "H5_CUSTOMER_EVALUATE_ELEM" // H5的回复消息
	// product
	case productContentVoyage = "PRODUCT_VOYAGE_ELEM"
	case productCabinElem = "PRODUCT_CABIN_ELEM"
	case productOrderElem = "PRODUCT_ORDER_ELEM"
    // article
    case articleElem = "ARTICLE_ELEM"
}


/// 消息元素的尺寸
struct ImageSize: HandyJSON {
	var width: CGFloat?
	var height: CGFloat?
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.width <-- TransformOf.init(fromJSON: { (rawValue: Float?) -> CGFloat? in
                if let value = rawValue {
                    return CGFloat.init(value)
                }
                return nil
            }, toJSON: { (rawValue: CGFloat?) -> Float? in
                if let value = rawValue {
                    return Float.init(value)
                }
                return nil
            })
        mapper <<<
            self.height <-- TransformOf.init(fromJSON: { (rawValue: Float?) -> CGFloat? in
                if let value = rawValue {
                    return CGFloat.init(value)
                }
                return nil
            }, toJSON: { (rawValue: CGFloat?) -> Float? in
                if let value = rawValue {
                    return Float.init(value)
                }
                return nil
            })
    }
    init() {}
    init(width: CGFloat?, height: CGFloat?) {
        self.width = width
        self.height = height
    }
    // 从数据库初始化
    init(object: ImageSizeObject?) {
        let w = CGFloat.init(object?.width ?? 0)
        let h = CGFloat.init(object?.height ?? 0)
        self.init(width: w, height: h)
    }
    // 转化为数据库对象
    func toObject() -> ImageSizeObject? {
        guard let width = self.width else {
            return nil
        }
        guard let height = self.height else {
            return nil
        }
        if width == 0 || height == 0 {
            return nil
        }
        let obj = ImageSizeObject.init()
        obj.width = Float(width)
        obj.height = Float(height)
        return obj
    }
}

/// 消息元素
class MessageElem: NSObject, HandyJSON {
	var type: MSG_ELEM?
	// text
	var text: String?
	// voice
	var duration: Int?
	var voice: String?
	// image
	var image: String?
	var size: ImageSize?

    // system
    var count: Int = 0
    // custom
    var product: String?
    var message: String?
    var reply: String?
    var is_bot: Int = 0
    // Article
    var data: [ArticlItem] = [ArticlItem]()
    
	required override init() {}
    
    func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.reply <-- ("content", TransformOf.init(fromJSON: { (rawValue: Dictionary<String, String>?) -> String? in
                if let dic = rawValue {
                    return dic["reply"]
                }
                return ""
            }, toJSON: { (value:String?) -> Dictionary<String, String>? in
                return nil
            }))
        mapper <<<
            self.message <-- ("content", TransformOf.init(fromJSON: { (rawValue: Dictionary<String, String>?) -> String? in
                if let dic = rawValue {
                    return dic["message"]
                }
                return ""
            }, toJSON: { (value:String?) -> Dictionary<String, String>? in
                return nil
            }))
        
    }
}

extension MessageElem {
	/// 文本消息元素的初始化
	convenience init(text: String) {
		self.init()
		self.text = text
		self.type = MSG_ELEM.text
	}
    
    /// 语音消息元素的初始化
    convenience init(duration: Int, voice: String) {
        self.init()
        self.type = MSG_ELEM.voice
        self.duration = duration
        self.voice = voice
    }
    /// 图片消息元素的初始化
    convenience init(imagePath: String, size: CGSize) {
        self.init()
        self.type = MSG_ELEM.image
        self.image = imagePath
        let imageSize = ImageSize.init(width: size.width, height: size.height)
        self.size = imageSize
    }
    
    // 从数据库初始化
    convenience init(object: ContentObject?) {
        self.init()
        guard let obj = object else {
            return
        }
        self.type = MSG_ELEM.init(rawValue: obj.type) ?? MSG_ELEM.text
        self.text = obj.text
        self.duration = obj.duration.value
        self.voice = obj.voice
        self.image = obj.image
        self.size = ImageSize.init(object: obj.size)
        self.product = obj.product
        // FIXME: 消息初始化的拓展
        for itemObj in obj.data {
            let item = ArticlItem.init(object: itemObj)
            self.data.append(item)
        }
    }
    
    // 转化为数据库对象
    func toObject() -> ContentObject {
        let object = ContentObject.init()
        object.type = self.type?.rawValue ?? MSG_ELEM.text.rawValue
        object.text = self.text
        object.voice = self.voice
        object.duration.value = self.duration
        object.image = self.image
        object.size = self.size?.toObject()
        object.product = self.product
        for item in self.data {
            let obj = item.toObject()
            object.data.append(obj)
        }
        // FIXME: 消息类型的拓展
        return object
    }
}
