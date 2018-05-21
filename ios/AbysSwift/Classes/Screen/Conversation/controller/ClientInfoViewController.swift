//
//  ClientInfoViewController.swift
//  AbysSwift
//
//  Created by aby on 2018/5/11.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import HandyJSON

class ClientInfoViewController: ABYBaseViewController {
    var room_id: Int16?
    var dataSource: Array = [
        (#imageLiteral(resourceName: "sex"), "性别：", ""),
        (#imageLiteral(resourceName: "address"), "地点：", ""),
        (#imageLiteral(resourceName: "device"), "终端：", ""),
        (#imageLiteral(resourceName: "source"), "来源：", "")
    ]
    var info: ClientInfo? {
        didSet {
           setInfo()
        }
    }
    var remarkHeight: CGFloat = W750(50)
    var footerHeight: CGFloat {
        return remarkHeight + W750(59)
    }
    // 备注的输入栏
    lazy var remark: UITextView = {
        let textView = UITextView.init()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = UIColor.init(hexString: "666666")
        textView.backgroundColor = UIColor.init(hexString: "f5f5f5")
        textView.delegate = self
        textView.contentInsetAdjustmentBehavior = .never
        textView.bounces = false
        textView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        textView.isEditable = false
        return textView
    }()
    
    // 整个页面的Tab
    lazy var tabview: UITableView = {
        let tab = UITableView.init(frame: self.view.bounds, style: .plain)
        tab.delegate = self
        tab.dataSource = self
        tab.contentInsetAdjustmentBehavior = .never
        
        // 注册cell
        tab.tableHeaderView = headView
        tab.separatorStyle = .none
        tab.rowHeight = W750(107)
        tab.bounces = false
        tab.backgroundColor = UIColor.init(hexString: "f5f5f5")
        tab.register(ClientInfoCell.classForCoder(), forCellReuseIdentifier: "ClientInfoCell")
        return tab
    }()
    
    private lazy var headView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.width, height: self.view.height / 3))
        view.backgroundColor = ABYGlobalThemeColor()
        view.addSubview(avatar)
        avatar.snp.makeConstraints({ (make) in
            make.centerX.equalTo(view)
            make.height.width.equalTo(W750(150))
            make.bottom.equalTo(view.snp.bottom).offset(-W750(120))
        })
        view.addSubview(name)
        name.snp.makeConstraints({ (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view.snp.bottom).offset(-W750(40))
        })
        return view
    }()
    
    lazy var footerView: UIView = {
        let view = initFooterView()
        return view
    }()
    
    lazy var avatar: UIImageView = {
        let imageView = UIImageView.init()
        imageView.backgroundColor = UIColor.gray
        imageView.layer.cornerRadius = W750(75)
        return imageView
    }()
    
    lazy var name: UILabel = {
        let name: UILabel = UILabel.init()
        name.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        name.textColor = UIColor.white
        name.text = "用户名"
        return name
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.title = "客户信息"
        addNotification()
        // Do any additional setup after loading the view.
        view.addSubview(tabview)
        getCustomerInfo() // 获取用户信息
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarTranslucent()
    }
    func initFooterView() -> UIView {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(hexString: "f5f5f5")
        let imageView = UIImageView.init()
        imageView.image = #imageLiteral(resourceName: "remark")
        imageView.contentMode = .left
        let label = UILabel.init()
        label.text = "备注："
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.init(hexString: "666666")
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).offset(W750(28))
            make.left.equalTo(view.snp.left).offset(15)
            make.height.equalTo(W750(50))
            make.width.equalTo(W750(90))
        }
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(imageView)
            make.left.equalTo(imageView.snp.right)
            make.height.equalTo(imageView)
        }
        label.sizeToFit()
        let button = UIButton.init(type: .custom)
        button.setImage(#imageLiteral(resourceName: "edit_remark"), for: .normal)
        button.addTarget(self, action: #selector(remarkAction(sender:)), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.top.equalTo(imageView)
            make.right.equalTo(view.snp.right).offset(-15)
            make.height.equalTo(imageView.snp.height)
            make.width.equalTo(W750(50))
        }
        view.addSubview(remark)
        remark.snp.makeConstraints { (make) in
            make.top.equalTo(imageView)
            make.left.equalTo(label.snp.right)
            make.right.equalTo(button.snp.left)
            make.bottom.equalTo(view.snp.bottom).offset(-W750(27))
        }
        let separator = UIView.init()
        separator.backgroundColor = UIColor.init(hexString: "cccccc")
        view.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.height.equalTo(1/UIScreen.main.scale)
            make.left.equalTo(view.snp.left).offset(15)
            make.right.equalTo(view.snp.right).offset(-15)
            make.bottom.equalTo(view.snp.bottom)
        }
        return view
    }
}

extension ClientInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientInfoCell") as! ClientInfoCell
        let data = dataSource[indexPath.row]
        cell.setWidth(data: data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.footerHeight
    }
}

// MARK: - 网络请求的方法
extension ClientInfoViewController {
    // 查看客户信息，这里的客户信息就是房间的id
    func getCustomerInfo() -> Void {
        guard let room_id = self.room_id else { return }
        self.showLoading()
        self.networkManager.aby_request(request: UserRouter.request(api: .getCustomerInfo, params: ["customer_id": "\(room_id)"])) { (json) -> (Void) in
            guard let res = json else { return }
            ABYPrint("\(res)")
            guard let dic = res["data"].dictionaryObject else { return }
            self.info = ClientInfo.deserialize(from: dic)
            self.hideLoading()
        }
    }
    
    func setInfo() -> Void {
        guard let info = self.info else {
            return
        }
        let url = URL.init(string: info.avatar ?? "")
        self.avatar.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "user"), options: nil, progressBlock: nil, completionHandler: nil)
        UIGraphicsBeginImageContextWithOptions(self.avatar.bounds.size, false, UIScreen.main.scale)
        let path = UIBezierPath.init(roundedRect: self.avatar.bounds, cornerRadius: self.avatar.bounds.width / 2)
        path.addClip()
        self.avatar.draw(self.avatar.bounds)
        self.avatar.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.name.text = info.nickname ?? ""
        self.dataSource[0].2 = info.sex ?? "未知"
        self.dataSource[1].2 = info.address ?? "保密"
        self.dataSource[2].2 = "unknown"
        self.dataSource[3].2 = info.source ?? "未知"
        self.remark.text = info.remark ?? ""
        self.tabview.reloadData()
    }
    
}

// MARK: -UITextViewDelegate, notification
extension ClientInfoViewController: UITextViewDelegate {
    
    func addNotification() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        var height = textView.sizeThatFits(CGSize.init(width: textView.width, height: CGFloat.greatestFiniteMagnitude)).height
        // 根据高度去改变视图的大小
        height = height > W750(50) ? height : W750(50)
        height = height < W750(200) ? height : W750(200)
        if height != remarkHeight {
            remarkHeight = height
            self.tabview.beginUpdates()
            self.tabview.reloadData()
            self.tabview.endUpdates()
        }
    }
    
    @objc
    func keyboardWillShow(notification: Notification) {
        guard let kbInfo = notification.userInfo else {
            return
        }
        //        let duration = kbInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let keyboardHeight = (kbInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect?)?.height ?? 0
        var frame = self.view.bounds
        frame.size.height = frame.height - keyboardHeight
        self.tabview.frame = frame
    }
    
    @objc
    func keyboardWillHide(notification: Notification) {
        self.tabview.frame = self.view.bounds
        self.tabview.layoutIfNeeded()
    }
    
    @objc
    func remarkAction(sender: UIButton) -> Void {
        if remark.isEditable {
            remark.resignFirstResponder()
            // 在这里提交备注
            updateRemark()
            remark.isEditable = false
        } else {
            remark.isEditable = true
            remark.becomeFirstResponder()
        }
    }
    
    func updateRemark() {
        guard let room_id = self.room_id else {
            return
        }
        let params: [String: Any] = [
            "customer_id": "\(room_id)",
            "remark": "\(remark.text ?? "")"
        ]
        showLoading()
        self.networkManager.aby_request(request: UserRouter.request(api: UserAPI.updateCustomRemark, params: params)) { (json) -> (Void) in
            self.hideLoading()
            if json != nil {
                self.showToast("修改备注成功")
            } else {
                self.showToast("修改备注失败")
            }
        }

    }
}

struct ClientInfo: HandyJSON {
    var commpany_id: Int?
    var source: String?
    var update_at: String?
    var wechat_id: Int?
    var address: String?
    var nickname: String?
    var unionid: String?
    var id: Int?
    var openid: String?
    var created_at: String?
    var avatar: String?
    var remark: String?
    var sex: String?
}
