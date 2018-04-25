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

protocol KKChatBarViewControllerDelegate {
	func chatBarUpdate(height: CGFloat) -> Void
	func chatBar(send message: Message) -> Void
	func chatBarVC(_ chatBarVC: KKChatBarViewController, didChangeBottomDistance distance: CGFloat, duration: CGFloat) -> Void
}

enum LXFChatKeyboardType: Int {
	case noting
	case voice
	case text
	case emotion
	case more
}

class KKChatBarViewController: UIViewController, ChatFootMenuDelegate, ChatFootBarDelegate {
	var delegate: KKChatBarViewControllerDelegate?

	lazy var chatFoot: ChatFooterBar = {
		let chatFoot = ChatFooterBar.init(frame: CGRect.zero)
		chatFoot.delegate = self
		return chatFoot
	}()
	var roomID: Int16 = 0

	// MARK:- 记录属性
	var keyboardFrame: CGRect?
	var keyboardType: LXFChatKeyboardType?

	// 自定义的初始化方法
	init(roomID: Int16) {
		super.init(nibName: nil, bundle: nil)
		chatFoot.room_id = roomID
		self.roomID = roomID
	}
    override func viewDidLoad() {
        super.viewDidLoad()
		view.addSubview(chatFoot)
		chatFoot.snp.makeConstraints { (make) in
			make.left.right.bottom.equalTo(self.view)
			make.height.equalTo(kChatBarOriginHeight)
		}
		//FIXME: 监听键盘的方法需要添加
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameWillChange(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension KKChatBarViewController {
	func menuAction(type: ChatFootMenuTag) {
		// 点击菜单事事件的实现
	}

	func footHeightChange(height: CGFloat, animate completion: @escaping CompontionBlock) {
		// 当bar的高度改变的时候，从这里进行
//		weak var weakSelf = self
		self.delegate?.chatBarUpdate(height: height)
		UIView.animate(withDuration: 0.3, animations: {
			self.chatFoot.snp.updateConstraints({ (make) in
				make.height.equalTo(height)
			})
			self.view.layoutIfNeeded()
		}) { (result) in
			completion()
		}
	}

	func update(message: Message) {
		// 发送信息的时候从这里发出，这里需要把消息插入进去，用代理的方法传回到最初的View
		self.delegate?.chatBar(send: message)
	}
}

extension KKChatBarViewController {
	@objc fileprivate func keyboardWillHide(_ notification: NSNotification) {
		guard let kbInfo = notification.userInfo else {
			return
		}
		let duration = kbInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
		keyboardFrame = CGRect.zero
//		if barView.keyboardType == .emotion || barView.keyboardType == .more {
//			return
//		}
		if self.chatFoot.isMenuShow {
			self.chatFoot.hideMenu()
		}
		// 隐藏键盘
		delegate?.chatBarVC(self, didChangeBottomDistance: 0, duration: CGFloat(duration))
	}

	@objc fileprivate func keyboardFrameWillChange(_ notification: NSNotification) {
		guard let kbInfo = notification.userInfo else {
			return
		}
		let duration = kbInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
		keyboardFrame = kbInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect?
//		if barView.keyboardType == .emotion || barView.keyboardType == .more {
//			return
//		}
		delegate?.chatBarVC(self, didChangeBottomDistance: keyboardFrame?.height ?? 0, duration: CGFloat(duration))
	}
}
