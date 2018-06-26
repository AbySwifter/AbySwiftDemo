//
//  UIView+Extension.swift
//  AbysSwift
//
//  Created by aby on 2018/4/18.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation
import UIKit

// UIView的一些快捷方法
extension UIView {
    
    /// x坐标的读写方法
	public var x: CGFloat{
		get{
			return self.frame.origin.x
		}
		set{
			var r = self.frame
			r.origin.x = newValue
			self.frame = r
		}
	}
    
    /// y坐标的读写方法
	public var y: CGFloat{
		get{
			return self.frame.origin.y
		}
		set{
			var r = self.frame
			r.origin.y = newValue
			self.frame = r
		}
	}
	/// 右边界X坐标的读写方法
	public var rightX: CGFloat{
		get{
			return self.x + self.width
		}
		set{
			var r = self.frame
			r.origin.x = newValue - frame.size.width
			self.frame = r
		}
	}
	/// 底部边界Y坐标的读写方法
	public var bottomY: CGFloat{
		get{
			return self.y + self.height
		}
		set{
			var r = self.frame
			r.origin.y = newValue - frame.size.height
			self.frame = r
		}
	}

	public var centerX : CGFloat{
		get{
			return self.center.x
		}
		set{
			self.center = CGPoint(x: newValue, y: self.center.y)
		}
	}

	public var centerY : CGFloat{
		get{
			return self.center.y
		}
		set{
			self.center = CGPoint(x: self.center.x, y: newValue)
		}
	}

	public var width: CGFloat{
		get{
			return self.frame.size.width
		}
		set{
			var r = self.frame
			r.size.width = newValue
			self.frame = r
		}
	}
	public var height: CGFloat{
		get{
			return self.frame.size.height
		}
		set{
			var r = self.frame
			r.size.height = newValue
			self.frame = r
		}
	}


	public var origin: CGPoint{
		get{
			return self.frame.origin
		}
		set{
			self.x = newValue.x
			self.y = newValue.y
		}
	}

	public var size: CGSize{
		get{
			return self.frame.size
		}
		set{
			self.width = newValue.width
			self.height = newValue.height
		}
	}

    /**
     依照图片轮廓对控制进行裁剪
     
     - parameter stretchImage:  模子图片
     - parameter stretchInsets: 模子图片的拉伸区域
     */
    public func clipShape(stretchImage: UIImage, stretchInsets: UIEdgeInsets) {
        // 绘制 imageView 的 bubble layer
        let bubbleMaskImage = stretchImage.resizableImage(withCapInsets: stretchInsets, resizingMode: .stretch)
        
        // 设置图片的mask layer
        let layer = CALayer()
        layer.contents = bubbleMaskImage.cgImage
        layer.contentsCenter = self.CGRectCenterRectForResizableImage(bubbleMaskImage)
        layer.frame = self.bounds
        layer.contentsScale = UIScreen.main.scale
        layer.opacity = 1
        self.layer.mask = layer
        self.layer.masksToBounds = true
    }
    
    public func CGRectCenterRectForResizableImage(_ image: UIImage) -> CGRect {
        return CGRect(
            x: image.capInsets.left / image.size.width,
            y: image.capInsets.top / image.size.height,
            width: (image.size.width - image.capInsets.right - image.capInsets.left) / image.size.width,
            height: (image.size.height - image.capInsets.bottom - image.capInsets.top) / image.size.height
        )
    }
}
