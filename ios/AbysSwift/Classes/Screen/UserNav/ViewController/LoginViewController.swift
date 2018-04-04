//
//  LoginViewController.swift
//  AbysSwift
//
//  Created by aby on 2018/2/2.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import JGProgressHUD

class LoginViewController: ABYBaseViewController, LoginProtocol {
	let network: ABYNetworkManager = {
		return ABYNetworkManager.shareInstance
	}()
	// 用户管理类的单例
	let user: Account = {
		return Account.share
	}()
	// 控制视图变化的全局变量
	var keyboardHide: Bool = true
	// UI组件
	var logoView: UIImageView = UIImageView.init() // logo的图像
	var titleLabel: UILabel = UILabel.init() // logo下的名字
	let formContent: UIView = UIView.init() // 对话框输入的父视图
	let userNmaeIcon: UIImageView = UIImageView.init() // 用户名logo
	let userName: UITextField = UITextField.init() // 输入用户名
	let passWordIcon: UIImageView = UIImageView.init() // 密码logo
	let passWord: UITextField = UITextField.init() // 输入密码
	let codeIcon: UIImageView = UIImageView.init() // 验证码logo
	let code: UITextField = UITextField.init() // 输入验证码
	let loginButton: UIButton = UIButton.init(type: UIButtonType.custom) // 登录按钮
	let hud:JGProgressHUD = JGProgressHUD.init(style: .dark)
	// MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = ABYGlobalBackGroundColor()
		self.user.delegate = self // 设置代理
        // Do any additional setup after loading the view.
		createView() // 创建布局
		setView() // 填充内容
		getCodeUrl() // 获取验证码视图
		addKeyBoardNotification() // 添加键盘监听事件
		ABYPrint(message: "登录页面出现")
    }
	func addKeyBoardNotification() -> Void {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillshow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	// MARK: -创建视图
	private func createView() -> Void {
		view.addSubview(logoView)
		logoView.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.top.equalToSuperview().offset(W750(135 as CGFloat))
			make.height.width.equalTo(W750(155))
		}
		view.addSubview(titleLabel)
		titleLabel.snp.makeConstraints { (make) in
			make.centerX.equalTo(logoView)
			make.top.equalTo(logoView.snp.bottom).offset(W750(20))
		}
		view.addSubview(formContent)
		formContent.snp.makeConstraints { (make:ConstraintMaker) in
			make.top.equalTo(titleLabel).offset(W750(100))
			make.left.equalToSuperview().offset(15)
			make.right.equalToSuperview().offset(-15)
			make.height.equalTo(W750(300))
		}
		formContent.addSubview(userName)
		userName.snp.makeConstraints { (make) in
			make.left.right.equalToSuperview()
			make.height.equalTo(W750(89))
			make.top.equalToSuperview()
		}
		createSeparator(topView: userName, superView: formContent)
		formContent.addSubview(passWord)
		passWord.snp.makeConstraints { (make) in
			make.left.right.equalToSuperview()
			make.height.equalTo(W750(89))
			make.top.equalTo(userName.snp.bottom).offset(1)
		}
		createSeparator(topView: passWord, superView: formContent)
		// 验证码图片
		formContent.addSubview(codeIcon)
		codeIcon.snp.makeConstraints { (make) in
			make.right.equalToSuperview()
			make.bottom.equalToSuperview().offset(W750(-15))
			make.height.equalTo(W750(90))
			make.width.equalToSuperview().dividedBy(2)
		}
		// 验证码输入框
		formContent.addSubview(code)
		code.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.right.equalTo(codeIcon.snp.left)
			make.height.equalTo(W750(89))
			make.bottom.equalToSuperview()
		}
		// 创建登录按钮
		view.addSubview(loginButton)
		loginButton.snp.makeConstraints { (make) in
			make.width.equalTo(formContent)
			make.height.equalTo(W750(90))
			make.centerX.equalTo(formContent)
			make.top.equalTo(formContent.snp.bottom).offset(20)
		}
	}

	private func setView() -> Void {
		logoView.image = #imageLiteral(resourceName: "logo")
		logoView.contentMode = UIViewContentMode.scaleAspectFit
		titleLabel.text = "侃侃 Talk"
		titleLabel.textColor = ABYGlobalThemeColor() // 和主题色相同
		formContent.layer.cornerRadius = 10.0
		formContent.backgroundColor = UIColor.white
		formContent.layer.borderColor = ABYGlobalBorderColor().cgColor
		formContent.layer.borderWidth = 1.0
//		formContent.layer.masksToBounds = true
		// 配置用户名对话框
		let leftImageView = createLeftView(image: #imageLiteral(resourceName: "account"))
		userName.leftView = leftImageView
		userName.leftViewMode = UITextFieldViewMode.always
		userName.placeholder = "请输入用户名"
		userName.clearButtonMode = .whileEditing
		userName.autocapitalizationType = .none
		// 配置密码对话框
		let leftPassWord = createLeftView(image: #imageLiteral(resourceName: "password"))
		passWord.leftView = leftPassWord
		passWord.leftViewMode = UITextFieldViewMode.always
		passWord.placeholder = "请输入密码"
		passWord.isSecureTextEntry = true
		passWord.autocapitalizationType = .none
		passWord.autocorrectionType = .no
		// 配置验证码对话框
		let leftCode = createLeftView(image: #imageLiteral(resourceName: "checkcode"))
		code.leftView = leftCode
		code.leftViewMode = UITextFieldViewMode.always
		code.placeholder = "请输入验证码"
		code.autocapitalizationType = .none
		code.autocorrectionType = .no
		// 配置验证码图
		codeIcon.contentMode = .scaleAspectFit
		codeIcon.isUserInteractionEnabled = true
		let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(getCodeUrl))
		codeIcon.addGestureRecognizer(tapGesture)
		// 设置button
		loginButton.backgroundColor = ABYGlobalThemeColor()
		loginButton.layer.cornerRadius = 10.0
		loginButton.setTitle("登录", for: .normal)
		loginButton.setTitleColor(UIColor.white, for: .normal)
		loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
	}

	/// 创建左侧图标
	///
	/// - Parameter image: 图标的Icon
	/// - Returns: 返回左侧视图
	private func createLeftView(image: UIImage) -> UIView {
		let LeftFrame = CGRect.init(x: 0, y: 0, width: W750(90), height: W750(35))
		let leftImageView = UIImageView.init(image: image)
		leftImageView.frame = LeftFrame
		leftImageView.contentMode = UIViewContentMode.scaleAspectFit
		return leftImageView
	}

	/// 创建Form表单的分割线
	///
	/// - Parameters:
	///   - topView: 分割线的顶部视图
	///   - superView: 父视图
	private func createSeparator(topView: UIView, superView: UIView) -> Void {
		let view = UIView.init()
		superView.addSubview(view)
		view.snp.makeConstraints { (make) in
			make.top.equalTo(topView.snp.bottom)
			make.width.equalTo(topView)
			make.height.equalTo(1)
			make.centerX.equalTo(topView)
		}
		view.backgroundColor = ABYGlobalBorderColor()
	}

	// TODO: 网络层的请求，根据设计原则不应该出现在VC里，后期优化
	@objc
	func getCodeUrl() -> Void {
		self.network.aby_request(request: UserRouter.code) { (res) -> (Void) in
			if let result = res {
				let urlString = result["data"]["captcha"]
				if let url:String = urlString.string {
					self.codeIcon.kf.setImage(with: URL.init(string: url))
				}
			} else {
				print("网络出错了")
			}
		}
	}
	// MARK: -点击动作
	@objc
	func login(_ button: UIButton) -> Void {
		self.view.endEditing(true) // 隐藏键
		//登录的时候需要检测用户名等是否为空
		guard let username = userName.text else { return }
		guard let password = passWord.text else { return }
		guard let code = code.text else { return }
		hud.textLabel.text = "登录中"
		hud.show(in: self.view)
		user.login(username: username, password: password, captcha: code);
	}

	// MARK - LoginDelegate
	func accountLoginFail(_ reson: String?) {
		// 登录失败
		hud.dismiss(animated: false)
		if let reason = reson {
			showToast(reason)
		}
		getCodeUrl() // 刷新验证码
	}

	func accountLoginSuccess() {
		// 登录成功
		hud.dismiss()
		self.dismiss(animated: true) {
			Account.share.getUserInfo()
		}
	}

	// MARK: 键盘弹出事件
	@objc
	func keyboardWillshow(_ notification: Notification) -> Void {
		if keyboardHide {
			keyboardHide = false
			UIView.animate(withDuration: 2.0, animations: {
				self.logoView.snp.updateConstraints({ (make) in
					make.width.height.equalTo(W750(70))
				})
				self.view.layoutIfNeeded()
			})
		}
	}

	@objc
	func keyboardWillHide(_ notification: Notification) -> Void {
		if !keyboardHide {
			keyboardHide = true
			UIView.animate(withDuration: 2.0, animations: {
				self.logoView.snp.updateConstraints({ (make) in
					make.width.height.equalTo(W750(155))
				})
				self.view.layoutIfNeeded()
			})
		}
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}

}
