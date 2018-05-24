//
//  KKChatEditorView.swift
//  AbysSwift
//
//  Created by aby on 2018/5/10.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit

enum EditorStatus {
    case none
    case text
    case emotion
    case more
    case voice
}

fileprivate enum RecordingDragStatus: Int {
    case noDrag = 0
    case dragInside = 1
    case dragOutside = 2
}

/// 录音事件，向外传递
enum RecordEvent {
    case start
    case parpareToCancel
    case recording
    case cancel
    case stop
}

protocol KKChatEditorDelegate {
    // 编辑状态变化事件
    func chatEditorBar(pervious status: EditorStatus, to current: EditorStatus) -> Void
    func chatEditorBar(send message: Message) -> Void
    func chatEditorBar(recordEvent: RecordEvent) -> Void
    func chatEditorBarHeightChanged(value: CGFloat) -> Void
}

let kChatBarOriginHeight: CGFloat = 55
let kChatBarTextViewHeight: CGFloat = 34.0
let kChatBarTextViewMaxHeight: CGFloat = 80

class KKChatEditorView: UIView {
    var currentStatus: EditorStatus = .none {
        didSet {
            self.previousStatus = oldValue
            self.changeState(currentStatus)
            self.delegate?.chatEditorBar(pervious: self.previousStatus, to: self.currentStatus)
        }
    }
    var previousStatus: EditorStatus = .none
    var isInputModel: Bool = true
    var room_id: Int16?
    var delegate: KKChatEditorDelegate?
    var inputTextViewCurHeight: CGFloat = kChatBarTextViewHeight {
        didSet {
            self.delegate?.chatEditorBarHeightChanged(value: self.totalHeight)
        }
    }
    var totalHeight: CGFloat {
        if self.currentStatus != .voice {
            return inputTextViewCurHeight + 19
        } else {
            return kChatBarOriginHeight
        }
    }
    // 语音消息的记录
    private let normalTitle = "按住 说话"
    private let highlightedTitle = "松开 结束"
    private var dragStatus: RecordingDragStatus = .noDrag // 默认未开始拖拽
    private let placeholder = "请输入..."
    // MARK: - 懒加载
    // 切换输入状态的方法
    private lazy var changeStateBtn: UIButton = {
        let btn = UIButton.init(type: UIButtonType.custom)
        let edgeInsert = UIEdgeInsets.init(top: 5, left: 15, bottom: 5, right: 5)
        btn.imageEdgeInsets = edgeInsert
        btn.imageView?.contentMode = .scaleAspectFit
        btn.setImage(#imageLiteral(resourceName: "footer_voice_icon"), for: .normal)
        btn.setImage(#imageLiteral(resourceName: "footer_scanf_icon"), for: .selected)
        btn.addTarget(self, action: #selector(switchVoiceAndTextEditStatus(_:)), for: .touchUpInside)
        return btn
    }()
    // 打开菜单的方法
    lazy var menuBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        let edgeInsert = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 15)
        btn.setImage(#imageLiteral(resourceName: "footer_more_icon"), for: .normal)
        btn.imageEdgeInsets = edgeInsert
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(switchMoreBoard(_:)), for: .touchUpInside)
        return btn
    }()
    // 发送消息的方法
    lazy var sendBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        let edgeInsert = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 15)
        btn.setImage(#imageLiteral(resourceName: "sender_btn_icon"), for: .normal)
        btn.imageEdgeInsets = edgeInsert
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(sendAction(_:)), for: .touchUpInside)
        return btn
    }()
    // 消息输入框
    lazy var  textMsgInput: UITextView = {
        let inputV = UITextView.init()
        inputV.font = UIFont.systemFont(ofSize: 15.0)
        inputV.textColor = UIColor.black
        inputV.returnKeyType = .send
        inputV.enablesReturnKeyAutomatically = true
        inputV.delegate = self
        inputV.text = self.placeholder
        inputV.textColor = UIColor.gray
        return inputV
    }()
    
    // 语音消息按钮
    lazy var voiceBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitleColor(UIColor.init(hexString: "333333"), for: .normal)
        btn.setTitle("按住 说话", for: .normal)
        btn.isHidden = true
        btn.layer.cornerRadius = 5.0
        btn.layer.borderColor = UIColor.init(hexString: "cfcfcf").cgColor
        btn.layer.borderWidth = 1 / UIScreen.main.scale
        btn.backgroundColor = UIColor.white
        return btn
    }()
    // MARK: - 计算属性
    var isTextNil: Bool {
        guard let text = self.textMsgInput.text else { return true }
        return text == "" || text  == "请输入..."
    }
    var textMsg: String {
        return self.textMsgInput.text ?? ""
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViewAction()// 添加视图
        makeConstraintsAction() // 设置约束
        setupEventes()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 点击事件的处理
extension KKChatEditorView {
    /// 切换文本编辑状态和录音编辑状态的方法
    @objc
    func switchVoiceAndTextEditStatus(_ sender: UIButton) -> Void {
        // 检查语音权限
        if sender.isSelected {
            self.currentStatus = .none
        } else {
            AudioTool.defaut.checkPermission()
            // 跳转之前检查语音权限
            if AudioTool.defaut.hasPermisssion == .granted {
                self.currentStatus = .voice
            } else if AudioTool.defaut.hasPermisssion == .undetermined {
                AudioTool.defaut.requestAccessForAudio()
                return
            } else if AudioTool.defaut.hasPermisssion == .denied {
                // 没有录音权限，需要提示
                return
            }
        }
    }
    
    // 更多菜单的开关
    @objc
    func switchMoreBoard(_ sender: UIButton) -> Void {
        if self.currentStatus != .more {
            self.currentStatus = .more
        } else {
            self.currentStatus = .text
        }
    }
    // 发送消息的动作
    @objc
    func sendAction(_ sender: UIButton) -> Void {
        // 在这里的发送方法只涉及到了文本消息的发送
        // 首先判断消息发送框是否为空
        guard !isTextNil else {
            ABYPrint("warning: 消息为空")
            return
        }
        guard let room_id = room_id else {
            ABYPrint("warning: 房间号不存在")
            return
        }
        ABYPrint("发送文本消息")
        let message = Message.init(text: textMsg, room_id:room_id ) // 组装消息
        self.delegate?.chatEditorBar(send: message)
        self.textMsgInput.text = "" // 清空文本框
        inputTextViewCurHeight = kChatBarTextViewHeight // 回复最初的文本高度
    }
}


// MARK: - 文本
extension KKChatEditorView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.currentStatus = .text
        if textView.text == self.placeholder {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = self.placeholder
            textView.textColor = UIColor.gray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        var height = textView.sizeThatFits(CGSize.init(width: textMsgInput.width, height: CGFloat(Float.greatestFiniteMagnitude))).height
        height = height > kChatBarTextViewHeight ? height : kChatBarTextViewHeight
        height = height < kChatBarTextViewMaxHeight ? height : textView.height
        if height != textView.height {
           inputTextViewCurHeight = height
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendAction(self.sendBtn)
            return false
        }
        return true
    }
}
// MARK: - 语音
extension KKChatEditorView {
    /// 点击按钮的方法
    ///
    /// - Parameter btn: 按钮
    @objc
    func touchDownInSide(_ btn: UIButton, event: UIEvent) -> Void {
        dragStatus = .dragInside
        replaceRecordBtnUI(isRecording: true)
        self.delegate?.chatEditorBar(recordEvent: RecordEvent.start) // 开始录音
    }
    /// 拖拽的处理
    ///
    /// - Parameter btn: 按钮
    @objc
    func dragon(_ btn: UIButton, event: UIEvent) -> Void {
        guard let touch: UITouch = event.allTouches?.first else { return }
        let isTouchInside: Bool = voiceBtn.point(inside: touch.location(in: voiceBtn), with: event)
        if isTouchInside {
            guard dragStatus == .dragOutside else { return }
            dragStatus = .dragInside
            self.delegate?.chatEditorBar(recordEvent: RecordEvent.recording) // 录音
        } else {
            guard dragStatus == .dragInside else {return}
            dragStatus = .dragOutside
            self.delegate?.chatEditorBar(recordEvent: RecordEvent.parpareToCancel) // 准备取消
        }
    }
    /// 在里面抬起的方法
    ///
    /// - Parameter btn: 按钮
    @objc
    func touchUpInSide(_ btn: UIButton, event: UIEvent) -> Void {
        dragStatus = .noDrag
        replaceRecordBtnUI(isRecording: false)
        self.delegate?.chatEditorBar(recordEvent: RecordEvent.stop)// 停止
    }
    /// 在外部抬起的方法
    ///
    /// - Parameter btn: 按钮
    @objc
    func touchUpOutSide(_ btn: UIButton, event: UIEvent) -> Void {
        replaceRecordBtnUI(isRecording: false)
        dragStatus = .noDrag
        self.delegate?.chatEditorBar(recordEvent: RecordEvent.cancel) // 取消
    }
    /// 取消的方法
    @objc
    func touchCancel() -> Void {
        dragStatus = .noDrag
        replaceRecordBtnUI(isRecording: false)
    }
    fileprivate func setupEventes() {
        voiceBtn.addTarget(self, action: #selector(touchDownInSide(_:event:)), for: .touchDown)
        voiceBtn.addTarget(self, action: #selector(touchUpInSide(_:event:)), for: .touchUpInside)
        voiceBtn.addTarget(self, action: #selector(touchUpOutSide(_:event:)), for: .touchUpOutside)
        voiceBtn.addTarget(self, action: #selector(dragon(_:event:)), for: .touchDragOutside)
        voiceBtn.addTarget(self, action: #selector(dragon(_:event:)), for: .touchDragInside)
        voiceBtn.addTarget(self, action: #selector(touchCancel), for: .touchCancel)
    }
    // 切换 录音按钮的UI
    fileprivate func replaceRecordBtnUI(isRecording: Bool) {
        if isRecording {
            voiceBtn.setTitle(highlightedTitle, for: .normal)
        } else {
            voiceBtn.setTitle(normalTitle, for: .normal)
        }
    }
}

extension KKChatEditorView {
    fileprivate func addSubViewAction() -> Void {
        addSubview(changeStateBtn)
        addSubview(menuBtn)
        addSubview(sendBtn)
        addSubview(textMsgInput)
        addSubview(voiceBtn)
    }
    
    fileprivate func makeConstraintsAction() {
        changeStateBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(30)
        }
        sendBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(40)
        }
        menuBtn.snp.makeConstraints { (make) in
            make.right.equalTo(sendBtn.snp.left)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(40)
        }
        textMsgInput.snp.makeConstraints { (make) in
            make.left.equalTo(changeStateBtn.snp.right).offset(15)
            make.right.equalTo(menuBtn.snp.left).offset(-15)
//            make.width.lessThanOrEqualTo(W750(750) - 170)
            make.top.equalTo(self.snp.top).offset(9.5)
            make.bottom.equalTo(self.snp.bottom).offset(9.5)
        }
        voiceBtn.snp.makeConstraints { (make) in
            make.left.equalTo(changeStateBtn.snp.right).offset(15)
            make.right.equalToSuperview().offset(-70)
            make.height.greaterThanOrEqualTo(30)
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: -切换状态
extension KKChatEditorView {
    private func changeState(_ state: EditorStatus) -> Void {
        switch state {
        case .none:
            textMsgInput.resignFirstResponder()
            changetoInputModel()
        case .voice:
            textMsgInput.resignFirstResponder()
            changeToRecordModel()
        case .text:
            changetoInputModel()
            textMsgInput.becomeFirstResponder()
        case .more:
            textMsgInput.resignFirstResponder()
            changetoInputModel()
        default:
            break
        }
    }
    
    func changetoInputModel() {
        guard !isInputModel else { return }
        isInputModel = true
        UIView.animate(withDuration: 0.3, animations: {
            self.menuBtn.snp.remakeConstraints({ (make) in
                make.right.equalTo(self.sendBtn.snp.left)
                make.centerY.equalToSuperview()
                make.height.equalTo(30)
                make.width.equalTo(40)
            })
            self.textMsgInput.isHidden = false
            self.voiceBtn.isHidden = true
            self.layoutIfNeeded()
        })
        self.sendBtn.isHidden = false
        self.changeStateBtn.isSelected = false
    }
    
    func changeToRecordModel() {
        guard isInputModel else { return }
        isInputModel = false
        UIView.animate(withDuration: 0.3, animations: {
            self.menuBtn.snp.remakeConstraints({ (make) in
                make.right.equalToSuperview().offset(-10)
                make.centerY.equalToSuperview()
                make.height.equalTo(30)
                make.width.equalTo(40)
            })
            self.textMsgInput.isHidden = true
            self.voiceBtn.isHidden = false
            self.layoutIfNeeded()
        })
        sendBtn.isHidden = true
        self.changeStateBtn.isSelected = true
    }
}
