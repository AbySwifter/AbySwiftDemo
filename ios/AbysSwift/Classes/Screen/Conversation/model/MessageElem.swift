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
	// product
	case productContentVoyage = "PRODUCT_VOYAGE_ELEM"
	case productCabinElem = "PRODUCT_CABIN_ELEM"
	case productOrderElem = "PRODUCT_ORDER_ELEM"
}


/// 消息元素的尺寸
struct ImageSize: HandyJSON {
	var width: CGFloat?
	var height: CGFloat?
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

	required override init() {}


}
