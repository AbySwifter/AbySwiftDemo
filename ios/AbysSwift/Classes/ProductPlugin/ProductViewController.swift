//
//  ProductViewController.swift
//  AbysSwift
//
//  Created by aby on 2018/4/13.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import React
import JGProgressHUD

let zipUrl = "http://0.0.0.0:8888/api/file/jsbundle.zip"

class ProductViewController: ABYBaseViewController {

    lazy var package: ABYPackage = {
        let p = ABYPackage.init()
        p.delegate = self
        p.remoteURL = "http://0.0.0.0:8888/api/file/jsbundle.zip" // 设置更新路径
        return p
    }()
    
    lazy var hud: JGProgressHUD = {
        let hud: JGProgressHUD = JGProgressHUD.init(style: JGProgressHUDStyle.dark)
        return hud
    }()
    
    // 返回按钮
    lazy var close: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        btn.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        registerNotification()
        self.view.addSubview(close)
        close.snp.makeConstraints { (make) in
            make.height.width.equalTo(20)
            make.top.left.equalToSuperview().offset(30)
        }
        self.view.backgroundColor = UIColor.init(hexString: "f5f5f5")
        package.isNeedUpdate { (result) -> (Void) in
            if result {
                self.package.downLoadBundle()
            } else {
                self.createReactNativeView(jsCodeLocation: self.package.bundleURL()!)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        removeNotification()
    }
    
    func createReactNativeView(jsCodeLocation: URL) {
        // http://localhost:8081/index.bundle?platform=ios
		let mockData: NSDictionary = [
            "routeName":"Main"
		]
		let rootView = RCTRootView(bundleURL: jsCodeLocation, moduleName: "ABYSwiftDemo", initialProperties: mockData as [NSObject: AnyObject], launchOptions: nil)
        rootView?.frame = self.view.bounds
        self.view.addSubview(rootView!)
	}

	@objc
	func dismissSelf() -> Void {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true) {
                // 处理返回键
            }
        }
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

extension ProductViewController: ABYPackageDelegate {
    func updateStatusChange(_ status: PackageLoadingStatus) {
        // 更新的状态改变了
        switch status {
        case .startDownload:
            self.hud.indicatorView = JGProgressHUDRingIndicatorView.init()
            self.hud.textLabel.text = "更新中..."
            self.hud.show(in: self.view)
        case .downloading(progress:let progress):
            self.hud.detailTextLabel.text = String.init(format: "%.2f%%", progress.fractionCompleted*100)
            self.hud.setProgress(Float(progress.fractionCompleted), animated: true)
        case .downloadSuccess:
            self.hud.textLabel.text = "下载完成"
            self.hud.detailTextLabel.text = ""
            self.hud.indicatorView = JGProgressHUDSuccessIndicatorView.init()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                self.hud.dismiss()
            })
        case .downloadFailed(error: _):
            self.hud.textLabel.text = "下载失败，请重试"
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
            self.hud.detailTextLabel.text = ""
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                self.hud.dismiss()
            })
        case .zipArchivingResult(path:let path, successed: let success, error: _):
            ABYPrint("文件路径为\(path)")
            if success {
                createReactNativeView(jsCodeLocation: package.bundleURL()!)
            }
        default:
            break
        }
    }
}
