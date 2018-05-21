//
//  ConversationViewController.swift
//  AbysSwift
//
//  Created by aby on 2018/2/2.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import MJRefresh

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
    
    lazy var rightMenuView: ABYPopMenu = {
        var popMenuItems: [ABYPopMenuItem] = [ABYPopMenuItem]()
        let imageArr = [(#imageLiteral(resourceName: "menu_online"), "在线"),(#imageLiteral(resourceName: "menu_offline"), "离线")]
        for item in imageArr {
            let popItem: ABYPopMenuItem = ABYPopMenuItem.init(image: item.0, title: item.1)
            popMenuItems.append(popItem)
        }
        let menu = ABYPopMenu.init(menus: popMenuItems, lineNumber: 1, targetPoint: CGPoint.init(x: self.view.frame.width - 15, y: 10))
        menu.popMenuDidSelectedBlock = {(index: Int, item: ABYPopMenuItem) in
            let status: Bool = index == 0
            self.setOnLine(status: status)
        }
        return menu
    }()
    
	// MARK: -控制器生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
		addUI()
		conversationManager.dataSource = self
		conversationManager.initData()
        let header: MJRefreshNormalHeader = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(refreshData))
        header.lastUpdatedTimeLabel.isHidden = true // 隐藏时间
        header.setTitle("下拉刷新", for: MJRefreshState.idle)
        header.setTitle("松开刷新", for: .pulling)
        header.setTitle("加载中...", for: .refreshing)
        header.setTitle("没有新的内容", for: .noMoreData)
        tableview.mj_header = header
//		setTable() // 设置空视图的方法，暂时屏蔽掉
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let user = Account.share.user {
			ABYSocket.manager.login(options: nil, userInfo: ["email": user.email, "password":""])
		}
		conversationManager.initData()
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        self.setThemeNavigationBar()
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
        // 添加右边的按钮(根据用户状态)
        let rightImage = Account.share.user?.is_online == 1 ? #imageLiteral(resourceName: "online") : #imageLiteral(resourceName: "offline")
        self.createRightBtnItem(icon: rightImage, method: #selector(popMenu(_:)))
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
    @objc
    func popMenu(_ item: UIBarButtonItem) {
       self.rightMenuView.showMenu(on: self.view, opacity: 0.5)
    }
	// MARK: -ConversationManger的代理方法
	func conversationListUpdata() {
		self.tableview.reloadData()
        self.tableview.mj_header.endRefreshing()
	}

	func waitNumberUpdata(number: Int) {
		self.headLabel.text = "待服务 \(number)"
	}

	func updateFail(_ error: Error?, _ message: String?) {
		self.tableview.mj_header.endRefreshing()
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
		let keys = Array(conversationManager.conversations.keys)
		let model: Conversation =	conversationManager.conversations[keys[indexPath.row]]!
		let chatViewController = KKChatViewController()
		chatViewController.conversation = model
		navigationController?.pushViewController(chatViewController, animated: true)
	}
}

// MARK: - 处理用户状态
extension ConversationViewController {
	/// 设置用户状态的具体方法
    func setOnLine(status: Bool) -> Void {
        self.navigationItem.rightBarButtonItem?.image = status ? #imageLiteral(resourceName: "online") : #imageLiteral(resourceName: "offline")
        let statusDes: String = status ? "1" : "0"
        let params: [String: Any] = [
            "current_id": Account.share.current_id,
            "status": statusDes
        ]
        // 进行离线在线状态的修改
        self.networkManager.aby_request(request: UserRouter.request(api: UserAPI.switchServiceStatus, params: params)) { (result) -> (Void) in
            if let json = result {
                if json["message"].string == "修改成功" {
                    Account.share.user?.is_online = Int(statusDes) ?? 1
                    self.showToast("在线状态修改成功")
                } else {
                    // 提示修改失败
                    self.showToast("在线状态修改失败")
                    // 并修改回去
                    self.navigationItem.rightBarButtonItem?.image = !status ? #imageLiteral(resourceName: "online") : #imageLiteral(resourceName: "offline")
                }
            } else {
                // 提示修改失败
                self.showToast("在线状态修改失败")
                // 并修改回去
                self.navigationItem.rightBarButtonItem?.image = !status ? #imageLiteral(resourceName: "online") : #imageLiteral(resourceName: "offline")
            }
        }
    }
}

// MARK: - 数据为空的时候的处理方式
extension ConversationViewController: ABYEmptyDataSetable {

	/// 设置空视图的方法
	fileprivate func setTable() {
		aby_EmptyDataSet(tableview) { () -> ([ABYEmptyDataSetAttributeKeyType : Any]) in
			return [
				.tipStr:"暂时没有服务中的用户...",
				.verticalOffset: -150,
				.allowScroll: false
			]
		}

		aby_tapEmptyView(tableview) { (view) in
			ABYPrint("点击了空视图")
		}
	}
}
