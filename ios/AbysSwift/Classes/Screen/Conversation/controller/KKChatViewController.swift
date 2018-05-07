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

class KKChatViewController: ABYBaseViewController, KKChatBarViewControllerDelegate, MessageBusDelegate {
    /// 会话管理者
    var conversationManger: ConversationManager {
		return ConversationManager.distance
	}
    /// 右上角客户信息的加载
	lazy var popMenu: ABYPopMenu = {
		var popMenuItems: [ABYPopMenuItem] = [ABYPopMenuItem]()
		let imageArr = [(#imageLiteral(resourceName: "user_info"), "客户信息"),(#imageLiteral(resourceName: "another_user"), "转接客服"),(#imageLiteral(resourceName: "history_conversation"), "历史消息"),(#imageLiteral(resourceName: "exit_conversation"), "结束服务")]
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
	
    /// 输入控制器
	lazy var chatBarVC: KKChatBarViewController = {
		let room_id = conversation?.room_id ?? 0
		let barVC = KKChatBarViewController.init(roomID: room_id)
		self.view.addSubview(barVC.view)
		barVC.view.snp.makeConstraints({ (make) in
			make.bottom.equalTo(self.view.snp.bottom)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalTo(kChatBarOriginHeight)
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

    // MARK:- 记录属性
    var finishRecordingVoice: Bool = true   // 决定是否停止录音还是取消录音
    
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = UIColor.white
		setup()
        // Do any additional setup after loading the view.
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setWhiteNavigationBar()
		_ = MessageBus.distance.addDelegate(self)
		conversationManger.change(atService: (conversation?.room_id) ?? -1, status: true)
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		conversationManger.change(atService: (conversation?.room_id) ?? -1, status: false)
	}
	@objc
	func popMenu(_ item: UIBarButtonItem) -> Void {
		self.popMenu.showMenu(on: self.view, opacity: 0.5)
	}
	@objc
	func tapTab(_ tap: UITapGestureRecognizer) {
		self.view.endEditing(true)
	}
	func clickRightMenu(index: Int, item: ABYPopMenuItem) {
		switch index {
		case 3:
			showAlert(title: "提示", content: "结束服务？") { () -> (Void) in
				// 这里进行结束服务处理
				self.endService()
			}
		default:
			break
		}
	}

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
}


extension KKChatViewController {
    /// 初始化方法
	fileprivate func setup() {
		// 设置标题
		navigationItem.title = conversation?.name ?? ""
		// 设置右侧按钮
		createRightBtnItem(icon: #imageLiteral(resourceName: "chat_right_icon"), method: #selector(popMenu(_ :)))
		chatBarVC.delegate = self
		let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapTab(_:)))
		tap.cancelsTouchesInView = false
		messageVC.view.addGestureRecognizer(tap)
        // 添加子视图
        self.view.addSubview(recordingView)
        // 布局
        recordingView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top).offset(100)
            make.bottom.equalTo(self.view.snp.bottom).offset(-100)
            make.left.right.equalTo(self.view)
        }
	}
}

// MARK: - delegate
extension KKChatViewController {
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

	func chatBar(send message: Message) {
		self.messageVC.instert(message)
	}
	// 键盘高度的改变
	func chatBarVC(_ chatBarVC: KKChatBarViewController, didChangeBottomDistance distance: CGFloat, duration: CGFloat) {
		UIView.animate(withDuration: TimeInterval(duration)) {
			self.chatBarVC.view.snp.updateConstraints({ (make) in
				make.bottom.equalTo(self.view.snp.bottom).offset(-distance)
			})
		}
		self.messageVC.scrollToBottom()
	}
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
	func chatBarMenuAction(type: ChatFootMenuTag) {
//		ABYPrint("点击的底部菜单")
	}
	/**
	* 监听从messageBus分发的消息
	*/
	func messageBus(_ message: Message, sendStatus: DeliveryStatus) {
		self.messageVC.update(message, status: sendStatus)
	}

	func messageBus(on message: Message) {
		// 来了消息之后插入列表
		self.messageVC.instert(message)
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
            ABYPrint("停止了录音")
        } else {
            // 取消录音
            ABYPrint("取消了录音")
        }
        recordingView.endRecord()
    }
}
