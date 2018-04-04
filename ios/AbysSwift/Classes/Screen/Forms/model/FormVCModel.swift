//
//  FormVCModel.swift
//  AbysSwift
//
//  Created by aby on 2018/3/8.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias DataTuple = (title: String, value: String, view: OtherDataView?)

class FormVCModel: NSObject {
	let network: ABYNetworkManager = {
		return ABYNetworkManager.shareInstance
	}()
	let segmentTitles: Array<String> = ["在线时长", "会话量", "接待客户数"];
	var timeLine: Array<String>?
	var active: Array<Int>?
	var session: Array<Int>?
	var customer: Array<Int>?
	var dataArray: Array<DataTuple> = [
		("累计在线时长", "00:00:00", nil),
		("日均在线时长", "00:00:00", nil),
		("累计会话量", "0", nil),
		("日均会话量", "0", nil),
		("累计接待客户数", "0", nil),
		("日均接待客户数", "0", nil),
	];
	var progress: (ABYProgressView?, ABYProgressView?) = (nil, nil)

	/// 获取报表数据
	func getData() -> Void {
		guard let user = Account.share.user else { return }
		let params: Parameters = ["current_id": String(user.id), "days": 7];
		self.network.aby_request(request: UserRouter.stats(params: params)) { (json) -> (Void) in
//			ABYPrint(message: json)
			if let data = json?["data"] {
				self.setOtherData(data) // 设置累计数据
				self.setProgress(data) // 设置满意度数据
				self.timeLine = data["curve"]["time_line"].arrayObject as? [String]
				// 折线图设计
				self.active = data["curve"]["data"]["active"].arrayObject as? [Int]
				self.customer = data["curve"]["data"]["custom"].arrayObject as? [Int]
				self.session = data["curve"]["data"]["session"].arrayObject as? [Int]
			}
		}
	}

	func setOtherData(_ data: JSON) -> Void {
		self.dataArray[0].view?.contentLabel.text = data["user_active_time"].stringValue
		self.dataArray[1].view?.contentLabel.text = data["user_active_average_time"].stringValue
		self.dataArray[2].view?.contentLabel.text = String(data["session_count"].intValue)
		self.dataArray[3].view?.contentLabel.text = String(data["session_average_count"].intValue)
		self.dataArray[4].view?.contentLabel.text = String(data["user_reception_customer"].intValue)
		self.dataArray[5].view?.contentLabel.text = String(data["user_average_reception_customer"].intValue)
	}

	func setProgress(_ data: JSON) -> Void {
		guard let evaluate = data["user_evaluate"].dictionary else { return }
		self.progress.0?.progressValue = CGFloat((evaluate["good"]?.floatValue)!)
		self.progress.1?.progressValue = CGFloat((evaluate["bad"]?.floatValue)!)
	}
}
