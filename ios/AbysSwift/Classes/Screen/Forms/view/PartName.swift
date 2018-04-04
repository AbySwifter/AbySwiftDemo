//
//  PartName.swift
//  AbysSwift
//
//  Created by aby on 2018/3/7.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit

class PartNameView: UIView {
	var titleLabel: UILabel = UILabel.init()
	private let leftLine:UIView = UIView.init()
	private let rightLine: UIView = UIView.init()
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.addSubview(titleLabel)
		self.addSubview(leftLine)
		self.addSubview(rightLine)
		setLabel()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutUI()
	}

	func setLabel() -> Void {
		titleLabel.textColor = UIColor.init(hexString: "999999")
		titleLabel.font = UIFont.systemFont(ofSize: 14.0)
		leftLine.backgroundColor = UIColor.init(hexString: "cccccc")
		rightLine.backgroundColor = UIColor.init(hexString: "cccccc")
	}

	func layoutUI() -> Void {
		// 在这里绘制布局
		titleLabel.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.top.equalToSuperview().offset(35.0)
			make.bottom.equalToSuperview().offset(-20.0)
		}
		leftLine.snp.makeConstraints { (make) in
			make.height.equalTo(2.0)
			make.width.equalTo(18.0)
			make.centerY.equalTo(titleLabel.snp.centerY)
			make.right.equalTo(titleLabel.snp.left).offset(-10.0)
		}
		rightLine.snp.makeConstraints { (make) in
			make.size.equalTo(leftLine)
			make.centerY.equalTo(titleLabel.snp.centerY)
			make.left.equalTo(titleLabel.snp.right).offset(10.0)
		}
	}
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
