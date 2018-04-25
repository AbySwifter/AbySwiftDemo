//
//  UIViewController+showHud.swift
//  AbysSwift
//
//  Created by aby on 2018/2/12.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import JGProgressHUD



extension UIViewController {
	func showToast(_ title: String ) -> Void {
		let hudFail: JGProgressHUD = JGProgressHUD.init(style: .dark)
		hudFail.indicatorView = nil
		hudFail.position = .bottomCenter
		hudFail.textLabel.text = title
		hudFail.show(in: self.view)
		hudFail.dismiss(afterDelay: 2.0)
	}

	func showAlert(title: String, content: String, sureAction: @escaping () -> (Void)) -> Void {
		let alertController: UIAlertController = UIAlertController(title: title, message: content, preferredStyle: .alert)
		let cancelAction: UIAlertAction = UIAlertAction(title: "取消", style: .cancel) { (action) in

		}
		let sureAction: UIAlertAction = UIAlertAction(title: "确定", style: .default) { (action) in
			sureAction()
		}
		alertController.addAction(cancelAction)
		alertController.addAction(sureAction)
		self.present(alertController, animated: true, completion: nil)
	}
}

enum BarBtnItemDirection: Int {
	case left
	case right
}

extension UIViewController {
	func createRightBtnItem(icon: UIImage, method: Selector) -> Void {
		// 设置右侧导航栏按钮
		let menuBtn = UIBarButtonItem.init(image: icon, style: .plain, target: self, action: method)
//		self.addFixedSpace(with: menuBtn, direction: .right)
		navigationItem.rightBarButtonItem = menuBtn
	}
	// 此方法在iOS 11中失效
	fileprivate func addFixedSpace(with barItem: UIBarButtonItem, direction: BarBtnItemDirection) {
		let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
		negativeSpacer.width = -20
		switch direction {
		case .left:
			navigationItem.leftBarButtonItems = [negativeSpacer, barItem]
		default:
			navigationItem.rightBarButtonItems = [negativeSpacer, barItem]
		}

	}
}
