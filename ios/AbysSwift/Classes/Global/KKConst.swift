//
//  KKConst.swift
//  AbysSwift
//
//  Created by aby on 2018/5/9.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation


/* 通知的常量 */

let kNoteImageCellTap = "ImageCellTapName"
let KNoteArticleCellTap = "ArticelCelltap"

/*会话列表的常量*/
let MSG_NOTIFICATION = "msg_event_notification"
let LIST_UPDATE = "ListUpdate"

/*常用的按钮颜色*/
// MARK:- 颜色方法
func normalRGBA (r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor (red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}
func RGBA (r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor (red: r, green: g, blue: b, alpha: a)
}
// MARK:- 常用按钮颜色
let kBtnWhite = RGBA(r: 0.97, g: 0.97, b: 0.97, a: 1.00)
let kBtnDisabledWhite = normalRGBA(r: 100, g: 149, b: 237, a: 1.0) // 这里临时做为一个按钮的常见颜色
let kBtnGreen = RGBA(r: 0.15, g: 0.67, b: 0.16, a: 1.00)
let kBtnDisabledGreen = normalRGBA(r: 100, g: 149, b: 237, a: 1.0)
let kBtnRed = RGBA(r: 0.89, g: 0.27, b: 0.27, a: 1.00)

// 主题色
func ABYGlobalThemeColor() ->  UIColor {
    return UIColor.init(hexString: "0084bf")
}

// 主题背景色
func ABYGlobalBackGroundColor() -> UIColor {
    return UIColor.init(hexString: "f5f5f5")
}

// boder色
func ABYGlobalBorderColor() -> UIColor {
    return UIColor.init(hexString: "e9e9e9")
}
