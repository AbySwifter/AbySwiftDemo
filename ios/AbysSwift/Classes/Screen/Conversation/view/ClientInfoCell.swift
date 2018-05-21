//
//  ClientInfoCell.swift
//  AbysSwift
//  用户信息页面的item： 高度是W750(107)
//  Created by aby on 2018/5/14.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit

class ClientInfoCell: UITableViewCell {

    lazy var icon: UIImageView = {
        let view = UIImageView.init()
        view.contentMode = .left
        return view
    }()
    
    lazy var title: UILabel = {
        let title = UILabel.init()
        title.font = UIFont.systemFont(ofSize: 16.0)
        title.textColor = UIColor.init(hexString: "666666")
        return title
    }()
    
    lazy var content: UILabel = {
        let content: UILabel = UILabel.init()
        content.font = UIFont.systemFont(ofSize: 16.0)
        content.textColor = UIColor.init(hexString: "666666")
        return content
    }()
    
    lazy var separator: UIView = {
        let separator = UIView.init(frame: CGRect.init(x: 15, y: self.frame.height-1, width: self.frame.width - 30, height: 1/UIScreen.main.scale))
        separator.backgroundColor = UIColor.init(hexString: "cccccc")
        return separator
    }()
    
    /// 重写初始化方法
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.isHidden = true // 隐藏原有的内容视图
        self.backgroundColor = UIColor.init(hexString: "f5f5f5")
        self.selectionStyle = .none // 选中样式
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if subviews.contains(separator) {
            return
        }
        self.addSubview(separator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been impleted")
    }
    
    private func setup() -> Void {
        self.addSubview(icon)
        icon.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(15)
            make.height.equalTo(W750(50))
            make.width.equalTo(W750(90))
            make.centerY.equalTo(self)
        }
        self.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.left.equalTo(icon.snp.right)
            make.centerY.equalTo(self)
//            make.size.equalTo(title)
        }
        self.addSubview(content)
        content.snp.makeConstraints { (make) in
            make.left.equalTo(title.snp.right)
            make.centerY.equalTo(self)
        }
    }
    
    func setWidth(data: (UIImage, String, String)) -> Void {
        self.icon.image = data.0
        self.title.text = data.1
        self.content.text = data.2
    }
}
