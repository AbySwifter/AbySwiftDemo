//
//  MineCell.swift
//  AbysSwift
//
//  Created by aby on 2018/2/27.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit


class MineCell: UITableViewCell {
	let icon: UIImageView = UIImageView.init()
	let cellTitle: UILabel = UILabel.init()
	let rightIcon: UIImageView = UIImageView.init()
    let subTitle: UILabel = UILabel.init()
    
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setUI()
		self.selectionStyle = .none
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	func setCell(data: SettingCellData) -> Void {
		icon.image = data.icon
		cellTitle.text = data.title
        if data.hasSubTitle {
            rightIcon.isHidden = true
            subTitle.isHidden = false
            subTitle.text = data.subTitle
        } else {
            subTitle.isHidden = true
            rightIcon.isHidden = false
        }
        
	}
	private func setUI() {
		self.addSubview(icon)
		icon.snp.makeConstraints { (make) in
			make.height.equalTo(W750(40))
			make.centerY.equalToSuperview().offset(W750(13))
			make.left.equalToSuperview().offset(20)
		}
		icon.contentMode = .scaleAspectFit
		self.addSubview(cellTitle)
		cellTitle.snp.makeConstraints { (make) in
			make.left.equalTo(icon.snp.right).offset(W750(30))
			make.centerY.equalToSuperview().offset(W750(13))
		}
		cellTitle.font = UIFont.systemFont(ofSize: W750(32))
		cellTitle.textColor = UIColor.init(hexString: "666666")
		self.addSubview(rightIcon)
		rightIcon.snp.makeConstraints { (make) in
			make.width.equalTo(W750(17))
			make.height.equalTo(W750(30))
			make.right.equalToSuperview().offset(-20)
			make.centerY.equalToSuperview().offset(W750(13))
		}
		rightIcon.image = #imageLiteral(resourceName: "icon_entrance")
		let view = UIView.init()
		self.addSubview(view)
		view.snp.makeConstraints { (make) in
			make.left.equalToSuperview().offset(20)
			make.right.equalToSuperview().offset(-20)
			make.height.equalTo(1/UIScreen.main.scale)
			make.bottom.equalToSuperview().offset(1)
		}
		view.backgroundColor = UIColor.init(hexString: "cccccc")
        self.addSubview(subTitle)
        subTitle.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-20)
            make.centerY.equalTo(cellTitle.snp.centerY)
        }
        subTitle.font = UIFont.systemFont(ofSize: W375(14.0))
        subTitle.textColor = UIColor.init(hexString: "666666")
	}
}
