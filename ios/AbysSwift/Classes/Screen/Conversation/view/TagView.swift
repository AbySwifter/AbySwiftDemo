//
//  TagView.swift
//  AbysSwift
//
//
//  Created by aby on 2018/6/14.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//
// @class TagView
// @abstract 标签页
// @discussion 展示标签
//
import UIKit

// 标签视图的代理方法
protocol TagViewDelegate {
    func touchTag(tag: Int, title: String) -> Void
    func touchTagClose(tag: Int, title: String) -> Void
    func touchTagAdd(tag: Int) -> Void
}

extension TagViewDelegate {
    func touchTag(tag: Int, title: String) -> Void {
        ABYPrint("执行了默认的点击方法")
    }
    
    func touchTagClose(tag: Int, title: String) -> Void {
        ABYPrint("执行了默认的删除方法")
    }
    
    func touchTagAdd(tag: Int) -> Void {}
}

class TagView: UIView {
    var delegate: TagViewDelegate? // 标签视图的代理
    var showAddBtn: Bool = true // 是否显示添加按钮
    /// 标签间间距
    var marginX: CGFloat = W375(20)
    /// 行高
    var rowHeight: CGFloat = W375(45)
    /// 标签数组
    var tags: Array<String> = [String]()
    /// 行的最大宽度
    var maxRowWidth: CGFloat = W375(375) // 默认为屏幕宽
    /// 行数
    var rowNumber: CGFloat {
        return currentRow + 1
    }
    /// 自适应的高度
    var totalHeight: CGFloat {
        return rowNumber*rowHeight
    }
    
    var showClose: Bool = true
    /// MARK: private proprites
    private var totalRowW: CGFloat = 0 // 用来记录当前最后一行的宽度
    private var currentRow: CGFloat = 0 // 记录当最后一行的行数
    private var lastButton: UIButton? // 记录当前最后一个button（为nil说明需要换行）
    
    lazy var addButton: UIButton = {
        let button = UIButton.init()
        button.setTitle("添加标签", for: .normal)
        button.setTitleColor(UIColor.init(hexString: "adadad"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: W375(14))
        button.setBackgroundImage(UIColor.white.trans2Image(), for: .normal)
        let bounds = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: W375(83), height: W375(30)))
        let border = CAShapeLayer.init()
        border.strokeColor = UIColor.init(hexString: "adadad").cgColor
        border.fillColor = UIColor.clear.cgColor
        let path = UIBezierPath.init(roundedRect: bounds, cornerRadius: W375(15))
        border.path = path.cgPath
        border.frame = bounds
        border.lineWidth = 1.0
        border.lineDashPattern = [NSNumber.init(value: 4), NSNumber.init(value: 2)]
        button.layer.cornerRadius = W375(15)
        button.layer.masksToBounds = true
        button.layer.addSublayer(border)
        button.addTarget(self, action:#selector(addBtnAction(_ :)) , for: .touchUpInside)
        return button
    }()
    
    //MARK: Initial Methods
    convenience init(tags: [String], maxRowW: CGFloat, rowH: CGFloat, marginX: CGFloat, showAddBtn: Bool = true, showClose: Bool = true) {
        self.init()
        self.marginX = marginX
        self.maxRowWidth = maxRowW
        self.rowHeight = rowH
        self.tags = tags
        self.showAddBtn = showAddBtn
        self.showClose = showClose
        self.createTags()
    }
    
    func updataTag() -> Void {
        for item in self.subviews {
            item.removeFromSuperview()
        }
        lastButton = nil
        currentRow = 0
        totalRowW = 0
        self.createTags() // 重新创建
    }
    
    //MARK: Internal Methods
    private func createTag(title: String) -> UIButton {
        let button = UIButton.init(bgColor: UIColor.init(hexString: "f5f5f5"), disabledColor: nil, title: title, titleColor: UIColor.init(hexString: "333333"), titleHighlightedColor: nil)
        button.titleLabel?.font = UIFont.systemFont(ofSize: W375(14))
        button.addTarget(self, action: #selector(tagTouchAction(_:)), for: .touchUpInside)
        button.layer.cornerRadius = W375(15)
        button.adjustsImageWhenHighlighted = true
        return button
    }
    
    private func createClose() -> UIButton {
        let button = UIButton.init(type: .custom)
        button.setImage(#imageLiteral(resourceName: "tag_close"), for: .normal)
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
        return button
    }
    
    private func addClose(in button: UIButton, tag: Int) -> Void {
        let close = createClose()
        close.tag = tag
        self.addSubview(close)
        close.snp.makeConstraints { (make) in
            make.top.equalTo(button.snp.top)
            make.right.equalTo(button.snp.right).offset(5)
            make.height.width.equalTo(W375(15))
        }
    }
    
    //MARK: Public Methods
    func createTags() -> Void {
        let btnHeight: CGFloat = W375(30) // 每个按钮的高度
        let rowMarginTop: CGFloat = (rowHeight - btnHeight) / 2
        var needChangeline: Bool = false
        for i in 0..<tags.count {
            let button = createTag(title: tags[i])
            // 决定是否可以点击
            button.isEnabled = !showClose
            //自适应title的宽度
            button.titleLabel?.sizeToFit()
            button.tag = 1000 + i // button的tag是1000以上
            var btnW = (button.titleLabel?.bounds.width)! + W375(20)
            // 判断是否需要换行
            if btnW < maxRowWidth - totalRowW {
                // 不需要换行
                needChangeline = false
                totalRowW += btnW + marginX
            } else {
                needChangeline = true
                // 需要换行
                if btnW > maxRowWidth {
                    // 如果标签的宽度比最大的还宽，那就得处理一下了
                    btnW = maxRowWidth
                }
                currentRow += 1 // 行数加1
                totalRowW = btnW + marginX
            }
            self.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.top.equalTo(self.snp.top).offset(currentRow*rowHeight + rowMarginTop)
                make.height.equalTo(btnHeight)
                make.width.equalTo(btnW)
                if needChangeline || lastButton == nil {
                    make.left.equalTo(self.snp.left)
                } else {
                    make.left.equalTo(lastButton!.snp.right).offset(marginX)
                }
            }
            if showClose {
                // 添加Close按钮
                addClose(in: button, tag: 2000 + i)
            }
            lastButton = button
        }
        // 如果需要添加addbtn，就添加addbtn
        if showAddBtn {
            var btnW = W375(103)
            // 判断是否需要换行
            if btnW < maxRowWidth - totalRowW {
                // 不需要换行
                needChangeline = false
                totalRowW += btnW + marginX
            } else {
                needChangeline = true
                // 需要换行
                if btnW > maxRowWidth {
                    // 如果标签的宽度比最大的还宽，那就得处理一下了
                    btnW = maxRowWidth
                }
                currentRow += 1 // 行数加1
                totalRowW = btnW + marginX
            }
            self.addSubview(addButton)
            addButton.snp.makeConstraints { (make) in
                make.width.equalTo(W375(83))
                make.height.equalTo(W375(30))
                make.top.equalTo(self.snp.top).offset(currentRow*rowHeight + rowMarginTop)
                if needChangeline || lastButton == nil {
                    make.left.equalTo(self.snp.left)
                } else {
                    make.left.equalTo(lastButton!.snp.right).offset(marginX)
                }
            }
        }
    }
}

extension TagView {
    
    @objc
    func tagTouchAction(_ sender: UIButton) -> Void {
        // 点击标签的事件
        let title = self.tags[sender.tag - 1000]
        self.delegate?.touchTag(tag: sender.tag - 1000, title: title)
    }
    
    @objc
    func closeAction(_ sender:UIButton) -> Void {
        // 点击关闭的事件
        let title = self.tags[sender.tag - 2000]
        self.delegate?.touchTagClose(tag: sender.tag - 2000, title: title)
    }
    
    @objc func addBtnAction(_ sender: UIButton) -> Void {
        // 点击添加事件
        self.delegate?.touchTagAdd(tag: -1) // 执行添加按钮的点击事件
    }
}
