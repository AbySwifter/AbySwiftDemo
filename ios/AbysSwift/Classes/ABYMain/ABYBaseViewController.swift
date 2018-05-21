//
//  ABYBaseViewController.swift
//  AbysSwift
//	在这个基础的类里设置Toast的样式，全局的网络监听。
//  Created by aby on 2018/2/12.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import Alamofire
import JGProgressHUD

class ABYBaseViewController: UIViewController {
	// 定制loading
	lazy var loading: JGProgressHUD = {
		let loading = JGProgressHUD.init(style: .extraLight)
		return loading
	}()
    lazy var networkManager: ABYNetworkManager = {
        return ABYNetworkManager.shareInstance
    }()
	let manager = NetworkReachabilityManager.init() // 网路检测
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
		manager?.listener = { (status) in
			switch status {
			case .reachable(.ethernetOrWiFi):
				print("wifi")
			case .notReachable:
				print("notReachable")
			case .unknown:
				print("未知网络")
			default:
				print("这是啥?")
			}
		}
		manager?.startListening()
    }
	deinit {
		manager?.stopListening()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
	}

	/// 设置当前VC的导航栏透明
	func setNavigationBarTranslucent() -> Void {
        guard let navBar = self.navigationController?.navigationBar else {
            return
        }
		navBar.isTranslucent = true
		let color = UIColor.clear
		let rect = CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 64)
		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()
		context?.setFillColor(color.cgColor)
		context?.fill(rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		navBar.setBackgroundImage(image, for: .any, barMetrics: .default)
		navBar.clipsToBounds = true
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18.0)]
//        self.extendedLayoutIncludesOpaqueBars = true
	}

    /// 设置白色导航栏
	func setWhiteNavigationBar() -> Void {
		guard let navBar = self.navigationController?.navigationBar else {
			return
		}
        navBar.clipsToBounds = false
        let color = UIColor.white
        let rect = CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 64)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        navBar.setBackgroundImage(image, for: .any, barMetrics: .default)
		navBar.isTranslucent = false
		navBar.tintColor = UIColor.black
		navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18.0)]
	}
    /// 设置主题色导航栏
	func setThemeNavigationBar() -> Void {
		guard let navBar = self.navigationController?.navigationBar else {
			return
		}
        navBar.setBackgroundImage(nil, for: .any, barMetrics: .default)
        navBar.clipsToBounds = false
		navBar.isTranslucent = false
		navBar.barTintColor = ABYGlobalThemeColor()
		navBar.tintColor = UIColor.white
		navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18.0)]
	}
	
	func showLoading() -> Void {
		self.loading.show(in: self.view, animated: true)
	}
	func hideLoading() -> Void {
		self.loading.dismiss(animated: true)
	}

}
