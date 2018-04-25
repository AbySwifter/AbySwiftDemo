//
//  SocketDatas.swift
//  AbysSwift
//
//  Created by aby on 2018/3/26.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation
import HandyJSON

/// 封装转化到Socket的发送体里面去的东西
struct SocketData: HandyJSON {
	var domain: String = ABYSocket.domain
	var path: String = ""
	var query: String = ""
	var device: String = SystemVersion
	var ims_version: String = ABYSocket.IMS_VERSION
	var message_type: String = "client"
	var session_id: String = ""
	var type: String = ""
	var client_id: String = ""
	var body: [String: Any] = [:]
}

struct SocketSendOptions {
	var path: String = ""
	var query: String = ""
}

