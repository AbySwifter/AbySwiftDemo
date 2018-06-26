//
//  AddTagController.swift
//  AbysSwift
//
//
//  Created by aby on 2018/6/15.
//Copyright © 2018年 Aby.wang. All rights reserved.
//
// @class AddTagController
// @abstract 添加标签页
// @discussion 完成添加标签的功能
//

import UIKit
import DTTools

protocol AddTagControllerdelegate {
    func add(tags:[String]) -> Void
}

class AddTagController: UIViewController, UITextFieldDelegate {
    var delegate: AddTagControllerdelegate?
    lazy var textField: UITextField = {
        let textField: UITextField = UITextField.init()
        textField.placeholder = "请输入标签"
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.addTarget(self, action: #selector(valueChanged(_:)), for: .editingChanged)
        textField.addObserver(self, forKeyPath: "text", options: .new, context: nil)
        textField.delegate = self
        textField.returnKeyType = .done
        return textField
    }()
    
    lazy var addbtn: UIButton = {
        let btn = UIButton.init(bgColor: UIColor.hexInt(0x0084bf), disabledColor: nil, title: "添加", titleColor: UIColor.white, titleHighlightedColor: nil)
        btn.addTarget(self, action: #selector(addTag(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var explain: UILabel = {
        let explainLabel = UILabel.init()
        explainLabel.font = UIFont.systemFont(ofSize: 14.0)
        explainLabel.textColor = UIColor.hexInt(0x646464)
        explainLabel.text = "多个备注之间请以“；”间隔"
        return explainLabel
    }()
    
    lazy var tagIcon: UIImageView = {
        let icon  = UIImageView.init()
        icon.image = #imageLiteral(resourceName: "remark")
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    lazy var tagTitle: UILabel = {
        let titleLabel = UILabel.init()
        titleLabel.text = "常用标签"
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        titleLabel.textColor = UIColor.hexInt(0x333333)
        return titleLabel
    }()
    var tagString: String = ""
    var addTagArray: [String] = []
    var tags = ["女性消费者", "土豪", "穷游", "喜爱美食", "关心价格", "不介意价格"]
    lazy var tagView: TagView = {
        let maxW = self.view.width - 40
        let tagView = TagView.init(tags: tags, maxRowW: maxW, rowH: W375(45), marginX: W375(20), showAddBtn: false, showClose: false)
        tagView.delegate = self
        return tagView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupUI()
        textField.becomeFirstResponder() //自动获得焦点
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Privater Methods
    private func setupUI() {
        view.addSubview(addbtn)
        addbtn.snp.makeConstraints { (make) in
            make.width.equalTo(W375(62))
            make.height.equalTo(W375(35))
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(20)
        }
        view.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(W375(35))
            make.top.equalToSuperview().offset(20)
            make.right.equalTo(addbtn.snp.left).offset(-20)
        }
        view.addSubview(explain)
        explain.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(textField.snp.bottom).offset(5)
        }
        view.addSubview(tagIcon)
        tagIcon.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(explain.snp.bottom).offset(W375(30))
            make.width.height.equalTo(W375(20))
        }
        view.addSubview(tagTitle)
        tagTitle.snp.makeConstraints { (make) in
            make.left.equalTo(tagIcon.snp.right).offset(W375(16))
            make.centerY.equalTo(tagIcon.snp.centerY)
        }
        view.addSubview(tagView)
        tagView.snp.makeConstraints { (make) in
            make.top.equalTo(tagIcon.snp.bottom).offset(W375(22))
            make.left.equalTo(view.snp.left).offset(20)
            make.height.equalTo(tagView.totalHeight)
            make.width.equalTo(tagView.maxRowWidth)
        }
    }
    
    //MARK: KVO Methods
    
    
    //MARK: Notification Methods
    
    /// textField回车键内容
    ///
    /// - Parameter textField: textField
    /// - Returns: 返回值不知道是干什么的
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.addTag(addbtn)
        return true
    }
    
    //MARK: Target Methods
    @objc
    func addTag(_ sender: UIButton) -> Void {
        guard tagString != "" else {
            self.showToast("添加标签为空哦")
            return
        }
        // 点击添加的按钮
        addTagArray = tagString.components(separatedBy: ";")
        addTagArray = addTagArray.filter({ (value) -> Bool in
            return value != ""
        })
        addTagArray = addTagArray.map { (string) -> String in
            return string.trimmingCharacters(in: .whitespaces)
        }
        DTLog(addTagArray)
        if textField.isFirstResponder {
              textField.resignFirstResponder()
        }
        // 将选择好的标签传过去
        self.delegate?.add(tags: addTagArray)
        // 弹出页面
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    func valueChanged(_ sender: UITextField) -> Void {
        // 改变事件
        DTLog(sender.text ?? "")
        tagString = sender.text ?? "" // 绑定tagString
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let newValue = change?[NSKeyValueChangeKey.newKey] {
            tagString = newValue as! String
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        textField.removeObserver(self, forKeyPath: "text")
    }
}

extension AddTagController: TagViewDelegate {
    func touchTag(tag: Int, title: String) {
        if !textField.isFirstResponder {
            textField.becomeFirstResponder()
        }
        guard let current = textField.text else {
            return
        }
        if current.count == 0 {
            textField.text = (current + title + ";")
        } else {
            let temp = current.trimmingCharacters(in: .whitespaces)
            let str = temp.suffix(1)
            if str == ";" {
                textField.text = (current + title + ";")
            } else {
                textField.text = (current + ";" + title + ";")
            }
        }
    }
}
