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
		guard getbundleFromDocument() else {
			createReactNativeView()
			return
		}
        // Do any additional setup after loading the view.
		NotificationCenter.default.addObserver(self, selector: #selector(dismissSelf), name: NSNotification.Name.init("ChangeUIDismiss"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	func createReactNativeView() {
		let jsCodeLocation = URL.init(string: "http://localhost:8081/index.bundle?platform=ios")
		let mockData: NSDictionary = ["routeName":"Main"
		]
		let rootView = RCTRootView(bundleURL: jsCodeLocation!, moduleName: "ABYSwiftDemo", initialProperties: mockData as [NSObject: AnyObject], launchOptions: nil)
		self.view = rootView!
	}

	func getbundleFromDocument() -> Bool {
		//		FileManager.default.
		let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		ABYPrint("路径为\(documents)")
		guard let documentPath: String = documents.first else { return false }
		let filePath = documentPath + "/main.jsbundle"
		if FileManager.default.fileExists(atPath: filePath) {
			let jsCodeLocation = URL.init(string: filePath)
			let mockData: NSDictionary = ["routeName":"Main"]
			let rootView = RCTRootView(bundleURL: jsCodeLocation!, moduleName: "GTravel_HyBird", initialProperties: mockData as [NSObject: AnyObject], launchOptions: nil)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
