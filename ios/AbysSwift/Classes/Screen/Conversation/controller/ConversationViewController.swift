//
//  ConversationViewController.swift
//  AbysSwift
//
//  Created by aby on 2018/2/2.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit


class ConversationViewController: ABYBaseViewController, UITableViewDelegate, UITableViewDataSource, ConversationManagerDeleagate {
	// 视图列表组件
	lazy var tableview: UITableView = {
		let temp = UITableView.init(frame: CGRect.zero, style: .plain)
		temp.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.identifierString)
		temp.delegate = self
		temp.dataSource = self
		temp.separatorStyle = .none
		return temp
	}()
	let headView = UIView.init()
	let headLabel = UILabel.init()
	let conversationManager = ConversationManager.distance
	let refreshControl = UIRefreshControl.init()
	// MARK: -控制器生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
		addUI()
		conversationManager.dataSource = self
		conversationManager.initData()
		refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
		tableview.addSubview(refreshControl)
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let user = Account.share.user {
			ABYSocket.manager.login(options: nil, userInfo: ["email": user.email, "password":""])
		}
		conversationManager.initData()
	}
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}

	deinit {
		conversationManager.dataSource = nil
		tableview.delegate = nil
		tableview.dataSource = nil
	}

	// 添加UI视图
	func addUI() -> Void {
		view.addSubview(headView)
		headView.snp.makeConstraints { (make) in
			make.top.left.right.equalToSuperview()
			make.height.equalTo(45)
		}
		setHeadView()
		// tableView
		view.addSubview(tableview)
		tableview.snp.makeConstraints { (make) in
			make.top.equalTo(headView.snp.bottom)
			make.bottom.left.right.equalToSuperview()
		}
	}

	// 设置头部等待视图
	func setHeadView() -> Void {
		headView.backgroundColor = UIColor.init(hexString: "ebebeb")
		let waitImageView = UIImageView.init(image: #imageLiteral(resourceName: "wait"))
		headView.addSubview(waitImageView)
		waitImageView.snp.makeConstraints { (make) in
			make.top.equalToSuperview().offset(10)
			make.bottom.equalToSuperview().offset(-10)
			make.left.equalToSuperview().offset(20)
			make.width.equalTo(waitImageView.snp.height)
		}
		waitImageView.contentMode = .scaleAspectFit
		headView.addSubview(headLabel)
		headLabel.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.left.equalTo(waitImageView.snp.right).offset(10)
		}
		headLabel.text = "待服务 \(self.conversationManager.waitCount)"
	}


	/// 刷新列表
	@objc
	func refreshData() -> Void {
		// 刷新当前页面
		conversationManager.getList()
	}

	// MARK: -ConversationManger的代理方法
	func conversationListUpdata() {
		self.tableview.reloadData()
		self.refreshControl.endRefreshing()
	}

	func waitNumberUpdata(number: Int) {
		self.headLabel.text = "待服务 \(number)"
	}

	func updateFail(_ error: Error?, _ message: String?) {
		self.refreshControl.endRefreshing()
	}

	// MARK: TableView的代理方法
	// 返回分区内的行数
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var number = 0
		switch section {
		case 0:
			number = conversationManager.notificationArray.count
		case 1:
			number = conversationManager.conversations.count
		default:
			number = 0
		}
		return number;
	}
	// 返回分区的个数
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2;
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableview.dequeueReusableCell(withIdentifier: ConversationCell.identifierString, for: indexPath) as! ConversationCell
		var model: Conversation = Conversation()
		switch indexPath.section {
		case 0:
			model = conversationManager.notificationArray[indexPath.row]
		case 1:
			let keys = Array(conversationManager.conversations.keys)
			model =	conversationManager.conversations[keys[indexPath.row]]!
		default:
			model.name = ""
		}
		cell.setCellWith(model: model)
		return cell
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return W750(165);
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// 点击了Cell的事件
		tableView.deselectRow(at: indexPath, animated: true)
		let conversationDetail: ConvDetailViewController = ConvDetailViewController()
		self.navigationController?.pushViewController(conversationDetail, animated: true)
	}
}
