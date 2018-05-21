//
//  OtherInfoCell.swift
//  AbysSwift
//
//  Created by aby on 2018/5/15.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit

class OtherInfoCell: UITableViewCell {

    var click:((Int) -> (Void))?
    var otherId: Int?
    lazy var avatar: UIImageView = {
        let avatar = UIImageView.init()
        avatar.contentMode = .scaleAspectFill
        avatar.layer.cornerRadius = W750(45)
        avatar.layer.masksToBounds = true
        return avatar
    }()
    
    lazy var nameLabel: UILabel = {
        let name = UILabel.init()
        name.font = UIFont.systemFont(ofSize: 16.0)
        return name
    }()

    lazy var button: UIButton = {
        let button: UIButton = UIButton.init(type: .custom)
        button.layer.cornerRadius = 3.0
        button.layer.borderColor = ABYGlobalThemeColor().cgColor
        button.layer.borderWidth = 1.0 / UIScreen.main.scale
        button.setTitle("转给ta", for: .normal)
        button.setTitleColor(ABYGlobalThemeColor(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        button.addTarget(self, action: #selector(switchOther), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.isHidden = true
        self.addSubview(nameLabel)
        self.addSubview(button)
        self.addSubview(avatar)
        avatar.snp.makeConstraints { (make) in
            make.width.height.equalTo(W750(90))
            make.centerY.equalTo(self)
            make.left.equalTo(self.snp.left).offset(15)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatar.snp.right).offset(20)
            make.centerY.equalTo(self.snp.centerY)
        }
        button.snp.makeConstraints { (make) in
            make.height.equalTo(W750(52))
            make.width.equalTo(60)
            make.right.equalTo(self.snp.right).offset(-15)
            make.centerY.equalTo(self.snp.centerY)
        }
         self.selectionStyle = .none // 选中样式
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been impeleted")
    }
    
    func setCellWith(model: OtherInfo) {
        self.nameLabel.text = model.name ?? ""
        let url = URL.init(string: model.avatar ?? "")
        self.avatar.kf.setImage(with: url)
        self.otherId = model.id
    }
    
    @objc
    func switchOther() -> Void {
        if let action = self.click {
            action(self.otherId ?? 0)
        }
    }
    
}
