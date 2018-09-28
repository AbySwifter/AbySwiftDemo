//
//  KKArrticalCell.swift
//  AbysSwift
//
//  Created by aby on 2018/5/29.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//
// 分两种情况去展示： 1、只有一行消息的时候。2、有多条消息的时候

import UIKit

class KKArrticalCell: KKChatBaseCell {
    override var model: Message? {
        didSet {
            setModel()
        }
    }
    lazy var articleContent: UIView = {
        let view = UIView.init()
        return view
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.msgContent.isHidden = true
        self.contentView.isHidden = true
        self.addSubview(articleContent)
        articleContent.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been impleted")
    }
    override func getCellHeight() -> CGFloat {
        self.layoutIfNeeded()
        let contentHeight = self.articleContent.height
        return contentHeight + verticalMargin + 10
    }
}

extension KKArrticalCell {
    
    /// 设置模型
    func setModel() -> Void {
        guard model?.content?.type == MSG_ELEM.articleElem else {
            return
        }
        guard let datas = model?.content?.data else { return }
        articleContent.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(verticalMargin)
        }
        for view in articleContent.subviews {
            view.removeFromSuperview()
        }
//         首先判断情况，决定显示几个
        if datas.count == 1 {
            // 只有一个的情况
            let item = createItem(type: .onlyOne, item: datas[0], tag: 1001)
            self.articleContent.addSubview(item) // 放在msgContent上
            item.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.width.equalTo(item.viewWidth)
                make.height.equalTo(item.viewHeight)
                make.centerX.equalTo(self.snp.centerX)
            }
            articleContent.snp.makeConstraints { (make) in
                make.height.equalTo(item.viewHeight)
            }
        } else {
            var firstHeight:CGFloat = 180
            var othersHeight: CGFloat = 90
            var totalHeight: CGFloat = 0
            // 有多个的情况
            for i in 0 ..< datas.count {
                var item: ArticleItemView!
                if i == 0 {
                    item = createItem(type: .first, item: datas[i], tag: 1001 + i)
                    firstHeight = item.viewHeight
                    self.articleContent.addSubview(item)
                    item.snp.makeConstraints { (make) in
                        make.width.equalTo(item.viewWidth)
                        make.height.equalTo(item.viewHeight)
                        make.top.equalTo(articleContent.snp.top)
                        make.centerX.equalToSuperview()
                    }
                } else {
                    item = createItem(type: .others, item: datas[i], tag: 1001 + i)
                    othersHeight = item.viewHeight
                    self.articleContent.addSubview(item)
                    item.snp.makeConstraints { (make) in
                        make.width.equalTo(item.viewWidth)
                        make.height.equalTo(item.viewHeight)
                        make.top.equalTo(articleContent.snp.top).offset(firstHeight + othersHeight * CGFloat.init(i - 1))
                        make.centerX.equalToSuperview()
                    }
                }
                totalHeight += item.viewHeight
            }
            articleContent.snp.makeConstraints { (make) in
                make.height.equalTo(totalHeight)
            }
        }
        self.layoutSubviews()
        model?.cellHeight = getCellHeight()
    }
    
    func createItem(type: ArticleItemType, item: ArticlItem, tag: Int) -> ArticleItemView {
        let articItem = ArticleItemView.init(type: type, item: item)
        articItem.tag = tag
        return articItem
    }
}
