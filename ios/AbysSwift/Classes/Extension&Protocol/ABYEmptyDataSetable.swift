//
//  ABYEmptyDataSetable.swift
//  AbysSwift
//
//  Created by aby.wang on 2018/4/18.
//  王勇旭 创建于 2018年4月18日
//  以面向协议的编程思想，完成对tabview的空数据的视图进行处理，依赖于DZNEmptyDataSet
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation
import DZNEmptyDataSet

public typealias ABYTapEmptyBlock = ((UIView)->())
public enum ABYEmptyDataSetAttributeKeyType {
	/// 纵向偏移(-50)  CGFloat
	case verticalOffset
	/// 提示语(暂无数据)  String
	case tipStr
	/// 提示语的font(system15)  UIFont
	case tipFont
	/// 提示语颜色(D2D2D2)  UIColor
	case tipColor
	/// 提示图(LXFEmptyDataPic) UIImage
	case tipImage
	/// 允许滚动(true) Bool
	case allowScroll
}

// 给ScrollView添加一个延展
extension UIScrollView {
	private struct AssociatedKeys {
		static var aby_emptyAttributeDictKey = "aby_emptyAttributeDictKey"
		static var aby_emptyTabBlockKey = "aby_emptyTabBlockKey"
	}

	// 存放闭包属性, 遵循copy协议，可以进行深拷贝
	private class BlockContainer: NSObject, NSCopying {
		func copy(with zone: NSZone? = nil) -> Any {
			return self
		}

		var rearrange_aby_emptyTapBlock : ABYTapEmptyBlock?
	}

	// 属性字典, 用运行时的方法去进行赋值，添加存储属性
	var aby_emptyAttributeDict: [ABYEmptyDataSetAttributeKeyType: Any]? {
		get {
			return objc_getAssociatedObject(self, &AssociatedKeys.aby_emptyAttributeDictKey) as? [ABYEmptyDataSetAttributeKeyType: Any]
		}
		set {
			// 类；属性名；值；修饰词
			objc_setAssociatedObject(self, &AssociatedKeys.aby_emptyAttributeDictKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}

	var aby_emptyTapBlock : ABYTapEmptyBlock? {
		get {
			return objc_getAssociatedObject(self, &AssociatedKeys.aby_emptyTabBlockKey) as? ABYTapEmptyBlock
		}
		set {
			objc_setAssociatedObject(self, &AssociatedKeys.aby_emptyTabBlockKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
		}
	}
}

/// 空视图协议
public protocol ABYEmptyDataSetable {

}


// MARK: - 空视图占位协议,用where关键字确定面向的对象类
public extension ABYEmptyDataSetable where Self: NSObject {
	//
	/// 初始化数据，设置代理和样式字典
	///
	/// - Parameters:
	///   - scrollView: 被设置的类
	///   - attributeBlock: 自定义样式的回调
	func aby_EmptyDataSet(_ scrollView: UIScrollView, attributeBlock:(() -> ([ABYEmptyDataSetAttributeKeyType : Any]))? = nil) -> Void {
		scrollView.aby_emptyAttributeDict = attributeBlock != nil ? attributeBlock!() : nil
		scrollView.emptyDataSetSource = self
		scrollView.emptyDataSetDelegate = self
	}

	/// 更新数据回调
	///
	/// - Parameters:
	///   - scrollView: 更新的视图
	///   - attributeBlock: 样式的返回
	func aby_updateEmptyDataSet(_ scrollView: UIScrollView, attributeBlock:(()->([ABYEmptyDataSetAttributeKeyType : Any]))) -> Void {
		let dict = attributeBlock()
		if scrollView.aby_emptyAttributeDict == nil {
			scrollView.aby_emptyAttributeDict = dict
		} else {
			for key in dict.keys {
				scrollView.aby_emptyAttributeDict![key] = dict[key]
			}
		}
		scrollView.reloadEmptyDataSet()
	}


	/// 点击回调
	///
	/// - Parameters:
	///   - scrollView: 点击的视图
	///   - block: 回调的内容
	func aby_tapEmptyView(_ scrollView: UIScrollView, block: @escaping ABYTapEmptyBlock) -> Void {
		scrollView.aby_emptyTapBlock = block
	}
}

extension NSObject: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
	// 返回当前占位图的方法
	public func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
		guard let tipImg = scrollView.aby_emptyAttributeDict?[.tipImage] as? UIImage else {
			return #imageLiteral(resourceName: "empty")
		}
		return tipImg
	}
	// 返回当前视图的标题色
	public func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
		let defaultColor = UIColor.init(red: 210/255, green: 210/255, blue: 210/255, alpha: 1.0) // 0xD2D2D2
		let tipText = (scrollView.aby_emptyAttributeDict?[.tipStr] as? String) ?? "暂无数据"
		let tipFont = (scrollView.aby_emptyAttributeDict?[.tipFont] as? UIFont) ?? UIFont.systemFont(ofSize: 15.0)
		let tipColor = (scrollView.aby_emptyAttributeDict?[.tipColor] as? UIColor) ?? defaultColor
		let attrStr = NSAttributedString(string: tipText, attributes: [
			NSAttributedStringKey.font: tipFont,
			NSAttributedStringKey.foregroundColor: tipColor
			])
		return attrStr
	}

	// 返回视图的向下偏移量
	public func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
		guard let offset = scrollView.aby_emptyAttributeDict?[.verticalOffset] as? NSNumber else {
			return -50
		}
		return CGFloat.init(truncating: offset)
	}

	// 是否允许滑动
	public func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
		return (scrollView.aby_emptyAttributeDict?[.allowScroll] as? Bool) ?? true
	}

	// 执行点击手势
	public func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
		if scrollView.aby_emptyTapBlock != nil {
			scrollView.aby_emptyTapBlock!(view)
		}
	}

	// 执行轻触手势(按钮)
	public func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
		if scrollView.aby_emptyTapBlock != nil {
			scrollView.aby_emptyTapBlock!(button)
		}
	}

}
