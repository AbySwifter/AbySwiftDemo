//
//  UIButton+EXtension.swift
//  AbysSwift
//
//  Created by aby on 2018/5/10.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation

/// button的分类，用于初始化点击背景色变化的button
extension UIButton {
    convenience init(bgColor: UIColor?, disabledColor: UIColor?, title: String, titleColor: UIColor?, titleHighlightedColor: UIColor?) {
        self.init(frame: CGRect.zero)
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.setTitleColor(titleHighlightedColor, for: .highlighted)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        self.setBackgroundImage((bgColor ?? kBtnWhite).trans2Image(), for: .normal)
        self.setBackgroundImage((disabledColor ?? kBtnWhite).trans2Image(), for: .disabled)
        //        self.backgroundColor = kBtnWhite
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
    }
}
