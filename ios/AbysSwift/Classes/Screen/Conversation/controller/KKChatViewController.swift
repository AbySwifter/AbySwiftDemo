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
import AVFoundation
import Photos



class KKChatViewController: ABYBaseViewController {
    /// 会话管理者
    var conversationManger: ConversationManager {
		return ConversationManager.distance
	}
    /// 右上角客户信息的加载
	lazy var popMenu: ABYPopMenu = {
		var popMenuItems: [ABYPopMenuItem] = [ABYPopMenuItem]()
		let imageArr = [(#imageLiteral(resourceName: "user_info"), "客户信息"),(#imageLiteral(resourceName: "another_user"), "转接客服"),(#imageLiteral(resourceName: "history_conversation"), "历史消息"),(#imageLiteral(resourceName: "evalute_icon"), "服务评价"),(#imageLiteral(resourceName: "exit_conversation"), "结束服务")]
		for item in imageArr {
			let popItem: ABYPopMenuItem = ABYPopMenuItem.init(image: item.0, title: item.1)
			popMenuItems.append(popItem)
		}
		let menu = ABYPopMenu.init(menus: popMenuItems, lineNumber: 2, targetPoint: CGPoint.init(x: self.view.frame.width - 15, y: 10))
		menu.popMenuDidSelectedBlock = {(index: Int, item: ABYPopMenuItem) in
			self.clickRightMenu(index: index, item: item)
		}
		return menu
	}()
    /// 当前会话
	var conversation: Conversation?
	/// 提示消息
    var tipMessage: Message?
    ///是否显示提示
    var isShowtips: Bool {
        get {
            return tipMessage != nil
        }
        set {
            if !newValue {
                tipMessage = nil
            }
        }
    }
    /// 输入控制器
	lazy var chatBarVC: KKChatBarViewController = {
		let room_id = conversation?.room_id ?? 0
        let barVC = KKChatBarViewController.init(roomID: room_id, page: self)
        barVC.delegate = self
        self.view.addSubview(barVC.view)
        barVC.view.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.view.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(barVC.originHeight)
        })
		return barVC
	}()
    
    /// 消息控制器
	lazy var messageVC: KKMessageViewController = {
		let messageVC = KKMessageViewController()
		self.view.addSubview(messageVC.view)
		messageVC.view.snp.makeConstraints({ (make) in
			make.left.right.top.equalTo(self.view)
			make.bottom.equalTo(self.chatBarVC.view.snp.top)
		})
		messageVC.conversation = self.conversation
		if let list = self.conversation?.message_list {
			messageVC.setMessage(list: list)
		}
		return messageVC
	}()
    
    /// 录音的视图
    lazy var recordingView: KKChatVoiceView = {
        let recordingV = KKChatVoiceView.init(frame: CGRect.zero)
        recordingV.isHidden = true
        return recordingV
    }()    
    lazy var back: ABYBackItem = {
        let back = ABYBackItem.init(title: backTitle, titleColor: UIColor.black, icon: #imageLiteral(resourceName: "chat_back_icon"))
        back.addTarget(self, action: #selector(popToLast), for: .touchUpInside)
        return back
    }()
    var backTitle: String {
        if self.conversationManger.unreadTotal != 0 {
            return "侃侃(\(self.conversationManger.unreadTotal))"
        } else {
            return "侃侃"
        }
    }
    // MARK:- 记录属性
    var finishRecordingVoice: Bool = true   // 决定是否停止录音还是取消录音
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = UIColor.white
		setup()
        BaseBridgeCenter.center.delegate = self
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: back)
        conversationManger.change(atService: (conversation?.room_id) ?? -1, status: true)
        back.set(title: backTitle)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setWhiteNavigationBar()
        registerNotification() // 注册通知
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0)]
        chatBarVC.addNotification() // 这些通知和UI的交互有关系, 建议只存在于视图出现的情况
        _ = MessageBus.distance.addDelegate(self)
    }
    
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
        chatBarVC.removeNotification()
        removeNotification()
	}
   
    deinit {
        DTLog("KKChatViewController，走了deinit的方法")
    }
    
    @objc
    func popToLast() -> Void {
        conversationManger.change(atService: (conversation?.room_id) ?? -1, status: false)
        BaseBridgeCenter.center.delegate = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    /// 弹出了右上角菜单
	@objc
	func popMenu(_ item: UIBarButtonItem) -> Void {
        self.chatBarVC.changeEditorStatus(.none)
		self.popMenu.showMenu(on: self.view, opacity: 0.5)
	}
    
    /// 点击了右上角菜单事件
	func clickRightMenu(index: Int, item: ABYPopMenuItem) {
		switch index {
        case 0:
            routeToCustomerInfo()
        case 1:
            routeToOtherList()
        case 2:
            routeHistoryList()
		case 3:
            DTLog("点击了服务评价")
            showAlert(title: "提示", content: "发起服务评价？") { () -> (Void) in
               self.sendEvaluate() // 发送评价消息
            }
        case 4:
			showAlert(title: "提示", content: "结束服务？") { () -> (Void) in
				// 这里进行结束服务处理
				self.endService()
			}
		default:
			break
		}
	}
    /// 客户信息
    private func routeToCustomerInfo() -> Void {
        let clientInfo = ClientInfoViewController()
        clientInfo.room_id = conversation?.room_id ?? 0
        self.navigationController?.pushViewController(clientInfo, animated: true)
    }
    /// 转接客服
    private func routeToOtherList() -> Void {
        let otherList = ToOtherViewController()
        otherList.room_id = Int(conversation?.room_id ?? 0)
        self.navigationController?.pushViewController(otherList, animated: true)
    }
    /// 历史消息
    private func routeHistoryList() -> Void {
        let historyList = HistoryMessageController()
        historyList.room_id = conversation?.room_id ?? 0
        historyList.conversation = conversation
        self.navigationController?.pushViewController(historyList, animated: true)
    }
    /// 结束服务
	private func endService() {
		showLoading()
		self.conversation?.endService(complete: { (result, msg) in
			self.hideLoading()
			if result {
				ConversationManager.distance.endService(room_id: self.conversation?.room_id ?? 0)
				self.navigationController?.popViewController(animated: true)
			} else {
				self.showToast("结束服务出错")
			}
		})
	}
    private func sendEvaluate() {
        showLoading()
        let params: [String: Any] = [
            "room_id": self.conversation?.room_id ?? 0,
            "cuttent_id": Account.share.current_id,
            "session_id": Account.share.session_id,
        ]
        self.net.dt_request(request: DTRequest.request(api: Api.sendEvaluate, params: params)) { (error, result) -> Void in
            self.hideLoading()
            if let res = result {
                DTLog(res)
                self.showToast("满意度调查消息发送成功")
            } else {
                self.showToast("满意度调查消息发送失败")
            }
        }
    }
}

extension KKChatViewController: KKMessageViewControllerDelegate {
    func listBeenTaped() {
        guard self.chatBarVC.currentStatus != .none else {
            return
        }
        if self.chatBarVC.currentStatus != .voice {
             self.chatBarVC.changeEditorStatus(EditorStatus.none)
        }
    }
}


extension KKChatViewController {
    /// 初始化方法
	fileprivate func setup() {
		// 设置标题
		navigationItem.title = conversation?.name ?? ""
		// 设置右侧按钮
		createRightBtnItem(icon: #imageLiteral(resourceName: "chat_right_icon"), method: #selector(popMenu(_ :)))
        messageVC.delegate = self
        chatBarVC.hiddenTip(!isShowtips)
        // 添加子视图
        self.view.addSubview(recordingView)
        // 布局
        recordingView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top).offset(100)
            make.bottom.equalTo(self.view.snp.bottom).offset(-100)
            make.left.right.equalTo(self.view)
        }
        view.bringSubviewToFront(chatBarVC.view)
        // 设置其他代理
	}
    /// 打开产品页面
    func pushProductViewController() -> Void {
        let productVC = ProductViewController()
        self.navigationController?.pushViewController(productVC, animated: true)
    }
    
    /// 打开话术推荐页面
    func pushReplyViewController() -> Void {
        let replayVC = ReplayViewController()
        replayVC.message = self.tipMessage
        self.conversationManger.recommendReply[self.conversation?.room_id ?? 0] = nil
        self.chatBarVC.hiddenTip(true)
        replayVC.sendAction = {(text: String) -> Void in
            guard let roomid = self.conversation?.room_id else {
                return
            }
            let message = Message.init(text: text, room_id: roomid)
            message.content?.is_bot = 1 // 发送话术的标识
            self.chatBarVC.sendMessage(message)
            // 发送出去之后要清空数据
            self.tipMessage = nil
            self.conversationManger.recommendReply[roomid] = nil
        }
        self.navigationController?.pushViewController(replayVC, animated: true)
    }
}

// MARK: - delegate
extension KKChatViewController: KKChatBarViewControllerDelegate, MessageBusDelegate{
    /// 底部高度改变的回调方法
    ///
    /// - Parameter height: 改变的高度
	func chatBarUpdate(height:CGFloat) -> Void {
		// 这里应该更新视图高度，并且滑动列表
		UIView.animate(withDuration: 0.3) {
			self.chatBarVC.view.snp.updateConstraints { (make) in
				make.height.equalTo(height)
			}
			self.view.layoutIfNeeded()
		}
		messageVC.scrollToBottom(true)
	}
    /// 底部编辑栏发送消息
	func chatBar(send message: Message) {
        // 发送的消息插入到列表里面
		self.messageVC.instert(message)
	}
	// 底部录音按钮发送消息
    func chatBarRecordButton(event: RecordEvent) {
        switch event {
        case .start:
            recordBegin()
        case .cancel, .stop:
            recordStoped()
        default:
            self.recordStatusChange(status: event)
        }
    }
    // 底部菜单点击事件
    func chatBarMenuAction(type: ChatFootMenuTag) {
        DTLog("点击了\(type)")
        switch type {
        case .product:
            pushProductViewController()
        case .speakRoutine:
            pushReplyViewController()
        default:
            break
        }
    }
	/**
	* 监听从messageBus分发的消息
	*/
	func messageBus(_ message: Message, sendStatus: DeliveryStatus) {
		self.messageVC.update(message, status: sendStatus)
	}
    /// FIXME: 在这里监听和过滤一些其他的消息
	func messageBus(on message: Message) {
        // 消息过滤
        if message.messageType != MessageType.custom {
            // 来了消息之后插入消息列表
            self.messageVC.instert(message)
        }
        back.set(title: backTitle) // 更新视图信息
	}
    
    func messageBus(onCustom message: Message) {
        // 收到自定义消息
        if message.content?.type == MSG_ELEM.customBotReply {
            self.chatBarVC.showTips()
            self.tipMessage = message
            self.chatBarVC.hiddenTip(!isShowtips)
        }
        if message.content?.type == MSG_ELEM.customproductReply {
            DTLog("产品回复：\(message.content?.product ?? "空的产品信息")")
        }
    }
    
    func messageBus(onEvent message: Message) {
        // 收到事件消息
        if message.content?.type == .sysServiceTimeout || message.content?.type == .sysChatTimeout || message.content?.type == .sysServiceEnd {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - 录音事件
extension KKChatViewController {
    /* ============================== 录音按钮长按事件 ============================== */
    @objc
    func recordBegin() {
        finishRecordingVoice = true
        recordingView.recording()
    }

    func recordStatusChange(status: RecordEvent) {
        if status == .parpareToCancel {
            guard finishRecordingVoice else { return } // 避免多次UI的绘制
            recordingView.slideToCancelRecord()
            finishRecordingVoice = false
        } else if status == .recording {
            guard !finishRecordingVoice else { return } // 避免多次UI的绘制
            recordingView.recording()
            finishRecordingVoice = true
        }
    }

    func recordStoped() {
        if finishRecordingVoice {
            // 停止录音
            DTLog("停止了录音")
        } else {
            // 取消录音
            DTLog("取消了录音")
        }
        recordingView.endRecord()
    }
}

