//
/**
* 好看的皮囊千篇一律，有趣的灵魂万里挑一
* 创建者: 王勇旭 于 2018/4/29
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

class KKChatAudioCell: KKChatBaseCell {

	override var model: Message? { didSet { setModel() }}

	// 播放声音的按钮
	lazy var voiceButton: UIButton = {
		let voiceBtn = UIButton.init(type: .custom)
		voiceBtn.setImage(#imageLiteral(resourceName: "message_voice_receiver_playing_3"), for: .normal)
		voiceBtn.imageView?.animationDuration = 1
		voiceBtn.imageEdgeInsets = UIEdgeInsetsMake(0, voiceIconInsert, 0, voiceIconInsert)
		voiceBtn.adjustsImageWhenHighlighted = false
		return voiceBtn
	}()

	lazy var durationLabel: UILabel = {
		let durationL = UILabel.init()
		durationL.font = UIFont.systemFont(ofSize: 12.0)
		durationL.text = "60\""
		durationL.textColor = UIColor.init(hexString: "999999")
		return durationL
	}()

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		// 给消息内容添加子视图
		msgContent.addSubview(voiceButton)
		msgContent.addSubview(durationLabel)
		// 给按钮添加事件
		voiceButton.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension KKChatAudioCell {
	// 语音气泡的高度
	var voiceHeight: CGFloat {
		return 40
	}
	// 语音消息Icon的插入距离
	var voiceIconInsert: CGFloat {
		return 8
	}

	var durationInsert: CGFloat {
		return 6
	}
}

extension KKChatAudioCell {
	@objc
	func playAudio() -> Void {
        guard let voice = self.model?.content?.voice else { return }
        if (voiceButton.imageView?.isAnimating)! {
            self.voiceButton.imageView?.stopAnimating()
            AudioTool.defaut.stopPlay()
        } else {
            voiceButton.imageView?.startAnimating()
            AudioTool.defaut.play(url: voice)
            AudioTool.defaut.playFinished = {
                self.voiceButton.imageView?.stopAnimating()
            }
        }
		
	}
}


extension KKChatAudioCell {

	func setModel() -> Void {
        self.model?.delegate = self // 设置代理
		// 根据消息模型创建视图
		guard model?.content?.type == MSG_ELEM.voice else { return }
		guard let message = self.model else { return }
		// 语音消息的高度是固定的
        
		durationLabel.text = "\(message.content?.duration ?? 0)\"" // 设置语音消息的时间
		durationLabel.sizeToFit() //label自适应大小

		// 计算语音消息的宽度，最小是40，最大是200.
		var voiceWidth = 40 + 160 * (CGFloat.init(model?.content?.duration ?? 0) / 60)
		if voiceWidth > 200 { voiceWidth = 200 } // 最大宽度为200

		// 设置泡泡
		let img = message.isSelf ? #imageLiteral(resourceName: "mebubble") : #imageLiteral(resourceName: "friendbubble")
		let normalImg = img.resizableImage(withCapInsets: UIEdgeInsetsMake(20, 20, 20, 20), resizingMode: .stretch)
		bubbleView.image = normalImg
        // 头像的通用样式
        avatar.snp.remakeConstraints { (make) in
            make.width.height.equalTo(self.avatarWidth)
            make.top.equalTo(self.snp.top).offset(verticalMargin)
        }
        // 发送者的姓名
        senderName.snp.remakeConstraints { (make) in
            make.top.equalTo(msgContent.snp.top)
        }
		// 重新布局
		bubbleView.snp.remakeConstraints { (make) in
			make.top.equalTo(senderName.snp.bottom).offset(self.n_cOffset)
            make.bottom.equalToSuperview().offset(-10) // 气泡距离内容有10的距离
			make.height.equalTo(self.voiceHeight) // 设置气泡的高度
			make.width.equalTo(voiceWidth) // 设置气泡的宽度
		}
		voiceButton.snp.remakeConstraints { (make) in
			make.height.equalTo(35)
			make.width.equalTo(voiceWidth)
			make.centerY.equalTo(bubbleView.snp.centerY)
		}
		durationLabel.snp.remakeConstraints { (make) in
			make.height.equalTo(25)
			make.width.equalTo(durationLabel.snp.width)
			make.bottom.equalTo(voiceButton.snp.bottom)
		}
        // 消息发送结果的通用
        tipView.snp.remakeConstraints { (make) in
            make.centerY.equalTo(bubbleView.snp.centerY)
            make.width.height.equalTo(30)
        }
        // 消息内容的通用样式
        msgContent.snp.remakeConstraints { (make) in
            make.top.equalTo(avatar.snp.top)
            make.width.equalToSuperview().offset(-avatarTotalWidth)
            make.bottom.equalTo(bubbleView.snp.bottom).offset(10)
        }
		if message.isSelf {
			// 设置通用的样式
            avatar.snp.makeConstraints { (make) in
                make.right.equalTo(self.snp.right).offset(-self.avatarMargin)
            }
            senderName.snp.makeConstraints { (make) in
                make.right.equalToSuperview()
            }
			bubbleView.snp.makeConstraints { (make) in
				make.right.equalToSuperview()
			}
			// 语音消息独有的
			voiceButton.snp.makeConstraints { (make) in
				make.right.equalTo(bubbleView.snp.right)
			}
			durationLabel.snp.makeConstraints { (make) in
				make.right.equalTo(bubbleView.snp.left).offset(-durationInsert)
			}
            tipView.snp.makeConstraints { (make) in
                make.right.equalTo(bubbleView.snp.left).offset(-25)
            }
            msgContent.snp.makeConstraints { (make) in
                make.right.equalTo(avatar.snp.left).offset(-self.avatarToMsg)
            }
			voiceButton.setImage(#imageLiteral(resourceName: "message_voice_sender_playing_3"), for: .normal)
			voiceButton.contentHorizontalAlignment = .right
			voiceButton.imageView?.animationImages = [
				#imageLiteral(resourceName: "message_voice_sender_playing_1"),
				#imageLiteral(resourceName: "message_voice_sender_playing_2"),
				#imageLiteral(resourceName: "message_voice_sender_playing_3")
			]
		} else {
			// 设置通用的样式
            avatar.snp.makeConstraints { (make) in
                make.left.equalTo(self.snp.left).offset(self.avatarMargin)
            }
            senderName.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
            }
			bubbleView.snp.makeConstraints { (make) in
				make.left.equalToSuperview()
			}
			// 语音消息独有的
			voiceButton.snp.makeConstraints { (make) in
				make.left.equalTo(bubbleView.snp.left)
			}
			durationLabel.snp.makeConstraints { (make) in
				make.left.equalTo(bubbleView.snp.right).offset(durationInsert)
			}
            msgContent.snp.makeConstraints { (make) in
                make.left.equalTo(avatar.snp.right).offset(self.avatarToMsg)
            }
			voiceButton.setImage(#imageLiteral(resourceName: "message_voice_receiver_playing_3"), for: .normal)
			voiceButton.contentHorizontalAlignment = .left
			voiceButton.imageView?.animationImages = [
				#imageLiteral(resourceName: "message_voice_receiver_playing_1"),
				#imageLiteral(resourceName: "message_voice_receiver_playing_2"),
				#imageLiteral(resourceName: "message_voice_receiver_playing_3")
			]
		}
        self.layoutSubviews()
		self.model?.cellHeight = getCellHeight()
	}
}
