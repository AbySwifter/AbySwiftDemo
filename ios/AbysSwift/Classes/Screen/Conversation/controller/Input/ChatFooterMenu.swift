//
//  ChatFooterMenu.swift
//  AbysSwift
//
//  Created by aby on 2018/3/29.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit

enum ChatFootMenuTag: Int {
	case camera = 1000
	case photo = 1001
	case product = 1002
}

protocol ChatFootMenuDelegate {
	func menuAction(type: ChatFootMenuTag) -> Void
}

class ChatFooterMenu: UIView {
	let menuSpace: CGFloat = (W750(750) - 48*4) / 6
	let menuHeight: CGFloat = 48
	let menuTopSpace: CGFloat = 14

	var delegate: ChatFootMenuDelegate?

	var btns: Array<UIButton> = [];

	override init(frame: CGRect) {
		super.init(frame: frame)
		let images = [#imageLiteral(resourceName: "camera"), #imageLiteral(resourceName: "picture_icon"), #imageLiteral(resourceName: "product")]
		setItems(images: images)
		makeBtnContainer()
//		ABYPrint(message: "我是Menu菜单的\(#function)")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
//		ABYPrint(message: "我是Menu菜单的\(#function)")
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setItems(images: [UIImage]) -> Void {
		var i = 0
		for item in images {
			let btn = UIButton.init(type: .custom)
			btn.setImage(item, for: .normal)
			btn.layer.cornerRadius = 5.0
			btn.layer.borderColor = UIColor.init(hexString: "d7d7d9").cgColor
			btn.layer.borderWidth = 1 / UIScreen.main.scale
			btn.tag = i + 1000
			btn.addTarget(self, action: #selector(menuAction(_:)), for: .touchUpInside)
			self.addSubview(btn)
			self.btns.append(btn)
			i += 1
		}
	}

	func makeBtnContainer() -> Void {
		var lastBtn: UIButton? = nil
		for btn in self.btns {
			btn.snp.makeConstraints({ (make) in
				make.height.width.equalTo(self.menuHeight)
				make.top.equalToSuperview().offset(self.menuTopSpace)
				if let leftView = lastBtn {
					make.left.equalTo(leftView.snp.right).offset(self.menuSpace)
				} else {
					make.left.equalToSuperview().offset(self.menuSpace)
				}
			})
			lastBtn = btn
		}
	}

	@objc
	func menuAction(_ sender: UIButton) -> Void {
		// 根据Tag去判断点击了哪一个
		guard let type = ChatFootMenuTag.init(rawValue: sender.tag) else {
			return
		}
		self.delegate?.menuAction(type: type)
	}
	/*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
