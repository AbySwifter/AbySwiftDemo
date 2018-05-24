//
//  ConversationCell.swift
//  AbysSwift
//
//  Created by aby on 2018/3/14.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell, ConversationDelegate {
	static let identifierString = "ConversationCell"
	// 需要的UI组件
	let headImageView = UIImageView.init()
	let userName = UILabel.init()
	let timeText = UILabel.init()
	let contentText = UILabel.init() // 用富文本去绘制不同的文字颜色
	let borderBottom: UIView = UIView.init()
	// 当前Cell绑定的会话
	var conversation: Conversation? {
		didSet {
			if conversation != nil && conversation?.type == .NormalType {
				dispatchTimer()
			}
		}
	}

	let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
	var isTimerWork: Bool = false

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.setupUI()
		self.selectionStyle = .default
	}
    
	// MARK: - 数据设置自身的显示数据
	func setCellWith(model: Conversation) -> Void {
		self.userName.text = model.name
		// 判断会话为空，或者新的model和已有的会话不相等时
		if conversation == nil || conversation !== model {
			self.conversation = model
			self.conversation?.delegate = self
		}
		if model.type == .NormalType {
			// TODO: 处理网络缓存头像
			self.userName.text = model.name
			if let url = URL.init(string: model.headImgUrl!) {
				self.headImageView.kf.setImage(with: url)
			}
			self.contentText.attributedText = model.contentAttributedStr
		} else {
			let image = #imageLiteral(resourceName: "notification_avatar")
			self.headImageView.image = image
			self.userName.text = model.name
		}
	}
	// MARK: - 布局
	private func setupUI() -> Void {
		// 开始布局
		// 头视图的view
		self.contentView.addSubview(headImageView)
		self.contentView.addSubview(userName)
		userName.numberOfLines = 1
		userName.font = UIFont.systemFont(ofSize: W750(32))
		userName.textColor = UIColor.init(hexString: "333333")
		self.contentView.addSubview(timeText)
		timeText.numberOfLines = 1
        timeText.font = UIFont.systemFont(ofSize: W750(24.0))
        timeText.textColor = UIColor.init(hexString: "666666") //时间展示的颜色
		timeText.textAlignment = .right
		self.contentView.addSubview(contentText)
		contentText.numberOfLines = 1
//		contentText.font = UIFont.systemFont(ofSize: W750(26))
//		contentText.textColor = UIColor.init(hexString: "999999")
		self.contentView.addSubview(borderBottom)
		borderBottom.backgroundColor = UIColor.init(hexString: "dcdcdc")
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		makeSelfConstraints()
	}
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		// 设置选中为None的时候，点击依旧有效
        // Configure the view for the selected state
		
    }

	deinit {
		conversation = nil
		stopTimer()
	}

	func dispatchTimer() -> Void {
		timer.schedule(deadline: .now(), repeating: 1.0)
		timer.setEventHandler {
			DispatchQueue.main.async {
				self.timeText.text = self.conversation?.tickTock ?? ""
			}
		}
		if !self.isTimerWork {
			isTimerWork = true
			timer.resume()
		}
	}

	func stopTimer() -> Void {
		timer.cancel()
	}

	func lastMessageChange(text: String, atttributeText: NSMutableAttributedString) {
		self.contentText.attributedText = atttributeText
	}
	func unReadCountChange(count: Int) {

	}
}

extension ConversationCell {

	func makeSelfConstraints() -> Void {
		headImageView.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.left.equalToSuperview().offset(W750(30))
			make.height.width.equalTo(W750(92))
		}
		headImageView.backgroundColor = UIColor.init(hexString: "92c360")
		headImageView.layer.cornerRadius = headImageView.bounds.width / 2
		headImageView.layer.masksToBounds = true
		headImageView.contentMode = .scaleAspectFit
		userName.snp.makeConstraints { (make) in
			make.bottom.equalTo(headImageView.snp.centerY).offset(-2)
			make.left.equalTo(headImageView.snp.right).offset(W750(30))
			make.width.lessThanOrEqualTo(W750(375))
		}
		timeText.snp.makeConstraints { (make) in
			make.bottom.equalTo(headImageView.snp.centerY).offset(-2)
			make.right.equalToSuperview().offset(W750(-30))
			//			make.width.lessThanOrEqualTo(W750(200))
			make.width.equalTo(W750(200))
			make.height.equalTo(W750(35))
		}
		contentText.snp.makeConstraints { (make) in
			make.top.equalTo(headImageView.snp.centerY).offset(2)
			make.right.equalToSuperview().offset(W750(-30))
			make.left.equalTo(headImageView.snp.right).offset(W750(30))
		}
		borderBottom.snp.makeConstraints { (make) in
			make.height.equalTo(1/UIScreen.main.scale)
			make.left.equalToSuperview().offset(W750(30))
			make.right.equalToSuperview().offset(W750(-30))
			make.bottom.equalToSuperview()
		}
	}
}
