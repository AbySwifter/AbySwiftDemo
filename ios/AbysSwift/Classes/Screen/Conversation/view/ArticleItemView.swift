//
//  ArticleItemView.swift
//  AbysSwift
//
//  Created by aby on 2018/5/29.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit

enum ArticleItemType {
    case onlyOne // 只有一个的情况
    case first // 在第一个的情况
    case others // 正常的情况
}

class ArticleItemView: UIView {
    
    var item: ArticlItem? {
        didSet {
            guard let item = self.item else { return }
            let imageURL = URL.init(string: item.image ?? "")
            if let url = imageURL {
                self.icon.kf.setImage(with: url)
            }
            self.titleLabel.text = item.title ?? ""
            self.descriptionLable.text = item.description ?? ""
        }
    }
    var type: ArticleItemType = .onlyOne
    
    lazy var icon: UIImageView = {
        let imageView = UIImageView.init()
        self.addSubview(imageView)
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.numberOfLines = 2
        label.textAlignment = .left
        self.addSubview(label)
        return label
    }()
    
    lazy var descriptionLable: UILabel = {
        let label = UILabel.init()
        label.numberOfLines = 0
        label.textAlignment = .left
        self.addSubview(label)
        return label
    }()
    
    // 第一张图的宽度
    private var imgFirstWidth: CGFloat {
        return UIScreen.main.bounds.width - 40
    }
    
    // 第一张图的高度
    private var imgFirstHeight: CGFloat {
        return imgFirstWidth * 10 / 13
    }
    // 普通item的高度
    var itemHeight: CGFloat {
        return 90.0
    }
    // 普通图片的宽和高
    var itemImageHeight: CGFloat {
        return 60.0
    }
    
    var itemMargin: CGFloat {
        return 15.0
    }
   
    
    /// 返回视图的高度
    var viewHeight: CGFloat {
        switch type {
        case .first:
            return imgFirstHeight
        case .onlyOne:
            return imgFirstHeight + itemHeight
        case .others:
            return itemHeight
        }
    }
    
    var viewWidth: CGFloat {
        return imgFirstWidth
    }
    
    /// 快捷初始化视图
    ///
    /// - Parameter type: 视图类型
    convenience init(type: ArticleItemType, item: ArticlItem) {
        self.init()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        self.type = type
        self.backgroundColor = UIColor.white
        self.item = item
        let imageURL = URL.init(string: item.image ?? "")
        if let url = imageURL {
            self.icon.kf.setImage(with: url)
        }
        self.titleLabel.text = item.title ?? ""
        self.descriptionLable.text = item.description ?? ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switch type {
        case .onlyOne:
            setOnlyOneStyle()
        case .first:
            setFirstStyle()
        case .others:
            setOthersStyle()
        }
    }
    
    @objc
    func tapAction() -> Void {
        NotificationCenter.default.post(name: NSNotification.Name.init(KNoteArticleCellTap), object: self.item?.url ?? "")
    }
}

// MARK: -三种布局的方式
extension ArticleItemView {
    func setOthersStyle() -> Void {
        icon.snp.makeConstraints { (make) in
            make.width.height.equalTo(itemImageHeight)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-itemMargin)
        }
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor.black
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(itemMargin)
            make.right.equalTo(icon.snp.left).offset(-itemMargin)
        }
    }
    func setFirstStyle() -> Void {
        icon.snp.makeConstraints { (make) in
            make.width.equalTo(imgFirstWidth)
            make.height.equalTo(imgFirstHeight)
            make.top.equalTo(self.snp.top)
            make.centerX.equalToSuperview()
        }
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .left
        titleLabel.backgroundColor = UIColor.init(hexString: "666666", alpha: 0.5)
        titleLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-30)
            make.bottom.equalTo(icon.snp.bottom).offset(-5)
            make.centerX.equalToSuperview()
            make.height.lessThanOrEqualTo(80)
        }
    }
    
    func setOnlyOneStyle() -> Void {
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        titleLabel.textColor = UIColor.black
        titleLabel.lineBreakMode = .byTruncatingTail
        descriptionLable.font = UIFont.systemFont(ofSize: 14.0)
        descriptionLable.textColor = UIColor.init(hexString: "666666")
        descriptionLable.lineBreakMode = .byTruncatingTail
        icon.snp.makeConstraints { (make) in
            make.width.equalTo(imgFirstWidth)
            make.height.equalTo(imgFirstHeight)
            make.top.equalTo(self.snp.top)
            make.centerX.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-30)
            make.top.equalTo(icon.snp.bottom).offset(15)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
        }
        descriptionLable.snp.makeConstraints { (make) in
            make.width.equalTo(titleLabel.snp.width)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
        }
    }
}
