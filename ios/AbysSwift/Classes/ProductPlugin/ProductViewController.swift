//
//  ProductViewController.swift
//  AbysSwift
//
//  Created by aby on 2018/4/13.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import React

class ProductViewController: ABYBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNotification()
        // 隐藏Header
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        guard getbundleFromDocument() else {
            #if DEBUGSWIFT
                createReactNativeView() // 调试的时候就直接从网络加载
            #else
            // 不存在的话，就先下载
            // 提示用户下载并加载
            #endif
            return
        }
        let _ = getBundleFromResouce()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        removeNotification()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	func createReactNativeView() {
		let jsCodeLocation = URL.init(string: "http://localhost:8081/index.bundle?platform=ios")
		let mockData: NSDictionary = [
            "routeName":"Main"
		]
		let rootView = RCTRootView(bundleURL: jsCodeLocation!, moduleName: "ABYSwiftDemo", initialProperties: mockData as [NSObject: AnyObject], launchOptions: nil)
		self.view = rootView!
	}

    // 在住文件中寻找路径
    func getBundleFromResouce() -> Bool {
        let path = Bundle.main.path(forResource: "main", ofType: "jsbundle")
        ABYPrint("路径为\(path)")
        if FileManager.default.fileExists(atPath: path ?? "") {
            let jsCodeLocation = URL.init(string: path!)
            let mockData: NSDictionary = ["routeName": "Main"]
            let rootView = RCTRootView(bundleURL: jsCodeLocation!, moduleName: "ABYSwiftDemo", initialProperties: mockData as [NSObject: AnyObject], launchOptions: nil)
            self.view = rootView!
            return true
        } else {
            return false
        }
    }
    
    // 在沙盒中寻找路径
	func getbundleFromDocument() -> Bool {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        ABYPrint("路径为\(documents)")
        guard let documentPath: String = documents.first else { return false }
        let filePath = documentPath + "/main.jsbundle"
        if FileManager.default.fileExists(atPath: filePath) {
            let jsCodeLocation = URL.init(string: filePath)
            let mockData: NSDictionary = ["routeName":"Main"]
            let rootView = RCTRootView(bundleURL: jsCodeLocation!, moduleName: "ABYSwiftDemo", initialProperties: mockData as [NSObject: AnyObject], launchOptions: nil)
            self.view = rootView!
            return true
        } else {
            return false
        }
	}
	@objc
	func dismissSelf() -> Void {
		self.navigationController?.popViewController(animated: true)
	}
}

// MARK: - 通知的注册
extension ProductViewController {
    func registerNotification() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(dismissSelf), name: NSNotification.Name.init("ChangeUIDismiss"), object: nil)
    }
    
    func removeNotification() -> Void {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("ChangeUIDismiss"), object: nil)
    }
}
