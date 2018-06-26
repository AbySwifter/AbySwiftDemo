//
//  BaseBridgeCenter.swift
//  AbysSwift
//
//  Created by aby on 2018/5/30.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import DTTools

protocol BridgeCenterDelegate {
    func onJSONString(value: String) -> Void
}

extension BridgeCenterDelegate {
    func onJSONString(value: String) -> Void {
        DTLog("默认的消息到达方法\(value)")
    }
}

class BaseBridgeCenter {
    static let center = BaseBridgeCenter.init()
    private init() {}
    var delegate: BridgeCenterDelegate?
}
