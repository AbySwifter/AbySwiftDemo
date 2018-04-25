//
//  WebSocketManager.swift
//  AbysSwift
//
//
//  Created by aby on 2018/3/26.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON
import HandyJSON

/// WebSocket管理类的单例
class ABYSocket: WebSocketDelegate {
	// 静态属性
	static let domain:String = URLinfo.domain.rawValue
	static let IMS_VERSION = "1.0.0"
	static let socketUrl: String = URLinfo.socketUrl.rawValue
	static let manager = ABYSocket.init()
	private init() {
		self.delegates.append(MessageBus.distance)
		self.delegates.append(ConversationManager.distance)
	}

	lazy var webSocket: WebSocket = {
		let temp: WebSocket = WebSocket.init(url: URL.init(string: ABYSocket.socketUrl)!)
		temp.delegate = self
		return temp
	}()
	var delegates: [ ABYSocketDelegate ] = [] // Socket的代理
	var session_id: String = "" // IMS登录的标志
	var sessionIDGetTime: Int32 = 0 // 获取Session的时间戳
	var loginPath: SocketSendOptions = SocketSendOptions.init(path: "api/ims/login", query: "")
	let client_id: String = newGUID()
	var loginInfo:[String: Any]?
	var isIMSLogin: Bool {
		return session_id != ""
	}
	var needReConnected: Bool = false
	/// 链接Socket
	private func connect() -> Void {
		needReConnected = true
		webSocket.connect()
		// 连接之后等待5秒检测是否链接成功
		DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
			if self.webSocket.isConnected {
				// 链接成功
				if !self.isIMSLogin {
					self.connect()
				}
			} else {
				// 未连接成功
				self.connect()
			}
		}
	}
	/// 断开链接
	func disConnect() -> Void {
		needReConnected = false
		webSocket.disconnect()
	}


	/// Socket发送消息的方法
	///
	/// - Parameters:
	///   - options: 发送选项
	///   - body: 发送内容
	private func send(options: SocketSendOptions, body: [String: Any] ) -> Void {
		var socketData: SocketData = SocketData.init()
		socketData.path = options.path
		socketData.query = options.query
		socketData.body = body
		socketData.session_id = self.session_id
		socketData.client_id = self.client_id
		let jsonStr = socketData.toJSONString()
		if let socketStr = jsonStr {
			webSocket.write(string: socketStr)
		}
	}

	//MARK: socket登录相关的方法
	func login(options: SocketSendOptions?, userInfo: Dictionary<String,String>) -> Void {
		if let loginPath = options {
			self.loginPath = loginPath
		}
		self.loginInfo = userInfo
		connect()
	}
	func loginOut() -> Void {
		self.disConnect()
		self.loginInfo = nil
		self.session_id = ""
	}

	/// 发送Socket消息，获取SessionID
	func getSessionID() -> Void {
		guard let loginInfo = self.loginInfo else {return}
		send(options: loginPath, body: loginInfo)
	}


	// MARK: WebSocketDelegate
	// 每次socket链接上的时候，都会调用此方法
	func websocketDidConnect(socket: WebSocketClient) {
//		ABYPrint(message: "Socket 已经连接")
		// Socket链接上的时候，根据是否登录来处理消息
		getSessionID()
	}

	func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
		ABYPrint(message: "Socket 断开链接")
		if needReConnected {
			if let loginInfo = self.loginInfo {
				login(options: nil, userInfo: loginInfo as! Dictionary<String, String>)
			} else {
				connect()
			}
		}
		for item in delegates {
			item.statusChange(status: .socketDisconnect)
		}
	}

	func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
		let msgBody = JSON.init(parseJSON: text) // 将收到的消息转化为Json格式
		if let session_id = msgBody["session_id"].string, let getTime = msgBody["msg_timestamp"].int32 {
			if sessionIDGetTime <= getTime {
				self.session_id = session_id
				for item in delegates {
					item.statusChange(status: .loginSuccess)
				}// 发送登录成功的回调
			}
			self.sessionIDGetTime = getTime
			ABYPrint("IM: 收到IM登录消息\(msgBody)")
		} else if let msgType = msgBody["type"].string {
			if msgType == "type" {
				let pongString = "{\"type\": \"pong\"}"
				self.webSocket.write(string: pongString)
			}
		} else if msgBody["messageType"].string != nil {
			for item in delegates {
				item.onMessage(message: msgBody)
			}
		} else {
			ABYPrint(message: "其他消息:\(msgBody)")
		}
	}

	func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//		ABYPrint(message: "Sokcet 收到数据\(data)")
	}
}

extension ABYSocket {
	func send(message: Message) -> Void {
	    let options = SocketSendOptions.init(path: "api/ims/send_to_group", query: "")
		self.send(options: options, body: message.toJSON()!)
	}
}
