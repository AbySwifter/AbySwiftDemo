//
/**
* 好看的皮囊千篇一律，有趣的灵魂万里挑一
* 创建者: 王勇旭 于 2018/4/19
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

import Foundation

// 注册通知的方法
extension ConvDetailViewController {
	//注册通知
	func registerNote() -> Void {
		// 键盘展开的事件
		NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		// 键盘回收的事件
		NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
	}
	// 移除通知
	func removeRegister() -> Void {
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
	}
}

// 通知调用的方法
extension ConvDetailViewController {
	// MARK: 键盘弹出的监听方法
	@objc
	func keyBoardWillShow(_ notification: Notification) -> Void {
		guard let kbInfo = notification.userInfo else { return  }
		// 获取键盘高度
		let kbRect: CGRect = (kbInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
		let kbHeight = kbRect.height
		// 键盘弹出时间
		let duration = kbInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
		if self.chatFoot.isMenuShow == true {
			self.chatFoot.hideMenu()
		}
		weak var weakSelf = self;
		// 界面进行偏移
		UIView.animate(withDuration: duration, animations: {
			weakSelf?.chatFoot.snp.updateConstraints({ (make) in
				make.bottom.equalTo((weakSelf?.view.snp.bottom)!).offset(-kbHeight)
			})
		}) { (result) in
			weakSelf?.scrollToBottom(true)
		}
	}
	@objc
	func keyBoardWillHide(_ notification: Notification) -> Void {
		guard let kbInfo = notification.userInfo else { return }
		// 键盘弹出时间
		let duration = kbInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
		weak var weakSelf = self;
		UIView.animate(withDuration: duration) {
			weakSelf?.chatFoot.snp.updateConstraints({ (make) in
				make.bottom.equalTo((weakSelf?.view.snp.bottom)!).offset(0)
			})
		}
	}
}
