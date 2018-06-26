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
    case speakRoutine = 1002
	case product = 1003
}

protocol ChatFootMenuDelegate {
	func menuAction(type: ChatFootMenuTag) -> Void
}

class ChatFooterMenu: UIView {
	let menuSpace: CGFloat = (W750(750) - 48*4) / 6
	let menuHeight: CGFloat = 48
	let menuTopSpace: CGFloat = 14

	var delegate: ChatFootMenuDelegate?

	var btns: Array<(UIButton, UIView)> = [];
    
	override init(frame: CGRect) {
		super.init(frame: frame)
		let images = [#imageLiteral(resourceName: "camera"), #imageLiteral(resourceName: "picture_icon"), #imageLiteral(resourceName: "speakRoutine"), #imageLiteral(resourceName: "product")]
		setItems(images: images)
		makeBtnContainer()
//		DTLog(message: "我是Menu菜单的\(#function)")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
//		DTLog(message: "我是Menu菜单的\(#function)")
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
            let tip = createtip()
            tip.tag = i + 2000
            btn.addSubview(tip)
			self.btns.append((btn, tip))
			i += 1
		}
	}
    
    func createtip() -> UIView {
        let view = UIView.init()
        view.backgroundColor = UIColor.red
        view.layer.cornerRadius = 4.0
        view.isHidden = true
        return view
    }

	func makeBtnContainer() -> Void {
		var lastBtn: UIButton? = nil
		for (btn, tip) in self.btns {
			btn.snp.makeConstraints({ (make) in
				make.height.width.equalTo(self.menuHeight)
				make.top.equalToSuperview().offset(self.menuTopSpace)
				if let leftView = lastBtn {
					make.left.equalTo(leftView.snp.right).offset(self.menuSpace)
				} else {
					make.left.equalToSuperview().offset(self.menuSpace)
				}
			})
            tip.snp.makeConstraints { (make) in
                make.width.height.equalTo(8.0)
                make.top.equalTo(btn.snp.top).offset(-3.0)
                make.right.equalTo(btn.snp.right).offset(3.0)
            }
			lastBtn = btn
		}
	}

	@objc
	private func menuAction(_ sender: UIButton) -> Void {
		// 根据Tag去判断点击了哪一个
		guard let type = ChatFootMenuTag.init(rawValue: sender.tag) else {
			return
		}
		self.delegate?.menuAction(type: type)
	}
    
    func changeTips(who:[ChatFootMenuTag], status: Bool) -> Void {
        for item in who {
            let i = item.rawValue - 1000
            let reslut = self.btns[i]
            reslut.1.isHidden = status
        }
    }
}
