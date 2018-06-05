//
//  ReplayViewController.swift
//  AbysSwift
//
//
//  Created by aby on 2018/6/1.
//Copyright © 2018年 Aby.wang. All rights reserved.
//
// @class ReplayViewController
// @abstract 话术回复类
// @discussion 展示并回复话术
//

import UIKit

class ReplayViewController: UIViewController {
    /// 显示回复的Label
    lazy var textLabel: UITextView = {
        let lable = UITextView.init()
        lable.backgroundColor = UIColor.white
        lable.textAlignment = .left
        lable.textContainerInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        lable.isEditable = false
        lable.font = UIFont.systemFont(ofSize: 16.0)
        return lable
    }()
    
   /// 发送按钮
    lazy var sendBtn: UIButton = {
        let btn = UIButton.init(bgColor: ABYGlobalThemeColor(), disabledColor: kBtnDisabledGreen, title: "发送", titleColor: UIColor.white, titleHighlightedColor: nil)
        btn.addTarget(self, action: #selector(send(_:)), for: .touchUpInside)
        return btn
    }()
    
    var sendAction: ((String) -> Void)?
    //MARK: Initial Methods
    
    
    //MARK: Internal Methods
    var message: Message? {
        didSet {
            if let msg = message {
                textLabel.text = msg.content?.reply ?? ""
            } else {
                textLabel.text = ""
            }
            sendBtn.isEnabled = !isSendBtnDisabled
        }
    }
    
    var isSendBtnDisabled: Bool {
        return textLabel.text == "" || textLabel.text == nil
    }
    
    //MARK: Public Methods
    
    
    //MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.hexInt(0xececec)
        view.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-124)
        }
        view.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-40)
            make.height.equalTo(44)
        }
    }
    
    //MARK: Privater Methods
    
    
    //MARK: KVO Methods
    
    
    //MARK: Notification Methods
    
    
    //MARK: Target Methods
    @objc
    private func send(_ sender: UIButton) -> Void {
        ABYPrint("发送的方法")
        self.sendAction?(self.textLabel.text)
        self.message = nil
        self.navigationController?.popViewController(animated: true)
    }

}
