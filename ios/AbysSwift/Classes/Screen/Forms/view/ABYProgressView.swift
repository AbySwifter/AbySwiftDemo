//
//  ABYProgressView.swift
//  AbysSwift
//
//  Created by aby on 2018/3/7.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit

class ABYProgressView: UIView {
	var progress: CGFloat = 0// 环形进度
	let label: UILabel = UILabel.init() // 中心文本显示
	var lineWidth: CGFloat = 10.0 // 环形的宽
	var circleColor: UIColor = ABYGlobalBorderColor() // 换的颜色
	var progressValue: CGFloat {
		get {
			return progress
		}
		set {
			progress = newValue
			self.label.text = String.init(format: "%.f%%", progress * 100)
			self.foreLayer.strokeEnd = progress
		}
	}
	private var foreLayer: CAShapeLayer = CAShapeLayer.init() // 进度条的Layer层

	override init(frame: CGRect) {
		super.init(frame: frame)

	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		drawCustomLayer(bounds.size)
	}

	func drawCustomLayer(_ size: CGSize) -> Void {
		let custombounds = CGRect.init(origin: CGPoint.zero, size: size)
		//背景灰色
		let shapeLayer: CAShapeLayer = CAShapeLayer.init()
		shapeLayer.frame = custombounds
		shapeLayer.lineWidth = lineWidth
		shapeLayer.fillColor = UIColor.clear.cgColor
		shapeLayer.strokeColor = circleColor.cgColor
		let center: CGPoint = CGPoint.init(x: size.width/2, y: size.height/2)
		// 画出曲线（贝塞尔曲线）
		let bezierPath: UIBezierPath = UIBezierPath.init(arcCenter: center, radius: (size.height - self.lineWidth) / 2, startAngle: CGFloat(-0.5*Double.pi), endAngle: CGFloat(1.5*Double.pi), clockwise: true)
		shapeLayer.path = bezierPath.cgPath
		// 给自己添加蒙版
		self.layer.addSublayer(shapeLayer)

		// 渐变色 加蒙版 显示蒙版区域
		let gradientLayer: CAGradientLayer = CAGradientLayer.init()
		gradientLayer.frame = custombounds
		gradientLayer.colors = [UIColor.init(hexString: "5F98FC").cgColor, UIColor.init(hexString: "47BF00").cgColor]
		gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
		gradientLayer.endPoint = CGPoint.init(x: 0, y: 1)
		self.layer.addSublayer(gradientLayer)

		// 裁剪
		self.foreLayer.frame = custombounds
		self.foreLayer.fillColor = UIColor.clear.cgColor
		self.foreLayer.lineWidth = lineWidth
		self.foreLayer.strokeColor = UIColor.red.cgColor
		self.foreLayer.strokeEnd = self.progress
		/* The cap style used when stroking the path. Options are `butt', `round'
		* and `square'. Defaults to `butt'. */
        self.foreLayer.lineCap = CAShapeLayerLineCap.round // 设置画笔
		self.foreLayer.path = bezierPath.cgPath
		// 修改渐变layer层的遮罩
		gradientLayer.mask = self.foreLayer

		self.label.text = String.init(format: "%.f%%", progress * 100)
		self.addSubview(label)
		label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
		}
		label.font = UIFont.systemFont(ofSize: 16.0)
		label.textAlignment = NSTextAlignment.center
	}
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
