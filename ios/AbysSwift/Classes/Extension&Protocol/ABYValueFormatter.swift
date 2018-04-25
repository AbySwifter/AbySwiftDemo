//
//  ABYValueFormatter.swift
//  AbysSwift
//
//  Created by aby on 2018/3/1.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation
import Charts


/// 完成折线图X轴的报表数据的填写
class ABYXAxisValueFormatter: NSObject, IAxisValueFormatter
{
	private var _values: [String] = [String]()
	private var _valueCount: Int = 0

	@objc public var values: [String]
		{
		get
		{
			return _values
		}
		set
		{
			_values = newValue
			_valueCount = _values.count
		}
	}

	public override init()
	{
		super.init()

	}

	@objc public init(values: [String])
	{
		super.init()

		self.values = values
	}

	@objc public static func with(values: [String]) -> IndexAxisValueFormatter?
	{
		return IndexAxisValueFormatter(values: values)
	}

	open func stringForValue(_ value: Double,
							 axis: AxisBase?) -> String
	{
		let index = Int(value.rounded())
		guard values.indices.contains(index), index == Int(value) else { return "" }
		return _values[index]
	}
}
