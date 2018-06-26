//
//  UIColor+Extension.swift
//  AbysSwift
//
//  Created by aby on 2018/2/2.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit

// MARK:- 颜色方法
func normalRGBA (r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor (red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}
func RGBA (r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor (red: r, green: g, blue: b, alpha: a)
}

extension UIColor {
    
    /// 根据十六进制字符串初始化Color的方法
    ///
    /// - Parameters:
    ///   - hexString: 十六进制的亚瑟值
    ///   - alpha: 透明度（可选）
	public convenience init(hexString: String, alpha: CGFloat? = 1.0) {
		let scanner:Scanner = Scanner(string:hexString)
		var valueRGB:UInt32 = 0
		if scanner.scanHexInt32(&valueRGB) == false {
			self.init(red: 0,green: 0,blue: 0,alpha: 0)
		}else{
			self.init(
				red:CGFloat((valueRGB & 0xFF0000)>>16)/255.0,
				green:CGFloat((valueRGB & 0x00FF00)>>8)/255.0,
				blue:CGFloat(valueRGB & 0x0000FF)/255.0,
				alpha:CGFloat(alpha!)
			)
		}
	}
    
    
    /// 根据0~255来初始化颜色
    ///
    /// - Parameters:
    ///   - r: 红色
    ///   - g: 绿色
    ///   - b: 蓝色
    ///   - a: 透明度
	public convenience init(r: CGFloat, g: CGFloat, b:CGFloat, a: CGFloat) {
		self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
	}
    
    
    /// 根据16精致的数字
    ///
    /// - Parameter hexValue: 16进制的颜色值
    /// - Returns: 返回UIColor实例
    public class func hexInt(_ hexValue: Int) -> UIColor {
        return UIColor(red: ((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0,
                       
                       green: ((CGFloat)((hexValue & 0xFF00) >> 8)) / 255.0,
                       
                       blue: ((CGFloat)(hexValue & 0xFF)) / 255.0,
                       
                       alpha: 1.0)
    }
    
    
    /// 将色值转化为1*1的Image图
    ///
    /// - Returns: 返回UIImage实例
    public func trans2Image() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.cgColor)
        context?.fill(rect)
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return theImage ?? UIImage()
    }
}
