//
//  FormsViewController.swift
//  AbysSwift
//
//  Created by aby on 2018/2/2.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import Charts
import SnapKit

class FormsViewController: UIViewController {
	let scrollView: UIScrollView = UIScrollView.init() // 整体的scrollView
	let segmentControl: UISegmentedControl = UISegmentedControl.init() // 数据类型选择框
	let lineChart: FormView = FormView.init() // 折线图
	// 满意度环形图
	let progressUp: ABYProgressView = ABYProgressView.init()
	// 不满意度环形图
	let progressDown: ABYProgressView = ABYProgressView.init()
	var dataViews: Array<UIView> = [];
	let model: FormVCModel = FormVCModel.init()

    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
		setScrollView()
		scrollView.backgroundColor = ABYGlobalBackGroundColor()
		view.backgroundColor = ABYGlobalBackGroundColor()
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.model.getData()
	}
	// 内存
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	// 整体布局约束
	func setScrollView() -> Void {
		view.addSubview(scrollView)
		scrollView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview().inset(UIEdgeInsetsMake(0, 15, 0, 15))
		}
		let containerView: UIView = UIView.init()
		scrollView.addSubview(containerView)
		containerView.snp.makeConstraints { (make) in
			make.top.left.bottom.right.equalTo(scrollView)
			make.width.equalToSuperview()
		}
		scrollView.showsVerticalScrollIndicator = false
		var lastView: UIView?
		// 添加选择控制器
		addSegmentController(containerView)
		// 图标插件
		addChartsView(containerView)
		// 头部title1
		let partName = addPartName(containerView, topView: lineChart, title: "满意度占比")
		let progressView = addProgressView(containerView, topView: partName)
		let partName2 = addPartName(containerView, topView: progressView, title: "累计数据")
		// 为了约束ScrollView的滚动视图
		lastView = setOtherDataView(containerView, topView: partName2)
		containerView.snp.makeConstraints { (make) in
			if let last = lastView {
				make.bottom.equalTo(last.snp.bottom).offset(20)
			}
		}
	}

	/// 添加头部选择控件
	///
	/// - Parameter container: 父视图
	func addSegmentController(_ container: UIView) -> Void {
		container.addSubview(segmentControl)
		segmentControl.snp.makeConstraints { (make) in
			make.width.equalTo(W750(630))
			make.height.equalTo(W750(53))
			make.centerX.equalToSuperview()
			make.top.equalTo(W750(50))
		}
		setSegmentedControl()
	}
	// 头部SegmentedControl设置
	func setSegmentedControl() -> Void {
		segmentControl.isMomentary = false;
		segmentControl.insertSegment(withTitle: "在线时长", at: 0, animated: false)
		segmentControl.insertSegment(withTitle: "会话量", at: 1, animated: false)
		segmentControl.insertSegment(withTitle: "接待客户数", at: 2, animated: false)
		segmentControl.selectedSegmentIndex = 0
		segmentControl.tintColor = ABYGlobalThemeColor()
		segmentControl.layer.cornerRadius = 3.0
		segmentControl.backgroundColor = UIColor.white
	}
	/// 添加折线图插件
	///
	/// - Parameter containerView: 父视图
	func addChartsView(_ containerView: UIView) -> Void {
		containerView.addSubview(lineChart)
		lineChart.snp.makeConstraints { (make) in
			make.top.equalTo(segmentControl.snp.bottom).offset(W750(50))
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.height.equalTo(lineChart.snp.width).multipliedBy(0.75)
		}
		setCharts()
	}

	func addProgressView(_ containerView: UIView, topView: UIView) -> UIView {
		let progressView: UIView = UIView.init()
		containerView.addSubview(progressView)
		progressView.snp.makeConstraints { (make) in
			make.left.right.equalToSuperview()
			make.top.equalTo(topView.snp.bottom)
			make.height.equalTo(W750(370))
		}
		progressView.backgroundColor = UIColor.white
		setProgressView(progressView, height: W750(370))
		return progressView
	}
	// Charts数据
	func setCharts() -> Void {
		let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
		let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0]
		lineChart.setData(unitsSold, xValues: months)
	}
	// 生成PartName
	func addPartName(_ containerView:UIView, topView: UIView, title: String) -> UIView {
		let partName: PartNameView = PartNameView.init()
		containerView.addSubview(partName)
		partName.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
			make.top.equalTo(topView.snp.bottom)
		}
		partName.titleLabel.text = title
		return partName
	}

	// 满意度占比环形图数据
	func setProgressView(_ view: UIView, height: CGFloat) -> Void {
		view.addSubview(progressUp)
		view.addSubview(progressDown)
		let S_width = self.view.frame.width
		let space = (S_width - 30 - (1.2 * height)) / 3
		progressUp.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.height.equalTo(progressUp.snp.width)
			make.left.equalToSuperview().offset(space)
			make.width.equalTo(height * 0.6)
		}
		progressDown.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.height.equalTo(progressDown.snp.width)
			make.right.equalToSuperview().offset(-space)
			make.width.equalTo(height * 0.6)
		}
		// 在此绑定model的属性，以便于修改视图属性
		model.progress = (progressUp, progressDown)
	}

	// 累计数据区域
	func setOtherDataView(_ container: UIView, topView: UIView) -> UIView {
		let otherView = UIView.init()
		let everyWidth = (self.view.frame.width - 35) / 2
		let everyHeight = 75
		container.addSubview(otherView)
		otherView.snp.makeConstraints { (make) in
			make.width.equalToSuperview()
			make.top.equalTo(topView.snp.bottom)
			make.centerX.equalToSuperview()
			make.height.equalTo(everyHeight*3 + 10)
		}
		for (count, value) in model.dataArray.enumerated() {
			let tempView = OtherDataView.init()
			otherView.addSubview(tempView)
			if count%2 == 0 {
				tempView.snp.makeConstraints { (make) in
					make.top.equalToSuperview().offset(count/2 * (everyHeight + 5))
					make.left.equalToSuperview()
					make.height.equalTo(everyHeight)
					make.width.equalTo(everyWidth)
				}
			} else {
				tempView.snp.makeConstraints { (make) in
					make.top.equalToSuperview().offset(count/2 * (everyHeight + 5))
					make.right.equalToSuperview()
					make.height.equalTo(everyHeight)
					make.width.equalTo(everyWidth)
				}
			}
			tempView.titleLabel.text = value.title
			tempView.contentLabel.text = value.value
			var tempValue = value
			tempValue.view = tempView
			model.dataArray[count] = tempValue
		}
//		ABYPrint(message: model.dataArray)
		return otherView
	}
}
