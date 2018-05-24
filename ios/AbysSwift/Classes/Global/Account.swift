//
//  Account.swift
//  AbysSwift
//
//  Created by aby on 2018/2/8.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import Alamofire

struct User:Codable {
//	var username:String = ""
	var email:String = ""//
//	var password: String = ""
	var number: String = ""//
	var id: Int64 = 0//
	var role_id: Int64 = 0//
	var name: String = ""//
	var avatar: String = ""//
	var real_name: String = "" //
	var is_online: Int = 1//
	var company_id:Int = -1 // 公司id
	var active: Int = -1//
	var created_at: String = ""//
	var updated_at: String = ""//
}

protocol LoginProtocol {
	func accountLoginSuccess() -> Void
	func accountLoginFail(_ reson: String?) -> Void
}

/// 用户管理类
class Account {
	static let share = Account.init()

	let updateUserInfoKey = "UpdateUserInfoKey"

	let networkManager: ABYNetworkManager = {
		return ABYNetworkManager.shareInstance
	}()
	let userPath: String = NSHomeDirectory() + "/Documents/user.data"
	var delegate: LoginProtocol?
	var user: User? {
		didSet {
			NotificationCenter.default.post(Notification.init(name: Notification.Name.init(updateUserInfoKey)))
			if let email = user?.email {
				guard email == oldValue?.email else { return } // 如果email没有变化的话，不需要重新登录Socket
				ABYSocket.manager.login(options: nil, userInfo: ["email": email, "password": ""])
			}
		}
	}
	var token: String {
		get {
			if let token = UserDefaults.standard.string(forKey: "token") {
				return token
			}
			return ""
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "token")
		}
	}
    var current_id: String {
        let result = self.user?.id ?? 0
        return "\(result)"
    }
    
	var isLogin: Bool {
		return self.token != ""
	}
	var session_id: String = "" // 每次登陆都会重置
	// 设备信息
	let deviceID: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
	let deviceName: String = ""
	let systemVersion: String = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
	let JPushRegistrationID: String = ""
	let AppVersion: String = "1.2.0"
	var deviceInfo: [String: String] {
		return ["deviceID": deviceID, "deviceName": deviceName, "systemVersion": systemVersion, "JPushRegistrationID": JPushRegistrationID, "AppVersion": AppVersion]
	}
	// 登出通知名
	let logoutName: Notification.Name = Notification.Name(rawValue: "LoginOut")
	// 初始化方法私有化，避免多余的实例化
	private init() {
		do {
			try self.readUser()
		} catch {
			print(error)
		}
	}
	func login(username: String, password: String, captcha: String) -> Void {
		let params: Parameters = ["email": username, "password": password, "captcha": captcha, "deviceInfo": deviceInfo]
//		ABYPrint(message: deviceInfo)
		self.networkManager.aby_request(request: UserRouter.request(api: UserAPI.auth, params: params)) { (result) -> (Void) in
			if let res = result {
				if (res["state"] == 200) {
					// 登录成功以后自动获取数据，并且保存Token值
					self.token = res["data"]["token"].string!
					self.delegate?.accountLoginSuccess()
				} else {
					self.delegate?.accountLoginFail(res["message"].string)
				}
			} else {
				self.delegate?.accountLoginFail("网络错误")
			}
		}
	}
	// 获取用户信息方法
	func getUserInfo() -> Void {
		self.networkManager.aby_request(request: UserRouter.userInfo(token: self.token)) { (result) -> (Void) in
			if let res = result {
				if (res["state"] == 200) {
					let user = res["data"]["user"]
					if let usrString = user.rawString(.utf8, options: JSONSerialization.WritingOptions.prettyPrinted) {
						let data = usrString.data(using: .utf8)
						do {
							self.user = try JSONDecoder().decode(User.self, from: data!)
							try self.saveUser()
						} catch {
							print(error)
						}
					}
				}
			}
		}
	}

	func loginOut() -> Void {
		// 第一步置空Token
		UserDefaults.standard.set("", forKey: "token")
		// 第二步重新初始化联系人
		let user = User()
		self.user = user
		do {
			try saveUser()
		} catch  {
			print(error)
		}
		ABYSocket.manager.loginOut()
        ABYRealmManager.instance.clearStore() // 清空数据库
		NotificationCenter.default.post(name: logoutName, object: nil)
	}
	// MARK: -私有方法
	private func saveUser() throws -> Void {
		if let user = self.user {
			let encodeData: Data = try JSONEncoder().encode(user)
			let url = URL.init(fileURLWithPath: userPath)
			try encodeData.write(to: url)
		}
	}
	private func readUser() throws -> Void {
		let url = URL.init(fileURLWithPath: userPath)
		let data = try FileHandle.init(forReadingFrom: url).readDataToEndOfFile()
		self.user = try JSONDecoder().decode(User.self, from: data)
	}
}
