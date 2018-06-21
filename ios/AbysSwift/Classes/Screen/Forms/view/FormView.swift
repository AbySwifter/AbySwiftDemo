//
//  Form.swift
//  AbysSwift
//
//  Created by aby on 2018/3/2.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import Charts

class FormView: UIView {
	let gridColor = UIColor.init(hexString: "f5f5f5")
	let cricleColor = UIColor.init(hexString: "92c360")
	var dates: [Double]?
	var xAxisValues: [String]?
	let lineChart: LineChartView = LineChartView()
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.addSubview(lineChart)
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override func layoutSubviews() {
		lineChart.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview().inset(UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10))
            make.edges.equalToSuperview()
            
		}
		setStyleOfLineChart()
	}

    /// 设置报表的数据
    func setData(_ data: [Double], xValues: [String], unit: String = "数量") -> Void {
		var dataEntris = [ChartDataEntry]() // 初始化数据数组
		for index in 0..<data.count {
			let dataEntry = ChartDataEntry.init(x: Double(index), y: data[index])
			dataEntris.append(dataEntry)
		}
        // 设置数据
		let dataSet: LineChartDataSet = LineChartDataSet.init(values: dataEntris, label: unit)
		let lineChartData: LineChartData = LineChartData.init(dataSets: [dataSet])
		lineChart.data = lineChartData
		lineChart.xAxis.valueFormatter = ABYXAxisValueFormatter.init(values: xValues)
		setDataSetStyle(dataSet)
	}

	func setDataSetStyle(_ dataSet: LineChartDataSet) -> Void {
		dataSet.lineWidth = 1.0
		dataSet.circleRadius = 4.0
		dataSet.circleHoleRadius = 3.0
		dataSet.setCircleColor(self.cricleColor)
		dataSet.setColor(self.cricleColor)
		dataSet.drawFilledEnabled = true // 是否填充线以下
		let color1 = self.cricleColor.cgColor
		let color2 = UIColor.init(hexString: "ffffff").cgColor
		let gradientColors = [color2, color1]
		let gradient = CGGradient.init(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)
		dataSet.fill = Fill.init(linearGradient: gradient!, angle: 90)
	}

	// MARK: -private方法
	// 设置lineChar的样式
	private func setStyleOfLineChart() -> Void {
		lineChart.noDataText = "暂无数据"
		lineChart.chartDescription?.enabled = false // 是否显示描述
		lineChart.drawGridBackgroundEnabled = false // 网格背景是否绘制
		lineChart.drawBordersEnabled = false // 是否绘制边框
		lineChart.borderLineWidth = 1.0
		lineChart.borderColor = self.gridColor
		lineChart.backgroundColor = UIColor.white
//		lineChart.dragEnabled = true
//		lineChart.scaleXEnabled = true
		// charts设置，X轴设置
		xAxisSetting()
		// charts设置，Y轴
		YAxisSetting()
		// 下方标识设置
		legendSetting()
	}

	/// X轴样式设置
	private func xAxisSetting() {
		let xAxis = lineChart.xAxis
		xAxis.labelPosition = .bottom // X轴的位置
		xAxis.labelFont = .systemFont(ofSize: 10.0) // x轴的字体设置
		xAxis.drawGridLinesEnabled = true
		xAxis.granularity = 1.0
		xAxis.gridColor = self.gridColor
		xAxis.gridLineWidth = 1.0
        xAxis.drawLabelsEnabled = true
        xAxis.avoidFirstLastClippingEnabled = true // 是否将X轴收回来
	}

	/// Y轴样式设置
	private func YAxisSetting() -> Void {
		// 左侧线条
		let leftAxis = lineChart.leftAxis
		// 网格线设置
		leftAxis.drawGridLinesEnabled = true
		leftAxis.gridLineWidth = 1.0
		leftAxis.gridColor = self.gridColor
		leftAxis.axisMinimum = 0.0
		leftAxis.granularity = 1.0
		// 轴线设置
		leftAxis.drawAxisLineEnabled = false
		// 右侧轴线
		let rightAxis = lineChart.rightAxis
		rightAxis.drawAxisLineEnabled = false // 不画右侧轴线
		rightAxis.enabled = false
	}

	/// 下方的说明
	private func legendSetting() -> Void {
		let legend = lineChart.legend
		legend.horizontalAlignment = .left
		legend.verticalAlignment = .bottom
		legend.orientation = .horizontal
		legend.drawInside = false
		legend.form = .square
		legend.formSize = 9.0
		legend.font = .systemFont(ofSize: 10)
		legend.xEntrySpace = 4.0
        legend.enabled = true
	}
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
