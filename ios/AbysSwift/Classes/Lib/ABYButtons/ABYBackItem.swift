//
//  ABYBackItem.swift
//  ButtonTest
//
//  Created by aby on 2018/5/25.
//  Copyright © 2018年 aby. All rights reserved.
//

import UIKit


/// 返回按钮的封装（用于聊天页面的返回）
class ABYBackItem: UIButton {

    /// 返回按钮的初始化方法
    ///
    /// - Parameters:
    ///   - title: 按钮标题
    ///   - titleColor: 按钮标题y颜色
    ///   - icon: 按钮的Icon
    init(title: String, titleColor: UIColor?, icon: UIImage) {
//        super.init(frame: CGRect.zero)
        super.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 35))
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
//        self.contentMode = .left
        self.contentHorizontalAlignment = .left
        self.setImage(icon, for: .normal)
        self.imageView?.contentMode = .scaleAspectFit
        self.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: -5)
        self.titleLabel?.lineBreakMode = .byTruncatingTail
//        self.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
    }

    /// 修改按钮标题
    ///
    /// - Parameter title: 需要修改的标题
    func set(title: String) -> Void {
        self.setTitle(title, for: .normal)
        self.titleLabel?.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) has not impleted")
    }
}
