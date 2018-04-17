//
//  ConvDetailViewController.swift
//  AbysSwift
//
//  Created by aby on 2018/3/16.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit

class ConvDetailViewController: ABYBaseViewController, ChatFootMenuDelegate, ChatFootBarDelegate {

	let chatFoot: ChatFooterBar = ChatFooterBar.init(frame: CGRect.zero)

    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = UIColor.init(hexString: "ececec")
        // Do any additional setup after loading the view.
		addChildView()
		layoutChildView()
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setWhiteNavigationBar()
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		setThemeNavigationBar()
	}

	func addChildView() -> Void {
		chatFoot.menuDelegate = self
		chatFoot.delegate = self
		view.addSubview(chatFoot)
	}

	func layoutChildView() -> Void {
		chatFoot.snp.makeConstraints { (make) in
//			make.bottom.equalToSuperview()
			make.top.equalTo(self.view.snp.bottom).offset(-55)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.greaterThanOrEqualTo(55)
//			make.height.equalTo(55)
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// MARK: - 菜单事件
	func menuAction(type: ChatFootMenuTag) {
		// 点击了菜单事件
		ABYPrint(message: type)
		switch type {
		case .product:
			let productVC = ProductViewController()
			self.navigationController?.pushViewController(productVC, animated: true)
		default:
			return
		}
	}

	func footHeightChange(height: CGFloat, animate completion: @escaping CompontionBlock) {
		// 动画事件也会触发ViewController的viewWillLayoutSubViews
		UIView.animate(withDuration: 0.3, animations: {
			self.chatFoot.snp.updateConstraints({ (make) in
				make.top.equalTo(self.view.snp.bottom).offset(-height)
			})
			self.view.layoutIfNeeded()
		}) { (result) in
			completion()
		}
	}


}
