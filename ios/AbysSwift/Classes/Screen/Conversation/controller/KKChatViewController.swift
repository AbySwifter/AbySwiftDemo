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
	var conversation: Conversation?
	// MARK: -输入栏的控制器
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

	lazy var messageVC: KKMessageViewController = {
		let messageVC = KKMessageViewController()
		self.view.addSubview(messageVC.view)
		messageVC.view.snp.makeConstraints({ (make) in
			make.left.right.top.equalTo(self.view)
			make.bottom.equalTo(self.chatBarVC.view.snp.top)
		})
		messageVC.conversation = self.conversation
		messageVC.setMessage(list: (self.conversation?.message_list)!)
		return messageVC
	}()

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
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		setThemeNavigationBar()
	}

	@objc
	func popMenu(_ item: UIBarButtonItem) -> Void {

	}
	@objc
	func tapTab(_ tap: UITapGestureRecognizer) {
		self.view.endEditing(true)
	}
}


extension KKChatViewController {
	fileprivate func setup() {
		// 设置标题
		navigationItem.title = conversation?.name ?? ""
		// 设置右侧按钮
		createRightBtnItem(icon: #imageLiteral(resourceName: "chat_right_icon"), method: #selector(popMenu(_ :)))
		chatBarVC.delegate = self
		let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapTab(_:)))
		tap.cancelsTouchesInView = false
		messageVC.view.addGestureRecognizer(tap)
	}
}

extension KKChatViewController {
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
	/**
	* 监听从Socket过来的消息
	*/
	func messageBus(_ message: Message, sendStatus: DeliveryStatus) {
		self.messageVC.update(message, status: sendStatus)
	}

	func messageBus(on message: Message) {
		// 来了消息之后插入列表
		self.messageVC.instert(message)
	}
}
