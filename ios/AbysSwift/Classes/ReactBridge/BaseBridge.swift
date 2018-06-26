//
//  BaseBridge.swift
//  AbysSwift
//
//  Created by aby on 2018/4/13.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//
//
// 与RN的通讯类，肩负着与RN沟通的重任

import UIKit
import DTTools

@objc(BaseBridge)
class BaseBridge: NSObject {
    
	@objc func addEvent(_ name: String, location: String, date: NSNumber, resolver: (NSObject) -> (), rejecter: (NSString, NSString, NSError) -> () ) -> Void {
		// Date is ready to use!
		DTLog("\(Thread.current)")
		let result = ["good"] as NSArray
		resolver(result)
	}

	@objc func nativePop() -> Void {
		NotificationCenter.default.post(name: Notification.Name.init(kBridgeDismiss), object: nil, userInfo: nil)
	}

	@objc func changeTab(_ hidden:Bool) -> Void {
		NotificationCenter.default.post(name: Notification.Name.init(kBridgeHidenTab), object: nil, userInfo: ["status": hidden])
	}
    
    @objc func passJSON(_ value: String, type: String) -> Void {
        DTLog("从JS接受消息\(value), 类型为\(type)")
        if type == "MSG_ELEM" {
            // 说明是消息体，需要包装并发送
            BaseBridgeCenter.center.delegate?.onJSONString(value: value)
        }
    }
}
