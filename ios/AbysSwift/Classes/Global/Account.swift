//
//  Account.swift
//  AbysSwift
//
//  Created by aby on 2018/2/8.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import Alamofire
import DTRequest


/// 用户信息模型
struct User:Codable {
//	var username:String = ""
    /// 邮箱
	var email:String = ""
    /// 电话
	var number: String = ""
    /// identifie 标识符
	var id: Int64 = 0
    /// 规则id
	var role_id: Int64 = 0
    /// 昵称
	var name: String = ""
    /// 头像
	var avatar: String = ""
    /// 真实姓名
	var real_name: String = ""
    /// 是否在线标识
	var is_online: Int = 1
    /// 公司id
	var company_id:Int = -1
    /// 活跃信息？
	var active: Int = -1
    /// 创建时间
	var created_at: String = ""
    /// 更新时间
    var updated_at: String = ""
}

protocol LoginProtocol {
    /// 登录成功代理方法
    ///
    /// - Returns: 空返回值函数
	func accountLoginSuccess() -> Void
    /// 登录失败的代理方法
    ///
    /// - Parameter reson: 失败原因
    ///     * 主要用于UI提示
    /// - Returns: 空返回值
	func accountLoginFail(_ reson: String?) -> Void
}
/// 用户信息管理单例
class Account {
    /// 用户信息管理单例实例
    static let share = Account.init()
    /// 用户信息更新的关键字
	let updateUserInfoKey = "UpdateUserInfoKey"
    /// 网路管理类的计算属性
    var net: DTNetworkManager {
        return DTNetworkManager.share
    }
    /// 私有属性：用户信息存储路径
    fileprivate let userPath: String = NSHomeDirectory() + "/Documents/user.data"
    /// LoginProtocol代理
	var delegate: LoginProtocol?
    /// 用户信息存储属性
    ///     * 每次赋值会触发didSet方法
	var user: User? {
		didSet {
			NotificationCenter.default.post(Notification.init(name: Notification.Name.init(updateUserInfoKey)))
			if let email = user?.email {
				guard email == oldValue?.email else { return } // 如果email没有变化的话，不需要重新登录Socket
				ABYSocket.manager.login(options: nil, userInfo: ["email": email, "password": ""])
			}
		}
	}
    /// 登录授权令牌计算属性
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
    /// 当前用户ID计算属性
    var current_id: String {
        let result = self.user?.id ?? 0
        return "\(result)"
    }
    /// 是否登录标示
	var isLogin: Bool {
		return self.token != ""
	}
    /// 用于socket链接的Session
	var session_id: String = "" // 每次登陆都会重置
    // MARK: - 设备信息
	private let deviceID: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
	private let deviceName: String = ""
	private let systemVersion: String = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
	let JPushRegistrationID: String = ""
    /// 版本信息
	let AppVersion: String = "V1.3.0"
    /// 设备信息
	var deviceInfo: [String: String] {
		return ["deviceID": deviceID, "deviceName": deviceName, "systemVersion": systemVersion, "JPushRegistrationID": JPushRegistrationID, "AppVersion": AppVersion]
	}
    /// 退出登录的关键字
	let logoutName: Notification.Name = Notification.Name(rawValue: "LoginOut")
	// 初始化方法私有化，避免多余的实例化
	private init() {
		do {
			try self.readUser()
		} catch {
			print(error)
		}
	}
    /// 登录方法
    ///
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - captcha: 验证码
	func login(username: String, password: String, captcha: String) -> Void {
		let params: Parameters = ["email": username, "password": password, "captcha": captcha, "deviceInfo": deviceInfo]
        self.net.dt_request(request: DTRequest.request(api: Api.auth, params: params)) { (error, result) -> (Void) in
            if let res = result {
                if (res["state"] == 200) {
                    // 登录成功以后自动获取数据，并且保存Token值
                    self.token = res["data"]["token"].string!
                    self.net.set(token: self.token)
                    self.delegate?.accountLoginSuccess()
                } else {
                    self.delegate?.accountLoginFail(res["message"].string)
                }
            } else {
                self.delegate?.accountLoginFail("网络错误")
            }
        }
	}
    /// 根据登录令牌获取用户信息
	func getUserInfo() -> Void {
        guard self.isLogin else {
            // TODO: - 添加未获取token提示
            return
        }
        self.net.dt_request(request: DTRequest.request(api: Api.userInfo, params: ["token": self.token])) { (err, result) -> (Void) in
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
    /// 退出登录的方法
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
