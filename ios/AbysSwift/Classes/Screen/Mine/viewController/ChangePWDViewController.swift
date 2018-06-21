//
//  ChangePWDViewController.swift
//  AbysSwift
//
//  Created by aby on 2018/5/16.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit

class ChangePWDViewController: ABYBaseViewController {

    lazy var oldPassword: UITextField = {
        let textFiled = UITextField.init()
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: W750(40), height: W750(40)))
        imageView.image = #imageLiteral(resourceName: "old_password")
        imageView.contentMode = .scaleAspectFit
        let view = UIView.init(frame:CGRect.init(x: 0, y: 0, width: W750(80), height: W750(40)))
        view.addSubview(imageView)
        textFiled.leftView = view
        textFiled.placeholder = "原密码"
        textFiled.leftViewMode = .always
        textFiled.isSecureTextEntry = true
        textFiled.font = UIFont.systemFont(ofSize: 16)
        return textFiled
    }()
    
    lazy var newPassword: UITextField = {
        let textFiled = UITextField.init()
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: W750(40), height: W750(40)))
        imageView.image = #imageLiteral(resourceName: "change_password")
        imageView.contentMode = .scaleAspectFit
        let view = UIView.init(frame:CGRect.init(x: 0, y: 0, width: W750(80), height: W750(40)))
        view.addSubview(imageView)
        textFiled.leftView = view
        textFiled.placeholder = "新密码"
        textFiled.leftViewMode = .always
        textFiled.isSecureTextEntry = true
        textFiled.font = UIFont.systemFont(ofSize: 16)
        return textFiled
    }()
    
    lazy var surePassword: UITextField = {
        let textFiled = UITextField.init()
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: W750(40), height: W750(40)))
        let view = UIView.init(frame:CGRect.init(x: 0, y: 0, width: W750(80), height: W750(40)))
        imageView.image = #imageLiteral(resourceName: "confirm_password")
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        textFiled.leftView = view
        textFiled.placeholder = "确认密码"
        textFiled.leftViewMode = .always
        textFiled.isSecureTextEntry = true
        textFiled.font = UIFont.systemFont(ofSize: 16)
        return textFiled
    }()
    
    lazy var sureBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.backgroundColor = ABYGlobalThemeColor()
        button.setTitle("确认", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(sureAction(_:)), for: .touchUpInside)
        return button
    }()
    
    var hasEmpty: Bool {
        if oldPassword.text == nil || oldPassword.text == "" {
            return true
        }
        if newPassword.text == nil || newPassword.text == "" {
            return true
        }
        if surePassword.text == nil || surePassword.text == "" {
            return true
        }
        return false
    }
    var isEqualOld: Bool {
        if oldPassword.text == newPassword.text {
            return true
        } else {
            return false
        }
    }
    var isEqualNAO: Bool {
        return newPassword.text == surePassword.text
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.clipsToBounds = false
    }
    
    @objc
    func sureAction(_ sender: UIButton) -> Void {
        guard !self.hasEmpty else {
            showToast("不可以有空项目哦~~~")
            return
        }
        guard self.isEqualNAO else {
            showToast("两次输入不一致~~~")
            return
        }
        guard !self.isEqualOld else {
            showToast("不可以与旧密码一致")
            return
        }
        let params: [String: Any] = [
            "current_password": oldPassword.text!,
            "new_password": newPassword.text!
        ]
        self.networkManager.aby_request(request: UserRouter.request(api: UserAPI.changePassword, params: params)) { (json) -> (Void) in
            if let res = json {
                ABYPrint("修改密码的结果\(res)")
                self.showToast("修改密码成功")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                self.showToast("修改密码失败")
            }
        }
    }
}

extension ChangePWDViewController {
    fileprivate func createSeparator(topView: UIView, superView: UIView) -> Void {
        let view = UIView.init()
        superView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.width.equalTo(topView).offset(-W750(80))
            make.height.equalTo(1/UIScreen.main.scale)
            make.right.equalTo(topView.snp.right)
        }
        view.backgroundColor = ABYGlobalBorderColor()
    }
    
    fileprivate func createUI() -> Void {
        view.addSubview(oldPassword)
        oldPassword.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(W750(80))
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(W750(60))
        }
        createSeparator(topView: oldPassword, superView: view)
        view.addSubview(newPassword)
        newPassword.snp.makeConstraints { (make) in
            make.top.equalTo(oldPassword.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(W750(60))
        }
        createSeparator(topView: newPassword, superView: view)
        view.addSubview(surePassword)
        surePassword.snp.makeConstraints { (make) in
            make.top.equalTo(newPassword.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(W750(60))
        }
        createSeparator(topView: surePassword, superView: view)
        view.addSubview(sureBtn)
        sureBtn.snp.makeConstraints { (make) in
            make.top.equalTo(surePassword.snp.bottom).offset(W750(90))
            make.left.equalTo(view.snp.left).offset(15)
            make.right.equalTo(view.snp.right).offset(-15)
            make.height.equalTo(W750(93))
        }
    }
}
