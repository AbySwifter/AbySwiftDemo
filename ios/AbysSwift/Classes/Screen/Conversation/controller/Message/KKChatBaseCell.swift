//
//  KKChatBaseCell.swift
//  AbysSwift
//
//  Created by aby on 2018/4/18.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit


class KKChatBaseCell: UITableViewCell {
	var model: Message? { didSet { baseCellSetModel() } }
	// 头像
	lazy var avatar: UIImageView = {
		let avatar = UIImageView.init()
		// FIX:ME暂时放一个默认头像，以后做更改
		avatar.image = #imageLiteral(resourceName: "user")
		avatar.contentMode = .scaleAspectFit
		avatar.layer.cornerRadius = avatarWidth/2
		avatar.layer.masksToBounds = true
		return avatar
	}()
	// 消息的时间显示
	lazy var timeContent: UIView = {
		let view = UIView.init()
		return view
	}()
	lazy var timeLabel: UILabel = {
		let timeL = UILabel.init()
		timeL.textColor = UIColor.white
		timeL.font = UIFont.systemFont(ofSize: 12.0)
		return timeL
	}()

	lazy var bgView: UIView = {
		let bg = UIView()
		bg.layer.cornerRadius = 4
		bg.layer.masksToBounds = true
		bg.backgroundColor = UIColor.init(normal: 190.0, g: 190.0, b: 190.0, a: 0.6)
		return bg
	}()
	// 聊天内容
	lazy var msgContent: UIView = {
		let view = UIView.init()
		return view
	}()
	// 聊天气泡
	lazy var bubbleView: UIImageView = {
		return UIImageView.init()
	}()
	// 发送人昵称
	lazy var senderName: UILabel = {
		let label = UILabel.init()
		label.font = UIFont.systemFont(ofSize: 12.0)
		label.textColor = UIColor.init(hexString: "909090")
		return label
	}()
	// tipView, 消息发送成功与否的视图
	lazy var tipView: UIView = { [unowned self] in
		let tipView = UIView.init()
		tipView.addSubview(self.activityIndicator)
		tipView.addSubview(self.resendButton)
		return tipView
	}()

	// 加载图，用来表示正在发送
	lazy var activityIndicator: UIActivityIndicatorView = {
		let act = UIActivityIndicatorView.init()
		act.activityIndicatorViewStyle = .gray
		act.hidesWhenStopped = false
		act.startAnimating()
		return act
	}()

	lazy var resendButton: UIButton = {
		let resendBtn = UIButton.init(type: .custom)
		resendBtn.setImage(#imageLiteral(resourceName: "resend"), for: .normal)
		resendBtn.contentMode = .scaleAspectFit
		resendBtn.addTarget(self, action: #selector(resend), for: .touchUpInside)
		return resendBtn
	}()

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
//		let transform: CGAffineTransform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
//		self.transform = transform
		// 时间的显示
		self.addSubview(timeContent)
		timeContent.addSubview(bgView)
		timeContent.addSubview(timeLabel)
		bgView.snp.makeConstraints { (make) in
			make.left.equalTo(timeLabel.snp.left).offset(-4)
			make.top.equalTo(timeLabel).offset(-1)
			make.right.equalTo(timeLabel).offset(4)
			make.bottom.equalTo(timeLabel).offset(1)
		}
		self.backgroundColor = UIColor.init(hexString: "ececec")
		self.addSubview(avatar)
		msgContent.addSubview(senderName)
		msgContent.addSubview(bubbleView)
		self.addSubview(msgContent)
		self.addSubview(tipView)
		activityIndicator.snp.makeConstraints { (make) in
			make.left.top.right.bottom.equalTo(tipView)
		}
		resendButton.snp.makeConstraints { (make) in
			make.left.top.right.bottom.equalTo(tipView)
		}
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
// 视图布局的常量
extension KKChatBaseCell {
	var avatarWidth: CGFloat { return 40.0 }
	var avatarMargin: CGFloat { return 10.0 }
	var avatarToMsg: CGFloat { return 12.5 }
	var senderNameHeight: CGFloat { return 20.0 }
	var minVoiceWidth: CGFloat { return 40.0 }
	var avatarTotalWidth: CGFloat { return avatarWidth + avatarMargin + avatarToMsg }
	var verticalMargin: CGFloat {
		guard let model = self.model else { return 10 }
		let marginTop = model.showTime ? 50 : 10
		return CGFloat(marginTop)
	}
	var n_cOffset: CGFloat { return 5 }
	var maxMsgWidth: CGFloat{
		let marginHorizontal = (avatarWidth + avatarMargin + avatarToMsg + 3.0) * 2
		let result = UIScreen.main.bounds.width - marginHorizontal
		return result
	}
	var selfTextColor: UIColor {
		return UIColor.init(hexString: "ffffff")
	}
	var sysMsgTextColor: UIColor {
		return UIColor.init(hexString: "8c8c8c")
	}
	var msgBackGroundColor: UIColor {
		return UIColor.init(hexString: "ffffff")
	}
}

extension KKChatBaseCell {
	func baseCellSetModel() -> Void {
		// 基本的视图设置，根据消息的状况设置发送成功的状态
		tipView.isHidden = false
		activityIndicator.startAnimating()
		// 设置时间（只有部分消息需要时间的显示）

		if let message = self.model {
			timeContent.snp.remakeConstraints { (make) in
				make.top.equalTo(self.snp.top).offset(10)
				make.height.equalTo(40.0)
				make.width.equalTo(UIScreen.main.bounds.width)
				make.centerX.equalTo(self.snp.centerX)
			}
			timeLabel.text = message.timeStr
			timeLabel.sizeToFit()
			timeLabel.snp.remakeConstraints { (make) in
				make.width.equalTo(timeLabel.width)
				make.height.equalTo(timeLabel.height)
				make.center.equalTo(timeContent.snp.center)
			}
			timeContent.isHidden = !message.showTime
		}
		// 设置头像(只有会话消息需要设置头像和昵称)
		if let message = self.model, message.messageType == MessageType.chat {
			avatar.kf.setImage(with: URL.init(string: (message.sender?.headImgUrl)!), placeholder: #imageLiteral(resourceName: "user"), options: nil, progressBlock: nil, completionHandler: nil)
			senderName.text = message.senderName
		    let contentSize = senderName.sizeThatFits(CGSize.init(width: self.maxMsgWidth, height: CGFloat(Float.greatestFiniteMagnitude)))
			senderName.snp.remakeConstraints { (make) in
				make.size.equalTo(contentSize)
			}
		}
		if model?.isSelf == true {
			activityIndicator.isHidden = false
			resendButton.isHidden = true
			guard let deliveryState = model?.deliveryStatus else { return }
			switch deliveryState {
			case .delivered:
				tipView.isHidden = true
			case .delivering:
				resendButton.isHidden = true
				activityIndicator.isHidden = false
			case .failed:
				resendButton.isHidden = false
				activityIndicator.isHidden = true
			}
			// 处理自己的消息发送状态
		} else {// 对方的话，就隐藏掉消息状态
			tipView.isHidden = true
		}
	}
}

extension KKChatBaseCell {

	func getCellHeight() -> CGFloat {
		self.layoutIfNeeded() // 立即布局子视图，强制执行
		// 获取Cell高度
		let contentHeight = bubbleView.height + senderName.height + verticalMargin + n_cOffset + 10 // 这里的加10，是下边距
		if avatar.height > contentHeight {
			return avatar.height + 20.0
		} else {
			return contentHeight
		}
	}

	/// 重新发送操作
	@objc func resend() -> Void {
		// 重新发送消息的操作
	}
}
