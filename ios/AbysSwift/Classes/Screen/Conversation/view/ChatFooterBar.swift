//
//  ChatFooterBar.swift
//  AbysSwift
//
//	尽量在这里处理FooterBar的变化等等的问题
//
//  Created by aby on 2018/3/28.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import SnapKit

enum ChatBoxState: Int {
	case normalState = 0
	case voiceState = 1
	case menuState = 2
	case menuHideState = 3
}

typealias CompontionBlock = () -> (Void)

protocol ChatFootBarDelegate {
	func footHeightChange(height: CGFloat, animate completion:@escaping CompontionBlock) -> Void
}


/// 聊天的FootBar
class ChatFooterBar: UIView {
	private var chatBox: UIView = UIView.init()
	private var menuBox: ChatFooterMenu = ChatFooterMenu.init(frame: CGRect.zero)
	// 切换输入状态的方法
	private lazy var changeStateBtn: UIButton = {
		let btn = UIButton.init(type: UIButtonType.custom)
		btn.addTarget(self, action: #selector(changeStateAction(_:)), for: .touchUpInside)
		return btn
	}()
	// 打开菜单的方法
	lazy var menuBtn: UIButton = {
		let btn = UIButton.init(type: .custom)
		btn.addTarget(self, action: #selector(menuAction(_:)), for: .touchUpInside)
		return btn
	}()
	// 发送消息的方法
	lazy var sendBtn: UIButton = {
		let btn = UIButton.init(type: .custom)
		btn.addTarget(self, action: #selector(sendAction(_:)), for: .touchUpInside)
		return btn
	}()
	// 消息输入框
	var textMsgInput: UITextField = UITextField.init()

	// 语音按钮
	lazy var voiceBtn: UIButton = {
		let btn = UIButton.init(type: .custom)
		btn.setTitleColor(UIColor.init(hexString: "333333"), for: .normal)
		btn.setTitle("按住说话", for: .normal)
		btn.setTitle("松开结束", for: .highlighted)
		btn.isHidden = true
		btn.layer.cornerRadius = 5.0
		btn.layer.borderColor = UIColor.init(hexString: "cfcfcf").cgColor
		btn.layer.borderWidth = 1 / UIScreen.main.scale
		btn.backgroundColor = UIColor.white
		return btn
	}()
	// 记录当前视图的状态信息
	private var isMenuShow: Bool = false
	private var lastHeight: CGFloat?
	// MARK: -Public property
	var menuDelegate: ChatFootMenuDelegate?
	var delegate: ChatFootBarDelegate?


	override init(frame: CGRect) {
		super.init(frame: frame)
		initUIElement() //初始化并添加UI
		setUIStyle() // 设置UI的属性
		makeChildConstraints() // 设定约束
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		if isMenuShow {
			menuBox.snp.makeConstraints { (make) in
				make.width.equalToSuperview()
				make.top.equalTo(self.chatBox.snp.bottom)
				make.height.equalTo(76)
				make.bottom.equalTo(self.snp.bottom)
				make.centerX.equalToSuperview()
			}
		}
		// 假如高度没有变化，则不执行代理方法
		if lastHeight != nil && lastHeight! != self.bounds.height {
			self.delegate?.footHeightChange(height: self.bounds.height, animate: {})
		}
		lastHeight = self.bounds.height
	}

	private func initUIElement() -> Void {
		self.addSubview(chatBox)
		chatBox.addSubview(changeStateBtn)
		chatBox.addSubview(menuBtn)
		chatBox.addSubview(sendBtn)
		chatBox.addSubview(textMsgInput)
		chatBox.addSubview(voiceBtn)
	}

	private func setUIStyle() -> Void {
		self.backgroundColor = UIColor.white
		var edgeInsert = UIEdgeInsets.init(top: 5, left: 15, bottom: 5, right: 5)
		changeStateBtn.imageEdgeInsets = edgeInsert
		changeStateBtn.imageView?.contentMode = .scaleAspectFit
		changeStateBtn.setImage(#imageLiteral(resourceName: "footer_voice_icon"), for: .normal)
		changeStateBtn.setImage(#imageLiteral(resourceName: "footer_scanf_icon"), for: .selected)
		edgeInsert.right = 15
		edgeInsert.left = 5
		menuBtn.setImage(#imageLiteral(resourceName: "footer_more_icon"), for: .normal)
		menuBtn.imageEdgeInsets = edgeInsert
		menuBtn.imageView?.contentMode = .scaleAspectFit
		sendBtn.setImage(#imageLiteral(resourceName: "sender_btn_icon"), for: .normal)
		sendBtn.imageEdgeInsets = edgeInsert
		sendBtn.imageView?.contentMode = .scaleAspectFit
		textMsgInput.placeholder = "请输入..."
	}

	func makeChildConstraints() -> Void {
		chatBox.snp.makeConstraints { (make) in
			make.height.greaterThanOrEqualTo(55)
			make.width.greaterThanOrEqualTo(W750(750)) // 与屏幕等宽
			make.top.equalToSuperview()
			make.centerX.equalToSuperview()
		}
		changeStateBtn.snp.makeConstraints { (make) in
			make.left.equalToSuperview().offset(10)
			make.centerY.equalToSuperview()
			make.width.equalTo(40)
			make.height.equalTo(30)
		}
		sendBtn.snp.makeConstraints { (make) in
			make.right.equalToSuperview().offset(-10)
			make.centerY.equalToSuperview()
			make.height.equalTo(30)
			make.width.equalTo(40)
		}
		menuBtn.snp.makeConstraints { (make) in
			make.right.equalTo(sendBtn.snp.left)
			make.centerY.equalToSuperview()
			make.height.equalTo(30)
			make.width.equalTo(40)
		}
		textMsgInput.snp.makeConstraints { (make) in
			make.left.equalTo(changeStateBtn.snp.right).offset(15)
			make.right.equalTo(menuBtn.snp.left).offset(-15)
			make.height.greaterThanOrEqualTo(30)
			make.centerY.equalToSuperview()
		}
		voiceBtn.snp.makeConstraints { (make) in
			make.left.equalTo(changeStateBtn.snp.right).offset(15)
			make.right.equalToSuperview().offset(-70)
			make.height.greaterThanOrEqualTo(30)
			make.centerY.equalToSuperview()
		}
	}

	func showMenu() -> Void {
		self.menuBox.delegate = self.menuDelegate
		isMenuShow = true
		self.addSubview(self.menuBox)
	}

	func hideMenu() -> Void {
		menuBox.delegate = nil
		isMenuShow = false
		self.delegate?.footHeightChange(height: 55, animate: { () -> (Void) in
			self.menuBox.removeFromSuperview()
		})
		lastHeight = 55
	}

	private func changeState(_ state: ChatBoxState) -> Void {
		switch state {
		case .normalState:
			UIView.animate(withDuration: 0.3, animations: {
				self.menuBtn.snp.remakeConstraints({ (make) in
					make.right.equalTo(self.sendBtn.snp.left)
					make.centerY.equalToSuperview()
					make.height.equalTo(30)
					make.width.equalTo(40)
				})
				self.layoutIfNeeded()
			}, completion: { (complete) in
				self.sendBtn.isHidden = false
			})
			break
		case .voiceState:
			sendBtn.isHidden = true
			UIView.animate(withDuration: 0.3, animations: {
				self.menuBtn.snp.remakeConstraints({ (make) in
					make.right.equalToSuperview().offset(-10)
					make.centerY.equalToSuperview()
					make.height.equalTo(30)
					make.width.equalTo(40)
				})
				self.layoutIfNeeded()
			})
			break
		case .menuState:
			break
		default:
			break
		}
	}

	@objc
	func changeStateAction(_ button: UIButton) -> Void {
		button.isSelected = !button.isSelected
		if button.isSelected {
			changeState(.voiceState)
		} else {
			changeState(.normalState)
		}
		textMsgInput.isHidden = button.isSelected
		voiceBtn.isHidden = !button.isSelected
	}

	@objc
	func menuAction(_ button: UIButton) -> Void {
		if isMenuShow {
			hideMenu()
		} else {
			showMenu()
		}
	}

	@objc
	func sendAction(_ button: UIButton) -> Void {

	}
	/*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
