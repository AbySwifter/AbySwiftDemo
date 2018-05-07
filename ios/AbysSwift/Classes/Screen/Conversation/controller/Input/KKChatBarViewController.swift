//
/**
* 好看的皮囊千篇一律，有趣的灵魂万里挑一
* 创建者: 王勇旭 于 2018/4/25
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

import UIKit

protocol KKChatBarViewControllerDelegate {
	func chatBarUpdate(height: CGFloat) -> Void
	func chatBar(send message: Message) -> Void
	func chatBarVC(_ chatBarVC: KKChatBarViewController, didChangeBottomDistance distance: CGFloat, duration: CGFloat) -> Void
	func chatBarMenuAction(type: ChatFootMenuTag) -> Void
    func chatBarRecordButton(event: RecordEvent) -> Void
}

enum LXFChatKeyboardType: Int {
	case noting
	case voice
	case text
	case emotion
	case more
}

class KKChatBarViewController: UIViewController, ChatFootMenuDelegate, ChatFootBarDelegate {
	var delegate: KKChatBarViewControllerDelegate?
    /// 聊天底部栏
	lazy var chatFoot: ChatFooterBar = {
		let chatFoot = ChatFooterBar.init(frame: CGRect.zero)
		chatFoot.delegate = self
		chatFoot.menuDelegate = self
		return chatFoot
	}()
    /// 录音管理员
    lazy var audioTool: AudioTool = {
        return AudioTool.defaut
    }()
    /// 文件管理员
    lazy var fileManager: KKFileManager = {
        return KKFileManager.distance
    }()
    /// 网络管理员
    lazy var networkManager: ABYNetworkManager = {
        return ABYNetworkManager.shareInstance
    }()
    /// 当前会话的房间号
	var roomID: Int16 = 0

	// MARK:- 记录属性
	var keyboardFrame: CGRect?
	var keyboardType: LXFChatKeyboardType?

	// 自定义的初始化方法
	init(roomID: Int16) {
		super.init(nibName: nil, bundle: nil)
		chatFoot.room_id = roomID
		self.roomID = roomID
	}
    override func viewDidLoad() {
        super.viewDidLoad()
		view.addSubview(chatFoot)
		chatFoot.snp.makeConstraints { (make) in
			make.left.right.bottom.equalTo(self.view)
			make.height.equalTo(kChatBarOriginHeight)
		}
		//FIXME: 监听键盘的方法需要添加
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameWillChange(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    /// 发送消息的总入口
    func sendMessage(_ message: Message) -> Void {
        message.deliver() // 发送消息
        self.delegate?.chatBar(send: message)
    }
}

// MARK: - 代理事件相关方法
extension KKChatBarViewController {
	func menuAction(type: ChatFootMenuTag) {
		// 点击菜单事事件的实现
		delegate?.chatBarMenuAction(type: type)
	}

	func footHeightChange(height: CGFloat, animate completion: @escaping CompontionBlock) {
		// 当bar的高度改变的时候，从这里进行
//		weak var weakSelf = self
		self.delegate?.chatBarUpdate(height: height)
		UIView.animate(withDuration: 0.3, animations: {
			self.chatFoot.snp.updateConstraints({ (make) in
				make.height.equalTo(height)
			})
			self.view.layoutIfNeeded()
		}) { (result) in
			completion()
		}
	}
    
    /// 发送消息并更新消息
    ///
    /// - Parameter message: 消息的描述
	func update(message: Message) {
		// 发送信息的时候从这里发出，这里需要把消息插入进去，用代理的方法传回到最初的View
        self.sendMessage(message)
	}
    
    /// 处理录音按钮的状态
    func chatFootRecord(event: RecordEvent) {
        switch event {
        case .start:
            delegate?.chatBarRecordButton(event: .start)
            self.startRecording()
            break
        case .recording:
            delegate?.chatBarRecordButton(event: .recording)
            break
        case .parpareToCancel:
            delegate?.chatBarRecordButton(event: .parpareToCancel)
            break
        case .cancel:
            self.cancelRecord()
            delegate?.chatBarRecordButton(event: .cancel)
            break
        case .stop:
            self.stopRecord()
            delegate?.chatBarRecordButton(event: .stop)
            break
        }
    }
}

// MARK: - 键盘事件相关方法
extension KKChatBarViewController {
	@objc fileprivate func keyboardWillHide(_ notification: NSNotification) {
		guard let kbInfo = notification.userInfo else {
			return
		}
		let duration = kbInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
		keyboardFrame = CGRect.zero
//		if barView.keyboardType == .emotion || barView.keyboardType == .more {
//			return
//		}
		if self.chatFoot.isMenuShow {
			self.chatFoot.hideMenu()
		}
		// 隐藏键盘
		delegate?.chatBarVC(self, didChangeBottomDistance: 0, duration: CGFloat(duration))
	}

	@objc fileprivate func keyboardFrameWillChange(_ notification: NSNotification) {
		guard let kbInfo = notification.userInfo else {
			return
		}
		let duration = kbInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
		keyboardFrame = kbInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect?
//		if barView.keyboardType == .emotion || barView.keyboardType == .more {
//			return
//		}
		delegate?.chatBarVC(self, didChangeBottomDistance: keyboardFrame?.height ?? 0, duration: CGFloat(duration))
	}
}


// MARK: - 语音录制的处理
extension KKChatBarViewController {
    /// 开始录制
    func startRecording() -> Void {
        let fileName = newGUID() // 生成文件名
        guard let userName = Account.share.user?.id else { return }
        let dirs = [ "\(userName)", "\(self.roomID)" ]
        guard let path = self.fileManager.createDirInCache(dirs: dirs) else {
            ABYPrint("创建用户目录失败")
            return
        }
        self.audioTool.filePath = path
        self.audioTool.startRecord(name: fileName)
    }
    
    /// 停止录制
    func stopRecord() -> Void {
        let result = self.audioTool.stopRecrod()
        // 停止录制的情况下，上传文件，组成消息，并发送
        // 首先判断录音时间是否过短
        let filePath = result.0 // 文件路径
        let fileDuration = result.1 // 文件时长
        let fileName = result.2 // 文件名称
        if fileDuration < 1.0 {
            // 录制时间过短
            // 删除文件
            _ = self.fileManager.removeFileIn(path: filePath)
            // FIXME: 更新视图
            
            return
        } else {
            //生成语音消息
            let messageElem = MessageElem.init(duration: Int(fileDuration), voice: filePath)
            let message = Message.init(elem: messageElem, room_id: self.roomID, messageID: fileName)
            // 上传语音消息
            self.sendMessage(message)
        }
        
    }
    /// 取消录制
    func cancelRecord() -> Void {
        let result = self.audioTool.stopRecrod()
        let filePath = result.0
        _ = self.fileManager.removeFileIn(path: filePath)
    }
}
