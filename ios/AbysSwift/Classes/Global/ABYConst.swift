//
//  ABYConst.swift
//  AbysSwift
//
//  Created by aby on 2018/2/2.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import Foundation
import SnapKit
import MJRefresh

/// 屏幕宽度
let kScreenWidth = UIScreen.main.bounds.width
/// 屏幕高度
let KScreenHeight = UIScreen.main.bounds.height
/// 系统版本
let SystemVersion: String = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
/// 750设计图转换函数
///
/// - Parameter number: 设计图尺寸
/// - Returns: 转换后的尺寸
func W750(_ number: CGFloat) -> CGFloat {
	let standWidth: CGFloat = 750.0
	return (number / standWidth) * UIScreen.main.bounds.size.width
}
/// 设计图尺寸转换函数
///
/// - Parameter number: 设计图尺寸
/// - Returns: 转换后的尺寸
func W375(_ number: CGFloat) -> CGFloat {
    let standWidth: CGFloat = 375.0
    return (number / standWidth) * UIScreen.main.bounds.size.width
}
/// 生成随机字符串
///
/// - Parameter length: 字符串长度
/// - Returns: 返回结果
func newGUID(length: Int = 30) -> String {
	let characters = "0123456789abcdef"
	var ranStr = ""
	for _ in 0..<length {
		let index = Int(arc4random_uniform(16))
		ranStr.append(characters[characters.index(characters.startIndex, offsetBy: index)])
	}
	return ranStr
}
/// 日志函数
///
/// - Parameters:
///   - message: 要打印的消息
///   - fileName: 文件名（有默认值）
///   - methodName: 方法名（有默认值）
///   - lineNumber: 行数（有默认值）
func Log<N>(message: N, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line){
    #if DEBUGSWIFT
        let file = (fileName as NSString).lastPathComponent.replacingOccurrences(of: ".Swift", with: "")
    print("\(file):\(lineNumber)行。\n\(methodName)中的打印信息:\n\(message)");
    #endif
}
/// 日志函数
///
/// - Parameters:
///   - message: 要打印的消息
///   - fileName: 文件名
///   - methodName: 方法名
///   - lineNumber: 行数
func Log<N>(_ message: N, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line){
    #if DEBUGSWIFT
    let file = (fileName as NSString).lastPathComponent.replacingOccurrences(of: ".Swift", with: "")
    print("\(file):\(lineNumber)行。\n\(methodName)中的打印信息:\n\(message)");
    #endif
}
