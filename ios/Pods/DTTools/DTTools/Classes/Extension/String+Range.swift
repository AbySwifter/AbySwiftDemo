//
//  String+Range.swift
//  AbysSwift
//
//  Created by aby on 2018/4/3.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation

public extension String {
    
    /// string的Range转为NSRange
    ///
    /// - Parameter range: 转化的range
    /// - Returns: NSrange的实例
	func nsRange(from range: Range<String.Index>) -> NSRange {
		let from = range.lowerBound.samePosition(in: utf16) ?? utf16.startIndex
		let to = range.upperBound.samePosition(in: utf16) ?? utf16.endIndex
		return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),
					   length: utf16.distance(from: from, to: to))
	}

	
    /// string的Range转化为NSRange
    ///
    /// - Parameter nsRange: 要转化的NSRange
    /// - Returns: Range的实例
	func range(from nsRange: NSRange) -> Range<String.Index>? {
		guard
			let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location,
									 limitedBy: utf16.endIndex),
			let to16 = utf16.index(from16, offsetBy: nsRange.length,
								   limitedBy: utf16.endIndex),
			let from = String.Index(from16, within: self),
			let to = String.Index(to16, within: self)
			else { return nil }
		return from ..< to
	}
}
