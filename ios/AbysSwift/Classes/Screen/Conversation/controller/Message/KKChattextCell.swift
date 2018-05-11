//
/**
* 好看的皮囊千篇一律，有趣的灵魂万里挑一。
* 创建者: aby 于 2018/4/18
* Copyright © 2018年 Aby.wang. All rights reserved.
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
import Kingfisher

class KKChattextCell: KKChatBaseCell {
	override var model: Message? {
		didSet {
			setModel()
		}
	}

	lazy var contentLabel: UILabel = {
		let contentL = UILabel.init()
		contentL.numberOfLines = 0 // 可以多行显示
		contentL.textAlignment = .left // 默认是从左对齐
		contentL.font = UIFont.systemFont(ofSize: 16.0)
		return contentL
	}()
    
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		// 只需要在气泡视图上添加一个Label即可
		contentLabel.font = UIFont.systemFont(ofSize: 16.0)
		bubbleView.addSubview(self.contentLabel)
	}
}

extension KKChattextCell {
	fileprivate func setModel() {
        self.model?.delegate = self // 创建代理
		// 根据消息模型创建视图布局
		guard model?.content?.type == MSG_ELEM.text else { return }
		guard let message = self.model else { return }
		// FIXME: 做表情的匹配
		contentLabel.text = message.content?.text ?? ""
		// 设置泡泡
		let img = message.isSelf ? #imageLiteral(resourceName: "mebubble") : #imageLiteral(resourceName: "friendbubble")
		let color = message.isSelf ? UIColor.white : UIColor.black
		contentLabel.textColor = color
		let normalImage = img.resizableImage(withCapInsets: UIEdgeInsetsMake(10, 10, 10, 10), resizingMode: .stretch)
		bubbleView.image = normalImage
		// 计算尺寸, 最大宽高不限
		let contentSize = contentLabel.sizeThatFits(CGSize.init(width: self.maxMsgWidth, height: CGFloat(Float.greatestFiniteMagnitude)))
        // 头像的通用样式
        avatar.snp.remakeConstraints { (make) in
            make.width.height.equalTo(self.avatarWidth)
            make.top.equalTo(self.snp.top).offset(verticalMargin)
        }
        // 发送者的姓名
        senderName.snp.remakeConstraints { (make) in
            make.top.equalTo(msgContent.snp.top)
        }
		// 计算完成以后开始重新布局
		bubbleView.snp.remakeConstraints { (make) in
			make.top.equalTo(senderName.snp.bottom).offset(n_cOffset)
            make.bottom.equalToSuperview().offset(-10)
			make.bottom.equalTo(contentLabel.snp.bottom).offset(10)
		}
		contentLabel.snp.remakeConstraints { (make) in
			make.height.equalTo(contentSize.height)
			make.width.equalTo(contentSize.width)
		}
        // 消息内容的通用样式
        msgContent.snp.remakeConstraints { (make) in
            make.top.equalTo(avatar.snp.top)
            make.width.equalToSuperview().offset(-avatarTotalWidth)
            make.bottom.equalTo(bubbleView.snp.bottom).offset(10)
        }
        // 消息发送结果的通用
        tipView.snp.remakeConstraints { (make) in
            make.centerY.equalTo(bubbleView.snp.centerY)
            make.width.height.equalTo(30)
        }
        // 根据是否为自己发送的消息来调整UI
		if message.isSelf {
            avatar.snp.makeConstraints { (make) in
                make.right.equalTo(self.snp.right).offset(-self.avatarMargin)
            }
            senderName.snp.makeConstraints { (make) in
                make.right.equalToSuperview()
            }
			bubbleView.snp.makeConstraints { (make) in
				make.right.equalToSuperview()
				make.left.equalTo(contentLabel.snp.left).offset(-10)
				make.right.equalTo(contentLabel.snp.right).offset(10)
			}
			contentLabel.snp.makeConstraints { (make) in
				make.top.equalTo(bubbleView.snp.top).offset(10)
			}
			tipView.snp.makeConstraints { (make) in
				make.right.equalTo(bubbleView.snp.left)
			}
            msgContent.snp.makeConstraints { (make) in
                make.right.equalTo(avatar.snp.left).offset(-self.avatarToMsg)
            }
		} else {
            avatar.snp.makeConstraints { (make) in
                make.left.equalTo(self.snp.left).offset(self.avatarMargin)
            }
            senderName.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
            }
			bubbleView.snp.makeConstraints { (make) in
				make.left.equalToSuperview()
				make.right.equalTo(contentLabel.snp.right).offset(10)
				make.left.equalTo(contentLabel.snp.left).offset(-10)
			}
			contentLabel.snp.makeConstraints { (make) in
				make.top.equalTo(bubbleView.snp.top).offset(10)
			}
			tipView.snp.makeConstraints {
				$0.left.equalTo(bubbleView.snp.right)
			}
            msgContent.snp.makeConstraints { (make) in
                make.left.equalTo(avatar.snp.right).offset(self.avatarToMsg)
            }
		}
        self.layoutSubviews()
		// 最后获取到当前cell的高度
		self.model?.cellHeight = getCellHeight()
	}
}
