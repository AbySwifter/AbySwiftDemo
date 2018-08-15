//
/**
* 好看的皮囊千篇一律，有趣的灵魂万里挑一
* 创建者: 王勇旭 于 2018/4/23
* Copyright © 2018年 Aby.wang. All rights reserved.
* 4.0
*  ┏┓　　　┏┓
*┏┛┻━━━┛┻┓
*┃　　　　　　　┃
*┃　　　━　　　┃
*┃　┳┛　┗┳　┃
*┃　　　　　　　┃
*┃　　　┻　　　┃
*┃　　　　　　　┃
*┗━┓　　　┏━┛
*　　┃　　　┃神兽保佑
*　　┃　　　┃代码无BUG！
*　　┃　　　┗━━━┓
*　　┃　　　　　　　┣┓
*　　┃　　　　　　　┏┛
*　　┗┓┓┏━┳┓┏┛
*　　　┃┫┫　┃┫┫
*　　　┗┻┛　┗┻┛
*/
import SwiftDate

let kChatMsgImgMaxWidth: CGFloat = 125 // 最大图片宽度
let kChatMsgImgMinWidth: CGFloat = 50 // 最小图片宽度
let kChatMsgImgMaxHeight: CGFloat = 150 // 最大图片高度
let kChatMsgImgMinHeight: CGFloat = 50 // 最小图片高度

// 主要是给消息队列中加入时间显示，处理消息中的图片等信息
class KKChatMsgDataHelper: NSObject {
	static let shared:KKChatMsgDataHelper = KKChatMsgDataHelper.init()
	private override init() {
		super.init()
		// 设置时区，默认为上海
		let regionRome = Region(tz: TimeZoneName.asiaShanghai, cal: CalendarName.gregorian, loc: LocaleName.chinese)
		Date.setDefaultRegion(regionRome)
	}
	
	/**
	* 处理消息的时间添加
	*/
	func addTimeTo(finalModel: Message? = nil, messages: [Message]) -> Void {
		for index in 0..<messages.count {
			if index == 0 {
				// 第一条和历史消息中的最后一条比较
				if finalModel == nil {
					messages[index].showTime = true
				} else {
					if KKChatMsgDataHelper.shared.needAddMinuteModel(preModel: finalModel!, curModel: messages[index]) {
						messages[index].showTime = true
					}
				}
			} else {
				// 是否相差五分钟，是则添加
				if KKChatMsgDataHelper.shared.needAddMinuteModel(preModel: messages[index - 1], curModel: messages[index]) {
					messages[index].showTime = true
				}
			}
		}
	}

	func addTime(finalModel: Message, messages: [Message]) -> [Message] {
		var list: [Message] = [Message]()
		for index in 0 ..< messages.count {
			if index == 0 {
				
			} else {

			}
		}
		return list
	}
}

// 根据时间生成字符串
extension KKChatMsgDataHelper {
	// 两条不同的消息间，是否需要添加时间模型
	func needAddMinuteModel(preModel: Message, curModel: Message) -> Bool {
		guard let preTime = preModel.timestamp  else {
			return false
		}
		guard let curTime = curModel.timestamp else {
			return false
		}
		let perTimeInterval = TimeInterval.init(preTime/1000)
		let preDate = Date(timeIntervalSince1970: perTimeInterval)
		let preInRome = DateInRegion(absoluteDate: preDate)
		let curTimeInterval = TimeInterval.init(curTime/1000)
		let curDate = Date(timeIntervalSince1970: curTimeInterval)
		let curInRome = DateInRegion(absoluteDate: curDate)

		let yesr = curInRome.year - preInRome.year
		let month = curInRome.month - preInRome.month
		let day = curInRome.day - preInRome.day
		let hour = curInRome.hour - preInRome.hour
		let minute = curInRome.minute - preInRome.minute
		if yesr > 0 || month > 0 || day > 0 || hour > 0 {
			return true
		} else if minute >= 5 {
			return true
		} else {
			return false
		}
	}
	
    /// 根据传入时间计算与当前时间相差多久的字符串
    ///
    /// - Parameter time: 过去的时间
    /// - Returns: 计算结果字符串
	func chatTimeString(with time: TimeInterval) -> String {
		// 消息时间
		let date = Date.init(timeIntervalSince1970: time)
		let dateInRome = DateInRegion.init(absoluteDate: date)
		// 当前时间
		let now = DateInRegion.init()
		// 相差年份
		let year = now.year - dateInRome.year
		// 相差月数
		let month = now.month - dateInRome.month
		// 相差天数
		let day = now.day - dateInRome.day
		// 相差小时数
		let hour = now.hour - dateInRome.hour
		// 相差分钟数
		let minute = now.minute - dateInRome.minute
		// 相差秒数
		let second = now.second - dateInRome.second
		if year != 0 {
			return String(format: "%d年%d月%d日 %d:%02d", dateInRome.year, dateInRome.month, dateInRome.day, dateInRome.hour, dateInRome.minute)
		} else if year == 0 {
			if month > 0 || day > 7 {
				return String(format: "%d月%d日 %d:%02d", dateInRome.month, dateInRome.day, dateInRome.hour, dateInRome.minute)
			} else if day > 2 {
				return String(format: "%@ %d:%02d", dateInRome.weekdayName, dateInRome.hour, dateInRome.minute)
			} else if day == 2 {
				return String(format: "前天 %d:%d", dateInRome.hour, dateInRome.minute)
			} else if dateInRome.isYesterday {
				return String(format: "昨天 %d:%d", dateInRome.hour, dateInRome.minute)
			} else if hour > 0 {
				return String(format: "%d:%02d",dateInRome.hour, dateInRome.minute)
			} else if minute > 0 {
				return String(format: "%02d分钟前", minute)
			} else if second > 10 {
				return String(format: "%d秒前",second)
			} else  {
				return String(format: "刚刚")
			}
		}
		return ""
	}
}

extension TimeInterval {
    /// 根据传入时间计算与当前时间相差多久的字符串
    ///
    /// - Parameter time: 过去的时间
    /// - Returns: 计算结果字符串
    func chatTimeString() -> String {
        // 消息时间
        let date = Date.init(timeIntervalSince1970: self)
        let dateInRome = DateInRegion.init(absoluteDate: date)
        // 当前时间
        let now = DateInRegion.init()
        // 相差年份
        let year = now.year - dateInRome.year
        // 相差月数
        let month = now.month - dateInRome.month
        // 相差天数
        let day = now.day - dateInRome.day
        // 相差小时数
        let hour = now.hour - dateInRome.hour
        // 相差分钟数
        let minute = now.minute - dateInRome.minute
        // 相差秒数
        let second = now.second - dateInRome.second
        if year != 0 {
            return String(format: "%d年%d月%d日 %d:%02d", dateInRome.year, dateInRome.month, dateInRome.day, dateInRome.hour, dateInRome.minute)
        } else if year == 0 {
            if month > 0 || day > 7 {
                return String(format: "%d月%d日 %d:%02d", dateInRome.month, dateInRome.day, dateInRome.hour, dateInRome.minute)
            } else if day > 2 {
                return String(format: "%@ %d:%02d", dateInRome.weekdayName, dateInRome.hour, dateInRome.minute)
            } else if day == 2 {
                return String(format: "前天 %d:%d", dateInRome.hour, dateInRome.minute)
            } else if dateInRome.isYesterday {
                return String(format: "昨天 %d:%d", dateInRome.hour, dateInRome.minute)
            } else if hour > 0 {
                return String(format: "%d:%02d",dateInRome.hour, dateInRome.minute)
            } else if minute > 0 {
                return String(format: "%02d分钟前", minute)
            } else if second > 10 {
                return String(format: "%d秒前",second)
            } else  {
                return String(format: "刚刚")
            }
        }
        return ""
    }
}
