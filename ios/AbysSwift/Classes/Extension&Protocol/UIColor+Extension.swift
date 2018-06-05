//
//  UIColor+Extension.swift
//  AbysSwift
//
//  Created by aby on 2018/2/2.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit


extension UIColor {
	convenience init(hexString: String, alpha: CGFloat? = 1.0) {
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

	convenience init(normalr: CGFloat, g: CGFloat, b:CGFloat, a: CGFloat) {
		self.init(red: normalr/255.0, green: g/255.0, blue: b/255.0, alpha: a)
	}
    
    // 数字类型的初始化方法
    class func hexInt(_ hexValue: Int) -> UIColor {
        return UIColor(red: ((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0,
                       
                       green: ((CGFloat)((hexValue & 0xFF00) >> 8)) / 255.0,
                       
                       blue: ((CGFloat)(hexValue & 0xFF)) / 255.0,
                       
                       alpha: 1.0)
    }
    
    // 颜色转化为图片
    func trans2Image() -> UIImage {
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
