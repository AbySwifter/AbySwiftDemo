//
//  MineViewController.swift
//  AbysSwift
//
//  Created by aby on 2018/2/2.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import Kingfisher


typealias SettingCellData = (icon: UIImage, title: String, hasSubTitle: Bool)

class MineViewController: ABYBaseViewController, UITableViewDelegate, UITableViewDataSource {
	lazy var tableView: UITableView = {
		let tableView: UITableView = UITableView.init(frame: self.view.bounds, style: .plain)
		tableView.dataSource = self
		tableView.delegate = self
		tableView.separatorStyle = .none
		tableView.bounces = false
		tableView.register(MineCell.self, forCellReuseIdentifier: "settingCell")
		tableView.isUserInteractionEnabled = true
		return tableView
	}()
	let avatar = UIImageView.init()
	let userName: UILabel = UILabel.init()
	let userEmail: UILabel = UILabel.init()
	let userNumber: UILabel = UILabel.init()
	let account: Account = {
		return Account.share
	}()
	let itemData: Array<SettingCellData> = [
		(#imageLiteral(resourceName: "change_password"), "修改密码", false),
		(#imageLiteral(resourceName: "notification"), "提醒设置", false),
		(#imageLiteral(resourceName: "cleaner"), "清理缓存", false),
		(#imageLiteral(resourceName: "version"), "当前版本", true),
	]
	// MARK: 生命周期函数
    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = UIColor.init(hexString: "f0f0f0")
        // Do any additional setup after loading the view.
		setNavigationRightButtons()
		self.view.addSubview(self.tableView)
		NotificationCenter.default.addObserver(self, selector: #selector(setAccountValue), name: NSNotification.Name.init(account.updateUserInfoKey), object: nil)
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationItem.title = "个人中心"
		self.navigationController?.navigationBar.titleTextAttributes =  [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18.0)]
//        setNavigationBarTranslucent()
        setWhiteNavigationBar()
        self.navigationController?.navigationBar.clipsToBounds = true
		setAccountValue()
	}
	// 设置用户信息
	@objc func setAccountValue() -> Void {
		userName.text = account.user?.real_name
		userEmail.text = "账号: \(account.user?.email ?? "")"
		userNumber.text = "工号: \(account.user?.number ?? "")"
		if let url = URL.init(string: (account.user?.avatar)!) {
			avatar.kf.setImage(with: url)
		}
	}

	private func setNavigationRightButtons() -> Void {
		let messageButton = UIButton.init(type: .custom)
		messageButton.setBackgroundImage(#imageLiteral(resourceName: "message"), for: .normal)
		messageButton.frame = CGRect.init(x: 0, y: 0, width: 22, height: 17)
		messageButton.addTarget(self, action: #selector(messageAction(_:)), for: .touchUpInside)
		let rigthItem = UIBarButtonItem.init(customView: messageButton)
		self.navigationItem.rightBarButtonItem = rigthItem
	}

	@objc
	private func messageAction(_ button: UIBarButtonItem) -> Void {
		// TODO: 点击展示站内信页面
	}
	@objc
	func logout(_ button: UIButton) -> Void {
		self.showAlert(title: "提示", content: "退出登录？") { () -> (Void) in
			self.account.loginOut()
		}
	}
	// MARK: tableViewDelegate、 tableViewDataSource
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:MineCell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! MineCell
		let cellData: SettingCellData = itemData[indexPath.row]
		cell.setCell(data: cellData)
		return cell
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return W750(92)
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return itemData.count
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// TODO：Tbaleview的点击事件除了
        if indexPath.row == 0 {
            let viewController = ChangePWDViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView.init()
		view.addSubview(avatar)
		avatar.snp.makeConstraints { (make) in
			make.width.height.equalTo(W750(124))
			make.centerY.equalToSuperview()
			make.right.equalToSuperview().offset(-20)
		}
		avatar.layer.cornerRadius = W750(62)
		avatar.layer.masksToBounds = true
		avatar.backgroundColor = UIColor.gray
		view.addSubview(userName)
		userName.snp.makeConstraints { (make) in
			make.top.equalToSuperview().offset(W750(60))
			make.left.equalToSuperview().offset(20)
//			make.height.equalTo(W750(50))
		}
		userName.font = UIFont.boldSystemFont(ofSize: W750(50))
		view.addSubview(userEmail)
		userEmail.snp.makeConstraints { (make) in
			make.top.equalTo(userName.snp.bottom).offset(W750(24))
			make.left.equalTo(userName)
//			make.height.equalTo(W750(26))
		}
		userEmail.font = UIFont.systemFont(ofSize: W750(26))
		userEmail.textColor = UIColor.init(hexString: "666666")
		view.addSubview(userNumber)
		userNumber.snp.makeConstraints { (make) in
			make.top.equalTo(userEmail.snp.bottom).offset(W750(10))
			make.left.equalTo(userEmail)
//			make.height.equalTo(W750(26))
			make.bottom.equalToSuperview().offset(W750(-60))
		}
		userNumber.font = UIFont.systemFont(ofSize: W750(26))
		userNumber.textColor = UIColor.init(hexString: "666666")
		return view
	}
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let view = UIView.init()
		let button: UIButton = UIButton.init(type: .system)
		view.addSubview(button)
		button.snp.makeConstraints { (make) in
			make.top.equalToSuperview().offset(W750(80))
			make.height.equalTo(W750(92))
			make.right.equalToSuperview().offset(-20)
			make.left.equalToSuperview().offset(20)
		}
		button.backgroundColor = ABYGlobalThemeColor()
		button.setTitle("退出登录", for: .normal)
		button.setTitleColor(UIColor.white, for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
		button.layer.cornerRadius = W750(9)
		button.addTarget(self, action: #selector(logout(_:)), for: .touchUpInside)
		return view
	}
	// tableView的底部高度，设置这个才能使点击事件生效
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return W750(172)
	}
}
