//
//  ConvDetailViewController.swift
//  AbysSwift
//
//  Created by aby on 2018/3/16.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import MJRefresh

fileprivate let KKChatBaseCellID = "KKChatBaseCell"
fileprivate let KKChattextCellID = "KKChattextCell"

class ConvDetailViewController: ABYBaseViewController, UITableViewDelegate, UITableViewDataSource, ChatFootMenuDelegate, ChatFootBarDelegate, MessageBusDelegate {

	let chatFoot: ChatFooterBar = ChatFooterBar.init(frame: CGRect.zero) // 底部组件
	lazy var chatListView: UITableView = {
		let tab = UITableView.init(frame: CGRect.zero, style: .plain)
		tab.showsVerticalScrollIndicator = false
		tab.separatorStyle = .none
		tab.separatorInset = UIEdgeInsetsMake(64, 0, 0, 0)
		tab.dataSource = self
		tab.delegate = self
		tab.tableFooterView = UIView.init()
		tab.backgroundColor = UIColor.init(hexString: "ececec")
		// 注册Cell
		tab.register(KKChatBaseCell.classForCoder(), forCellReuseIdentifier: KKChatBaseCellID)
		tab.register(KKChattextCell.classForCoder(), forCellReuseIdentifier: KKChattextCellID)
		let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapTab(_:)))
		tap.cancelsTouchesInView = false
		tab.addGestureRecognizer(tap)
		return tab
	}()

	var helper: KKChatMsgDataHelper {
		return KKChatMsgDataHelper.shared
	}

	var conversation: Conversation?
	var messageList: [Message] = [] // 存放列表消息的数组
	var historyList: [Message] = [] // 存放本地历史消息的数组
	var messageArr: [Message] {
		return messageList
	}

	var isScrollBottom: Bool = false
	var firstScroll: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
		// 添加视图
		addChildView()
		layoutChildView()
		// 注册通知
		self.registerNote()
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setWhiteNavigationBar() // 设置当前页面的navigation的颜色。
		// 这里需要添加MessageBus的监听进去
		_ = MessageBus.distance.addDelegate(self)
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		setThemeNavigationBar() // 设置回正常的颜色。
		MessageBus.distance.removeDelegate(index: nil)
	}
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		// 第一次加载的时候的处理
		if self.firstScroll {
			let indexPath = IndexPath.init(row: messageArr.count - 1, section: 0)
			_ = self.tableView(chatListView, cellForRowAt: indexPath)
			scrollToBottom()
			firstScroll = false
		}
	}
	deinit {
		// 移除注册的通知
		self.removeRegister()
	}
	@objc
	func tapTab(_ tap: UITapGestureRecognizer) {
		self.view.endEditing(true)
	}
	func menuAction(type: ChatFootMenuTag) {
		// 点击了菜单事件
		ABYPrint(message: type)
		switch type {
		case .product:
			let productVC = ProductViewController()
			self.navigationController?.pushViewController(productVC, animated: true)
		default:
			return
		}
	}
	/**
	 *
	 */
	func messageBus(_ message: Message, sendStatus: DeliveryStatus) {
		update(message, status: sendStatus)
	}

	func messageBus(on message: Message) {
		// 来了消息之后插入列表
		instert(message)
	}
}

// MARK: -tableView的代理方法
extension ConvDetailViewController {
	// MARK: TableView DataSouce& Delegate
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messageArr.count;
	}

	// 先执行cell的方法
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let model = messageArr[indexPath.row]
		var cell: KKChatBaseCell?
		// 在这里选择cell
		switch model.messageType! {
		case .chat:
			if model.content?.type == MSG_ELEM.text {
				cell = tableView.dequeueReusableCell(withIdentifier: KKChattextCellID) as? KKChattextCell
			} else {
				cell = tableView.dequeueReusableCell(withIdentifier: KKChatBaseCellID) as? KKChatBaseCell
			}
			break
			//		case .custom:
			//			break
			//		case .sys:
		//			break
		default:
	
			break
		}
		cell?.model = model
		return cell!
	}

	// 再执行高度获取的方法
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let model = messageArr[indexPath.row]
		return model.cellHeight
	}
}


// MARK: - 视图的绘制，以及键盘弹出后的处理
extension ConvDetailViewController {

	private func addChildView() -> Void {
		chatFoot.menuDelegate = self
		chatFoot.delegate = self
		chatFoot.room_id = self.conversation?.room_id
		view.addSubview(chatFoot)
		chatListView.delegate = self
		chatListView.dataSource = self
		let header: MJRefreshNormalHeader = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(loadMoreMessage))
		header.lastUpdatedTimeLabel.isHidden = true // 隐藏时间
		header.setTitle("下拉加载更多消息", for: MJRefreshState.idle)
		header.setTitle("松开加载更多消息", for: .pulling)
		header.setTitle("加载中...", for: .refreshing)
		header.setTitle("没有更多消息了", for: .noMoreData)
		chatListView.mj_header = header
		view.addSubview(chatListView)
	}

	private func layoutChildView() -> Void {
		chatFoot.snp.makeConstraints { (make) in
			make.bottom.equalTo(self.view.snp.bottom)
//			make.top.equalTo(self.view.snp.bottom).offset(-55)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
//			make.height.greaterThanOrEqualTo(55)
			make.height.equalTo(55)
			//			make.height.equalTo(55)
		}
		chatListView.snp.makeConstraints { (make) in
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.top.equalToSuperview()
			make.bottom.equalTo(chatFoot.snp.top)
		}
	}
}

// ChatBar的代理处理
extension ConvDetailViewController {
	/// 处理发送组件高度变化的方案
	///
	/// - Parameters:
	///   - height: 变化后的高度
	///   - completion: 处理完高度变化的回调, 在这里注意，视图展开时，需要先执行动画，后添加按钮。
	func footHeightChange(height: CGFloat, animate completion: @escaping CompontionBlock) {
		weak var weakSelf = self
		UIView.animate(withDuration: 0.3, animations: {
			self.chatFoot.snp.updateConstraints({ (make) in
				make.height.equalTo(height)
			})
			self.view.layoutIfNeeded()
		}) { (result) in
			completion()
			weakSelf?.scrollToBottom(true)
		}
	}

	func update(message: Message) -> Void {
		message.deliveryStatus = .delivering // 正在发送
		instert(message)
		// 发送消息
		MessageBus.distance.send(message: message)
	}
}

// 加载更多的消息
extension ConvDetailViewController {
	// 加载历史消息
	@objc
	fileprivate func loadMoreMessage() {
		guard historyList.count != 0 else {
			// 没有历史消息
			chatListView.mj_header.endRefreshing()
			return
		}
		// 在加载历史消息之前，先判断消息的显示
		if messageList.count > 0 {
			messageList[0].showTime = KKChatMsgDataHelper.shared.needAddMinuteModel(preModel: historyList[historyList.count - 1], curModel: messageList[0])
		}
		var msgList: [Message]!
		var indexPath: IndexPath!
		if historyList.count > 10 {
			let count = historyList.count
			let range = (count-10)...(count-1)
			let tempSlice = historyList[range]
			
			msgList = ([] + tempSlice) as [Message]
			indexPath = IndexPath.init(row: 10, section: 0)
			historyList.removeSubrange(range)
		} else {
			msgList = historyList
			indexPath = IndexPath.init(row: historyList.count, section: 0)
			historyList.removeAll()
		}
		// 一条一条的插入到顶部， 一次插入多条会有闪动
		for msg in msgList.reversed() {
			self.instert(msg, isBottom: false)
		}
		chatListView.scrollToRow(at: indexPath, at: .top, animated: false)
		chatListView.mj_header.endRefreshing()
	}
}

// 对外提供的更新数据的方法
extension ConvDetailViewController {
	/// 初始化数据
	func setMessage(list: [Message]) -> Void {
		var tempList = list
		let count = tempList.count
		if count > 10 {
			let start = count - 10
			let end = count - 1
			messageList = tempList[start...end] + []
			tempList.removeSubrange(start...end)
			historyList = tempList
		} else {
			messageList = tempList
		}
		KKChatMsgDataHelper.shared.addTimeTo(finalModel: nil, messages: messageList)
		KKChatMsgDataHelper.shared.addTimeTo(finalModel: nil, messages: historyList)
	}

	// 滚到最低部
	func scrollToBottom(_ animated: Bool = false) {
		self.chatListView.layoutIfNeeded()
		if messageArr.count > 0 {
			let indexPath = IndexPath.init(row: messageArr.count - 1, section: 0)
			_ = self.tableView(chatListView, cellForRowAt: indexPath)
			chatListView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
		}
	}

	/// 插入单条消息
	func instert(_ message: Message, isBottom: Bool = true) ->  Void {
		var indexPath: IndexPath!
		if isBottom {
			// 插入消息之前，首先判断是否需要显示时间戳
			message.showTime = helper.needAddMinuteModel(preModel: messageList[messageList.count - 1], curModel: message)
			messageList.append(message)
			indexPath = IndexPath.init(row: messageArr.count - 1, section: 0)
			_ = self.tableView(chatListView, cellForRowAt: indexPath) // 为了可以正常的插入这个cell
			self.insert(rows: [indexPath])
		} else {
			// 一个一个的插入
			messageList.insert(message, at: 0)
			indexPath = IndexPath.init(row: 0, section: 0)
			_ = self.tableView(chatListView, cellForRowAt: indexPath)
			self.insert(rows: [indexPath], atBottom: false)
		}
	}


	func update(_ message: Message, status: DeliveryStatus?) {
		guard let index = (messageList.index { (item) -> Bool in
			return item.messageID == message.messageID
		}) else { return }
		if let delivery = status {
			messageList[index].deliveryStatus = delivery
		} else {
			messageList[index] = message
		}
		let indexPath = IndexPath.init(row: index, section: 0)
		self.update([indexPath])
	}
}

// MARK: -更新数据的处理，私有方法
extension ConvDetailViewController {
	/// 插入消息
	fileprivate func insert(rows: [IndexPath], atBottom: Bool = true) {
		UIView.setAnimationsEnabled(false)
		chatListView.beginUpdates()
		chatListView.insertRows(at: rows, with: .none)
		chatListView.endUpdates()
		if atBottom {
			scrollToBottom(true)
		}
		UIView.setAnimationsEnabled(true)
	}

	/// 更新数据
	fileprivate func update(_ rows: [IndexPath]) {
		// 这里加异步延迟的方法是为了处理消息滚动和消息刷新的冲突
		let popTime = DispatchTime.now() + 0.300
		DispatchQueue.main.asyncAfter(deadline: popTime) {
			UIView.setAnimationsEnabled(false)
			self.chatListView.beginUpdates()
			self.chatListView.reloadRows(at: rows, with: .none)
			self.chatListView.endUpdates()
			UIView.setAnimationsEnabled(true)
		}
	}
}
