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
import AVFoundation
import Photos
import DTTools

protocol KKChatBarViewControllerDelegate {
	func chatBarUpdate(height: CGFloat) -> Void
	func chatBar(send message: Message) -> Void
	func chatBarMenuAction(type: ChatFootMenuTag) -> Void
    func chatBarRecordButton(event: RecordEvent) -> Void
}

extension KKChatBarViewControllerDelegate {
    func chatBarMenuAction(type: ChatFootMenuTag) -> Void {
        DTLog("默认的点击事件,\(type)")
    }
}

let kKeyboardChangeFrameTime: TimeInterval = 0.25
let kNoTextKeyboardHeight: CGFloat = 216.0

class KKChatBarViewController: UIViewController {
    var delegate: KKChatBarViewControllerDelegate? {
        didSet {
            DTLog("设置了代理\(delegate)")
        }
    }
    var pageViewController: UIViewController
    /// 聊天底部编辑栏
    private lazy var chatEditor: KKChatEditorView = {
        let view: KKChatEditorView = KKChatEditorView.init()
        view.delegate = self
        return view
    }()
    /// 键盘视图
    lazy var boardView: UIView = {
        let view: UIView = UIView.init()
        return view
    }()
    /// 更多菜单键盘
    lazy var moreBoard: ChatFooterMenu = {
        let menu = ChatFooterMenu.init(frame: CGRect.zero)
        menu.delegate = self
        return menu
    }()
    /// iPhone X适配区域
    lazy var iPhoneXView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }()
    /// 录音管理员
    lazy var audioTool: AudioTool = {
        AudioTool.defaut.delegate = self
        return AudioTool.defaut
    }()
    /// 文件管理员
    lazy var fileManager: KKFileManager = {
        return KKFileManager.distance
    }()
    /// 当前会话的房间号
	var roomID: Int16 = 0
    var iPhoneHeight: CGFloat {
        if self.currentStatus == .text {
            return 0
        }
        return UIDevice.current.isX() ? 34 : 0
    }
    var originHeight: CGFloat {
        return iPhoneHeight + editBarHeight + keyboardHeight
    }
    
    lazy var tips: UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = ABYGlobalThemeColor()
        label.text = "有新推荐"
        return label
    }()
   
    /// 计算属性，处理消息的编辑状态
    var currentStatus: EditorStatus {
        get {
            return self.chatEditor.currentStatus
        }
        set {
            self.chatEditor.currentStatus = newValue
        }
    }
	// MARK:- 记录属性
	var keyboardHeight: CGFloat = 0 // 记录当前的键盘的高度
	var keyboardType: EditorStatus? // 记录当前应该显示的视图
    var finishRecordingVoice: Bool = true
    var editBarHeight: CGFloat = kChatBarOriginHeight

	// 自定义的初始化方法
    init(roomID: Int16, page: UIViewController) {
        self.pageViewController = page
		super.init(nibName: nil, bundle: nil)
		chatEditor.room_id = roomID
		self.roomID = roomID
	}
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(chatEditor)
        chatEditor.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.view)
            make.height.equalTo(kChatBarOriginHeight)
        }
        view.addSubview(boardView)
        boardView.addSubview(moreBoard) // 添加moreBoard键盘
        boardView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.height.equalTo(0) // 初始化为0
            make.top.equalTo(chatEditor.snp.bottom)
        }
        moreBoard.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(boardView)
        }
        view.addSubview(iPhoneXView)
        iPhoneXView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.height.equalTo(iPhoneHeight)
        }
        view.addSubview(tips)
        tips.snp.makeConstraints { (make) in
            make.right.equalTo(self.view.snp.right).offset(-15)
            make.bottom.equalTo(self.view.snp.top).offset(-5)
        }
        tips.sizeToFit()
        tips.isHidden = true
        view.clipsToBounds = false
    }

    func addNotification() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func removeNotification() -> Void {
        NotificationCenter.default.removeObserver(self)
    }
 
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    /// 发送消息的总入口（在当前会话）
    func sendMessage(_ message: Message) -> Void {
        message.deliver() // 发送消息
        self.delegate?.chatBar(send: message)
    }
    
    func showTips() -> Void {
        self.tips.isHidden = false
        let alphaAnimation = CABasicAnimation.init(keyPath: "opacity")
        alphaAnimation.fromValue = 0.0
        alphaAnimation.toValue = 1.0
        alphaAnimation.duration = 0.5
        alphaAnimation.beginTime = 0.0
        let alphaAnimation_2 = CABasicAnimation.init(keyPath: "opacity")
        alphaAnimation_2.fromValue = 1.0
        alphaAnimation_2.toValue = 0.0
        alphaAnimation_2.duration = 0.5
        alphaAnimation_2.beginTime = 1.0
        let group = CAAnimationGroup.init()
        group.animations = [alphaAnimation, alphaAnimation_2]
        group.duration = 1.5
        group.repeatCount = 1
        group.delegate = self
        group.fillMode = CAMediaTimingFillMode.forwards
        self.tips.layer.add(group, forKey: nil)
    }
    
    func hiddenTip(_ hidden: Bool) {
        self.chatEditor.showTip = !hidden
        self.moreBoard.changeTips(who: [.speakRoutine], status: hidden)
    }
}

extension KKChatBarViewController: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        self.tips.layer.opacity = 1.0
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.tips.layer.opacity = 0.0
    }
}

// MARK: - 语音录制的处理
extension KKChatBarViewController: AudioToolDelegate {
    /// 开始录制
    func startRecording() -> Void {
        finishRecordingVoice = true
        let fileName = newGUID() // 生成文件名
        guard let userName = Account.share.user?.id else { return }
        let dirs = [ "\(userName)", "\(self.roomID)" ]
        guard let path = self.fileManager.createDirInCache(dirs: dirs) else {
            DTLog("创建用户目录失败")
            return
        }
        self.audioTool.filePath = path
        self.audioTool.startRecord(name: fileName)
    }
    /// 停止录制
    func stopRecord() -> Void {
        finishRecordingVoice = true
        self.audioTool.stopRecrod()
    }
    /// 取消录制
    func cancelRecord() -> Void {
        finishRecordingVoice = false
        self.audioTool.stopRecrod()
//        let filePath = result.0
//        _ = self.fileManager.removeFileIn(path: filePath)
    }
    
    func audioToolRecorded(path: String, duration: Double, name: String) {
        guard path != "" && name != "" else { return }
        guard finishRecordingVoice else {
            _ = self.fileManager.removeFileIn(path: path)
            return
        }
        if duration < 1.0 {
            // 录制时间过短
            // 删除文件
            _ = self.fileManager.removeFileIn(path: path)
            // FIXME: 更新视图，提示录制时间太短
            
            return
        } else {
            //生成语音消息
            let messageElem = MessageElem.init(duration: Int(duration), voice: path)
            let message = Message.init(elem: messageElem, room_id: self.roomID, messageID: name)
            // 上传语音消息
            self.sendMessage(message)
        }
    }
}

// 发送消息的代理
extension KKChatBarViewController: KKChatEditorDelegate {
    func changeEditorStatus(_ status: EditorStatus) -> Void {
        if self.currentStatus != status {
            self.currentStatus = status
        }
    }
    func chatEditorBar(pervious status: EditorStatus, to current: EditorStatus) {
        switch current {
        case .none:
            self.keyboardHeight = 0
            // 回复到最初的状态
            self.boardView.snp.updateConstraints { (make) in
                make.height.equalTo(self.keyboardHeight)
            }
            self.editBarHeight = self.chatEditor.totalHeight
            self.chatEditor.snp.updateConstraints { (make) in
                make.height.equalTo(self.editBarHeight)
            }
            self.delegate?.chatBarUpdate(height: originHeight)
            break
        case .more:
            self.keyboardHeight = 76
            // 打开了菜单高度为76
            self.boardView.snp.updateConstraints { (make) in
                make.height.equalTo(self.keyboardHeight)
            }
            self.delegate?.chatBarUpdate(height: self.originHeight)
            break
        case .text:
            // 文本编辑状态
            self.chatEditor.textMsgInput.becomeFirstResponder()
            self.editBarHeight = self.chatEditor.totalHeight
            self.chatEditor.snp.updateConstraints { (make) in
                make.height.equalTo(self.editBarHeight)
            }
            self.delegate?.chatBarUpdate(height: originHeight)
            break
        case .voice:
            self.keyboardHeight = 0
            self.boardView.snp.updateConstraints { (make) in
                make.height.equalTo(self.keyboardHeight)
            }
            self.editBarHeight = self.chatEditor.totalHeight
            self.chatEditor.snp.updateConstraints { (make) in
                make.height.equalTo(self.editBarHeight)
            }
            self.delegate?.chatBarUpdate(height: originHeight)
            // 语音发送状态
            break
        case .emotion:
            // 表情键盘
            break
        }
    }

    func chatEditorBarHeightChanged(value: CGFloat) {
        self.editBarHeight = value
        self.chatEditor.snp.updateConstraints { (make) in
            make.height.equalTo(value)
        }
        self.delegate?.chatBarUpdate(height: self.originHeight)
    }
    
    func chatEditorBar(send message: Message) {
        self.sendMessage(message)
    }
    
    func chatEditorBar(recordEvent: RecordEvent) {
        switch recordEvent {
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
   
    @objc fileprivate func keyboardWillHide(_ notification: NSNotification) {
//        guard let kbInfo = notification.userInfo else {
//            return
//        }
        //        let duration = kbInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        DTLog(self.currentStatus)
        self.keyboardHeight = 0
        if self.currentStatus == .text {
            self.currentStatus = .none
        }
    }
    
    @objc fileprivate func keyboardFrameWillChange(_ notification: NSNotification) {
        guard let kbInfo = notification.userInfo else {
            return
        }
        //        let duration = kbInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let keyboardHeight = (kbInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect?)?.height ?? 0
        self.keyboardHeight = keyboardHeight
        self.delegate?.chatBarUpdate(height: originHeight)
    }
}

// MARK: -ChatFootMenuDelegate
extension KKChatBarViewController: ChatFootMenuDelegate {
    func menuAction(type: ChatFootMenuTag) {
        switch type {
        case .photo:
            openPhotoLibaray(UIImagePickerController.SourceType.photoLibrary)
        case .camera:
            openPhotoLibaray(UIImagePickerController.SourceType.camera)
        default: // 发出没有过滤的事件
            self.delegate?.chatBarMenuAction(type: type)
        }
        self.currentStatus = EditorStatus.none
    }
}

// MARK: -相册和相机
extension KKChatBarViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 取消了的回调
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 生成图片消息
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        var imagePath: String = ""
//        if #available(iOS 11.0, *) {
//           imagePath = (info[UIImagePickerControllerImageURL] as! URL).path
//        } else {
//             DTLog("\(info[UIImagePickerControllerPHAsset] as! URL)")
//        }

        imagePath = (info[UIImagePickerController.InfoKey.imageURL] as! URL).path
          DTLog("选取的文件路径为\(imagePath)")
        let size = image.size
        let message = Message.init(image: imagePath, size: size, room_id: self.roomID, isKH: false)
        self.sendMessage(message)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func openPhotoLibaray(_ type: UIImagePickerController.SourceType) -> Void {
        var permission: PermissonStatus = .granted
        if type == .camera {
            permission = checkCreamaPermission()
        } else {
            permission = checkPhotoLibarayPermission()
        }
        guard permission == .granted else {
            if permission == .undetermined {
                if type == .camera {
                    AVCaptureDevice.requestAccess(for: .video) { (result) in
                        DTLog("请求权限的结果: \(result)")
                    }
                } else {
                    PHPhotoLibrary.requestAuthorization { (result) in
                        DTLog("权限请求结果： \(result)")
                    }
                }
            } else {
                // 暂时的解决方案是在底部提示
                self.pageViewController.showToast("没有相应权限，请到设置中开启")
            }
            return
        }
        let picker: UIImagePickerController = UIImagePickerController.init()
        picker.delegate = self
        picker.sourceType = type
        picker.allowsEditing = false
        if UIImagePickerController.isSourceTypeAvailable(type) {
            self.pageViewController.present(picker, animated: true, completion: nil)
        } else {
            // 没有权限
        }
    }
    // 检查相机权限
    func checkCreamaPermission() -> PermissonStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        var result: PermissonStatus = .granted
        switch status {
        case .authorized:
            result = .granted
        case .denied:
            result = .denied
        case .notDetermined:
            result = .undetermined
        case .restricted:
            result = .granted
        }
        return result
    }
    // 检查相册权限
    func checkPhotoLibarayPermission() -> PermissonStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        var result: PermissonStatus = .granted
        switch status {
        case .authorized:
            result = .granted
        case .denied:
            result = .denied
        case .notDetermined:
            result = .undetermined
        case .restricted:
            result = .denied
        }
        return result
    }
}
