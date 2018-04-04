//
//  OhterDataView.swift
//  AbysSwift
//
//  Created by aby on 2018/3/8.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit

class OtherDataView: UIView {
	let titleLabel: UILabel = UILabel.init()
	let contentLabel: UILabel = UILabel.init()
	private let stackView: UIStackView = UIStackView.init()
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor.white
		addSubview(stackView)
		stackView.axis = .vertical
		stackView.spacing = 1.0
		stackView.alignment = .center
		stackView.distribution = .equalCentering
		contentLabel.font = UIFont.systemFont(ofSize: W750(40))
		contentLabel.textColor = UIColor.init(hexString: "333333")
		titleLabel.font = UIFont.systemFont(ofSize: W750(24))
		titleLabel.textColor = UIColor.init(hexString: "999999")
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		stackView.snp.makeConstraints { (make) in
			make.center.equalToSuperview()
//			make.size.equalToSuperview()
		}
		stackView.addArrangedSubview(contentLabel)
		stackView.addArrangedSubview(titleLabel)
	}

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
