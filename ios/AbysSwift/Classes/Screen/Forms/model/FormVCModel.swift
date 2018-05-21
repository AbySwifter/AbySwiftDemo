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

protocol FormVCModelDelegate {
    func dataUpdated() -> Void
}

class FormVCModel: NSObject {
	let network: ABYNetworkManager = {
		return ABYNetworkManager.shareInstance
	}()
    
    var delegate: FormVCModelDelegate?
	let segmentTitles: Array<String> = ["在线时长", "会话量", "接待客户数"];
	var timeLine: Array<String>?
    var timeDatas: Array<String> {
        guard let list = self.timeLine else {
            return ["0", "0", "0", "0", "0"]
        }
        var array = [String]()
        for item in list {
            let str = item.suffix(5)
            array.append(String(str))
        }
        return array
    }
    // 在线时长
	var active: Array<Int>?
    var activeTime: Array<Double> {
        guard let list = active else {
            return [0,0,0,0,0]
        }
        var array = [Double]()
        for time in list {
            let number = Double(time) / 360
            let str = String.init(format: "%.2f", number)
            let value = Double.init(str)
            array.append(value ?? 0)
        }
        return array
    }
    // 会话量
	var session: Array<Int>?
    var sessionNumber: Array<Double> {
        guard let list = session else {
            return [0,0,0,0,0]
        }
        var array: [Double] = []
        for i in list {
            array.append(Double(i))
        }
        return array
    }
    // 用户数
	var customer: Array<Int>?
    var customerNumber: Array<Double> {
        guard let list = customer else {
            return [0,0,0,0,0]
        }
        var array: [Double] = []
        for i in list {
            array.append(Double(i))
        }
        return array
    }
    // 视图的绑定，方便更改
	var dataArray: Array<DataTuple> = [
		("累计在线时长", "00:00:00", nil),
		("日均在线时长", "00:00:00", nil),
		("累计会话量", "0", nil),
		("日均会话量", "0", nil),
		("累计接待客户数", "0", nil),
		("日均接待客户数", "0", nil),
	];
    // 视图的绑定，方便更改
	var progress: (ABYProgressView?, ABYProgressView?) = (nil, nil)

	/// 获取报表数据
	func getData() -> Void {
		guard let user = Account.share.user else { return }
		let params: Parameters = ["current_id": String(user.id), "days": 7];
		self.network.aby_request(request: UserRouter.request(api: UserAPI.stats, params: params)) { (json) -> (Void) in
//			ABYPrint(message: json)
			if let data = json?["data"] {
				self.setOtherData(data) // 设置累计数据
				self.setProgress(data) // 设置满意度数据
                // 时间轴
				self.timeLine = data["curve"]["time_line"].arrayObject as? [String]
				// 折线图数据
				self.active = data["curve"]["data"]["active"].arrayObject as? [Int]
				self.customer = data["curve"]["data"]["customer"].arrayObject as? [Int]
				self.session = data["curve"]["data"]["session"].arrayObject as? [Int]
                self.delegate?.dataUpdated()
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
