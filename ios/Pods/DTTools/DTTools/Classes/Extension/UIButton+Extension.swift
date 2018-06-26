//
//  UIButton+EXtension.swift
//  AbysSwift
//
//  Created by aby on 2018/5/10.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation

// MARK:- 常用按钮颜色
let kBtnWhite = RGBA(r: 0.97, g: 0.97, b: 0.97, a: 1.00)
let kBtnDisabledWhite = normalRGBA(r: 100, g: 149, b: 237, a: 1.0) // 这里临时做为一个按钮的常见颜色
let kBtnGreen = RGBA(r: 0.15, g: 0.67, b: 0.16, a: 1.00)
let kBtnDisabledGreen = normalRGBA(r: 100, g: 149, b: 237, a: 1.0)
let kBtnRed = RGBA(r: 0.89, g: 0.27, b: 0.27, a: 1.00)

/// button的分类，用于初始化点击背景色变化的button
public extension UIButton {
    
    /// 初始化Button, 颜色会填充到背景图片， 默认有5.0的圆角
    ///
    /// - Parameters:
    ///   - bgColor: 背景色
    ///   - disabledColor: 禁止点击下的颜色
    ///   - title: 按钮标题
    ///   - titleColor: 标题正常颜色
    ///   - titleHighlightedColor: 标题高亮颜色
    convenience init(bgColor: UIColor?, disabledColor: UIColor?, title: String, titleColor: UIColor?, titleHighlightedColor: UIColor?) {
        self.init(frame: CGRect.zero)
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.setTitleColor(titleHighlightedColor, for: .highlighted)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        self.setBackgroundImage((bgColor ?? kBtnWhite).trans2Image(), for: .normal)
        self.setBackgroundImage((disabledColor ?? kBtnWhite).trans2Image(), for: .disabled)
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
    }
}
