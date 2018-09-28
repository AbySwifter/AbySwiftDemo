//
//  KKChatBaseCell.swift
//  AbysSwift
//
//  Created by aby on 2018/4/18.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import DTTools

class KKChatBaseCell: UITableViewCell, MessageStatusChangeDelegate {
	var model: Message? { didSet { baseCellSetModel() } }
	// 头像
	lazy var avatar: UIImageView = {
		let avatar = UIImageView.init()
		// FIX:ME暂时放一个默认头像，以后做更改
		avatar.image = #imageLiteral(resourceName: "user")
        avatar.backgroundColor = UIColor.lightGray
		avatar.contentMode = .scaleAspectFill
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
//        bg.backgroundColor = UIColor.init(normalr: 190.0, g: 190.0, b: 190.0, a: 0.6)
        bg.backgroundColor = UIColor.init(r: 190.0, g: 190.0, b: 190.0, a: 0.6)
		return bg
	}()
	// 聊天内容
	lazy var msgContent: UIView = {
		let view = UIView.init()
		return view
	}()
	// 聊天气泡
	lazy var bubbleView: UIImageView = {
        let bubble = UIImageView.init()
        bubble.isUserInteractionEnabled = true
		return bubble
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
        act.style = .gray
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
//		let transform: CGAffineTransform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
//		self.transform = transform
        self.clipsToBounds = true
		addTimeArae()
		chatMsgInit() // 只有会话消息需要显示头像，以后需要将其解耦出去
		self.backgroundColor = UIColor.init(hexString: "ececec")
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// 给消息添加时间显示视图
	func addTimeArae() {
		self.addSubview(timeContent)
		timeContent.addSubview(bgView)
		timeContent.addSubview(timeLabel)
		bgView.snp.makeConstraints { (make) in
			make.left.equalTo(timeLabel.snp.left).offset(-4)
			make.top.equalTo(timeLabel).offset(-1)
			make.right.equalTo(timeLabel).offset(4)
			make.bottom.equalTo(timeLabel).offset(1)
		}
	}
	// chat消息的统一布局
	func chatMsgInit() {
		// 时间的显示
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

	func getCellHeight() -> CGFloat {
        self.layoutIfNeeded()
		// 获取Cell高度
        let contentHeight = msgContent.height // 这里的加10，是下边距
//        let contentHeight = bubbleView.height + senderName.height + n_cOffset + 10
		let avatarHeight = avatar.height
		let height = contentHeight > avatarHeight ? contentHeight : avatarHeight
		return height + verticalMargin
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
	} // 消息的头像与cell的顶部距离

	var n_cOffset: CGFloat { return 5 } // 头像和消息内容的距离

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
		if let message = self.model, message.messageType != MessageType.sys {
			setTimeArae() // 预设时间区域
		}
		// 设置头像(只有会话消息需要设置头像和昵称)
		if let message = self.model, message.messageType == MessageType.chat {
			setAvatar() // 预设头像
		}
        // 在这里设置发送状态
		if model?.isSelf == true {
			activityIndicator.isHidden = false
			resendButton.isHidden = true
			changeStatusUI()
			// 处理自己的消息发送状态
		} else {// 对方的话，就隐藏掉消息状态
			tipView.isHidden = true
		}
	}
	// 设置时间区域
	func setTimeArae() {
		guard let message = self.model else { return  }
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
	// 设置头像区域
	func setAvatar() {
		guard let message = self.model else { return }
		avatar.kf.setImage(with: URL.init(string: (message.sender?.headImgUrl)!), placeholder: #imageLiteral(resourceName: "user"), options: nil, progressBlock: nil, completionHandler: nil)
		senderName.text = message.senderName
		let contentSize = senderName.sizeThatFits(CGSize.init(width: self.maxMsgWidth, height: CGFloat(Float.greatestFiniteMagnitude)))
		senderName.snp.remakeConstraints { (make) in
			make.size.equalTo(contentSize)
		}
	}

    /// 更新发送状态
    func changeStatusUI() {
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
    }
}

extension KKChatBaseCell {
    /// 改变cell视图显示的代理方法
    func messageStatusChange(_ status: DeliveryStatus) {
        DTLog("BaseCell: 消息发送状态变化： \(status)")
        switch status {
        case .delivered:
            tipView.isHidden = true
        case .delivering:
            resendButton.isHidden = true
            activityIndicator.isHidden = false
        case .failed:
            resendButton.isHidden = false
            activityIndicator.isHidden = true
        }
//        self.layoutIfNeeded()
    }
    
	/// 重新发送操作
	@objc func resend() -> Void {
		// 重新发送消息的操作
        self.model?.deliver()
        changeStatusUI()
	}
}
