//
/**
* 好看的皮囊千篇一律，有趣的灵魂万里挑一
* 创建者: 王勇旭 于 2018/4/25
* Copyright © 2018年 Aby.wang. All rights reserved.
* 4.0
*  ┏┓　　　┏┓
*┏┛┻━━━┛┻┓
*┃　　　　　　　┃
*┃　　　━　　　┃
*┃　┳┛　┗┳　┃
*┃　　　　　　　┃
*┃　　　┻　　　┃
*┃　　　　　　　┃
*┗━┓　　　┏━┛
*　　┃　　　┃神兽保佑
*　　┃　　　┃代码无BUG！
*　　┃　　　┗━━━┓
*　　┃　　　　　　　┣┓
*　　┃　　　　　　　┏┛
*　　┗┓┓┏━┳┓┏┛
*　　　┃┫┫　┃┫┫
*　　　┗┻┛　┗┻┛
*/

import UIKit
import MJRefresh

fileprivate let KKChatBaseCellID = "KKChatBaseCell"
fileprivate let KKChattextCellID = "KKChattextCell"
fileprivate let KKChatAudioCellID = "KKChatAudioCell"
fileprivate let KKSystemMsgCellID = "KKChatSystemMsgCell"
fileprivate let KKChatImageCellID = "KKChatImageCell"
fileprivate let KKArticleCellID = "KKArticleCell"

protocol KKMessageViewControllerDelegate {
    func listBeenTaped() -> Void
}

class KKMessageViewController: ABYBaseViewController,UITableViewDelegate, UITableViewDataSource {
    var showBot: Bool = false // 控制是否显示Bot消息标记
    var isChatView: Bool = true
    var delegate: KKMessageViewControllerDelegate?
    var loadMoreAction: (() -> (Void))? // 如果此属性为真，则默认的历史消息拉取方法不执行
    var loadFromRemote: (() -> (Void))? // 此属性存在，则在本地消息完毕后自动拉取历史消息
    /// 显示消息Item的tableView
	lazy var chatListView: UITableView = {
		let tab = UITableView.init(frame: CGRect.zero, style: .plain)
		tab.showsVerticalScrollIndicator = false
		tab.separatorStyle = .none
        tab.separatorInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
		tab.dataSource = self
		tab.delegate = self
		tab.tableFooterView = UIView.init()
		tab.backgroundColor = UIColor.init(hexString: "ececec")
		// 注册Cell
		tab.register(KKChatBaseCell.classForCoder(), forCellReuseIdentifier: KKChatBaseCellID) // 基础Cell，负责健壮性的维护，显示未定消息的类型
		tab.register(KKChattextCell.classForCoder(), forCellReuseIdentifier: KKChattextCellID) // 聊天文本消息
		tab.register(KKChatAudioCell.classForCoder(), forCellReuseIdentifier: KKChatAudioCellID)
		tab.register(KKChatSystemMsgCell.classForCoder(), forCellReuseIdentifier: KKSystemMsgCellID) // 聊天系统消息
        tab.register(KKChatImageCell.classForCoder(), forCellReuseIdentifier: KKChatImageCellID)
        tab.register(KKArrticalCell.classForCoder(), forCellReuseIdentifier: KKArticleCellID)
		return tab
	}()

    // 用来处理一些聊天数据的帮助类
	var helper: KKChatMsgDataHelper {
		return KKChatMsgDataHelper.shared
	}

	var conversation: Conversation?
	var messageList: [Message] = [] // 存放列表消息的数组
	var historyList: [Message] = [] // 存放本地历史消息的数组
	// 记录是否为第一次滚动
	private var firstScroll: Bool = true
    // 记录当前视图的ContentOffsetY
    
    override func viewDidLoad() {
        super.viewDidLoad()
		addChild() // 添加视图
        if isChatView {
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapTab(_:)))
            tap.cancelsTouchesInView = false
            self.view.addGestureRecognizer(tap)
        }
         defaultMoreMessage()
        // Do any additional setup after loading the view.
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		if self.firstScroll {
			let indexPath = IndexPath.init(row: messageList.count - 1, section: 0)
			_ = self.tableView(chatListView, cellForRowAt: indexPath)
			scrollToBottom()
			firstScroll = false
		}
	}

	private func addChild() -> Void {
		chatListView.delegate = self
		chatListView.dataSource = self
		view.addSubview(chatListView)
		chatListView.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			make.left.equalToSuperview()
			make.right.equalToSuperview()
		}
	}
    
    private func defaultMoreMessage() -> Void {
        let header: MJRefreshNormalHeader = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(loadMoreMessage))
        header.lastUpdatedTimeLabel.isHidden = true // 隐藏时间
        header.setTitle("下拉加载更多消息", for: MJRefreshState.idle)
        header.setTitle("松开加载更多消息", for: .pulling)
        header.setTitle("加载中...", for: .refreshing)
        header.setTitle("没有更多消息了", for: .noMoreData)
        chatListView.mj_header = header
    }
}

// 对外暴露的方法
extension KKMessageViewController {
	// 滚到最低部
	func scrollToBottom(_ animated: Bool = false) {
		self.chatListView.layoutIfNeeded()
		if messageList.count > 0 {
			let indexPath = IndexPath.init(row: messageList.count - 1, section: 0)
			_ = self.tableView(chatListView, cellForRowAt: indexPath)
			chatListView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
		}
	}

	/// 初始化聊天消息消息（非网络拉取历史消息）
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
		// FIXME: 暂时放在cellforrow里面去执行
		helper.addTimeTo(finalModel: nil, messages: messageList)
		helper.addTimeTo(finalModel: nil, messages: historyList)
	}
    
    /// 添加消息消息（网络拉取历史消息）
    func addMessageRemote(list: [Message]) -> Void {
        // 在添加消息前，先判断
        messageList[0].showTime = helper.needAddMinuteModel(preModel: list[list.count - 1], curModel: messageList[0])
        helper.addTimeTo(messages: list)
        let indexPath = IndexPath.init(row: list.count, section: 0)
        for msg in list.reversed() {
            self.instert(msg, isBottom: false)
        }
        chatListView.scrollToRow(at: indexPath, at: .top, animated: false)
    }
}

// MARK: -存放objc响应事件的扩展
extension KKMessageViewController {
    /// 轻点Tab或者开始滑动
    @objc
    func tapTab(_ tap: UITapGestureRecognizer) {
        self.delegate?.listBeenTaped()
    }
	// 加载历史消息
	@objc
	fileprivate func loadMoreMessage() {
        if let action = self.loadMoreAction {
            action()
            return
        }
		guard historyList.count != 0 else {
			// 没有历史消息
			chatListView.mj_header.endRefreshing()
            // FIXME: 执行远程加载历史消息的方法
			return
		}
		// 在加载历史消息之前，先判断消息的显示
		if messageList.count > 0 {
			messageList[0].showTime = helper.needAddMinuteModel(preModel: historyList[historyList.count - 1], curModel: messageList[0])
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
    
    func refresh() -> Void {
        chatListView.reloadData()
    }
}

// tabView的代理方法和数据源
extension KKMessageViewController {
	// MARK: TableView DataSouce& Delegate
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messageList.count;
	}

	// 先执行cell的方法
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messageList.count == 0 {
            return UITableViewCell.init()
        }
		let model = messageList[indexPath.row]
		var cell: KKChatBaseCell?
		// 在这里选择cell
        let type = model.messageType ?? .custom
		switch type {
		case .chat:
			if model.content?.type == MSG_ELEM.text {
				cell = tableView.dequeueReusableCell(withIdentifier: KKChattextCellID) as? KKChattextCell
                (cell as! KKChattextCell).showBot = self.showBot
			} else if model.content?.type == MSG_ELEM.voice {
				cell = tableView.dequeueReusableCell(withIdentifier: KKChatAudioCellID) as? KKChatAudioCell
            } else if model.content?.type == MSG_ELEM.image {
                cell = tableView.dequeueReusableCell(withIdentifier: KKChatImageCellID) as? KKChatImageCell
            } else if model.content?.type == MSG_ELEM.articleElem {
                cell = tableView.dequeueReusableCell(withIdentifier: KKArticleCellID) as? KKArrticalCell
            } else {
				cell = tableView.dequeueReusableCell(withIdentifier: KKChatBaseCellID) as? KKChatBaseCell
			}
			break
			//		case .custom:
			//			break
        case .sys:
            cell = tableView.dequeueReusableCell(withIdentifier: KKSystemMsgCellID) as? KKChatSystemMsgCell
        case .article:
            cell = tableView.dequeueReusableCell(withIdentifier: KKArticleCellID) as? KKArrticalCell
		default:
			cell = tableView.dequeueReusableCell(withIdentifier: KKChatBaseCellID) as? KKChatBaseCell
			break
		}
		cell?.model = model
		return cell!
	}

	// 再执行高度获取的方法
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let model = messageList[indexPath.row]
		return model.cellHeight
	}
    // 估算的高度
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    // MARK: - ScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 开始拖拽（手指触摸屏幕的时候）
        // FIXME: 处理逻辑：暂时按照微信的逻辑去弄
        self.delegate?.listBeenTaped()
    }
}

// 更新的方法
extension KKMessageViewController {
	/// 插入单条消息
	func instert(_ message: Message, isBottom: Bool = true) ->  Void {
		var indexPath: IndexPath!
		if isBottom {
			// 插入消息之前，首先判断是否需要显示时间戳
			message.showTime = helper.needAddMinuteModel(preModel: messageList[messageList.count - 1], curModel: message)
			messageList.append(message)
			indexPath = IndexPath.init(row: messageList.count - 1, section: 0)
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

	// 更新消息
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

// MARK: -操作列表，跟新UI的方法。私有方法
extension KKMessageViewController {
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

