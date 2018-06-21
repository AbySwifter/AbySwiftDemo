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

let kScreenWidth = UIScreen.main.bounds.width
let KScreenHeight = UIScreen.main.bounds.height

let SystemVersion: String = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
/// 计算比例的函数（750）的设计图
func W750(_ number: CGFloat) -> CGFloat {
	let standWidth: CGFloat = 750.0
	return (number / standWidth) * UIScreen.main.bounds.size.width
}

/// 计算比例的函数（375的设计图）
func W375(_ number: CGFloat) -> CGFloat {
    let standWidth: CGFloat = 375.0
    return (number / standWidth) * UIScreen.main.bounds.size.width
}

// 生成随机字符串
func newGUID(length: Int = 30) -> String {
	let characters = "0123456789abcdef"
	var ranStr = ""
	for _ in 0..<length {
		let index = Int(arc4random_uniform(16))
		ranStr.append(characters[characters.index(characters.startIndex, offsetBy: index)])
	}
	return ranStr
}

func ABYPrint<N>(message: N, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line){
	#if DEBUGSWIFT
		let file = (fileName as NSString).lastPathComponent.replacingOccurrences(of: ".Swift", with: "")
	print("\(file):\(lineNumber)行。\n\(methodName)中的打印信息:\n\(message)");
	#endif
}

func ABYPrint<N>(_ message: N, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line){
	#if DEBUGSWIFT
	let file = (fileName as NSString).lastPathComponent.replacingOccurrences(of: ".Swift", with: "")
	print("\(file):\(lineNumber)行。\n\(methodName)中的打印信息:\n\(message)");
	#endif
}
