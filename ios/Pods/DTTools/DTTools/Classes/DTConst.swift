
import Foundation
import UIKit


/// 屏幕宽的常量
public let DTScreenWidth = UIScreen.main.bounds.width
/// 屏幕高的常量
public let DTScreenHeight = UIScreen.main.bounds.height


/// 自定义的log输出
///
/// - Parameters:
///   - message: 要打印的message
///   - fileName: 文件名
///   - methodName: 方法名
///   - lineNumber: 行数
public func DTLog<N>(_ message: N, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line) {
    #if DEBUG
    let file = (fileName as NSString).lastPathComponent.replacingOccurrences(of: ".Swift", with: "")
    print("\(file):\(lineNumber)行。\n\(methodName)中的打印信息:\n\(message)");
    #endif
}


/// 375设计图的缩放函数
///
/// - Parameter number: 375设计图下的size
/// - Returns: CGFloat实例
public func W375(_ number: CGFloat) -> CGFloat {
    let standWidth: CGFloat = 375.0
    return (number / standWidth) * UIScreen.main.bounds.size.width
}


/// 计算比例函数（750）的设计图
///
/// - Parameter number: 750设计图下的size
/// - Returns: CGFloat的实例
public func W750(_ number: CGFloat) -> CGFloat {
    let standWidth: CGFloat = 750.0
    return (number / standWidth) * UIScreen.main.bounds.size.width
}
