//
//  ClientInfoViewController.swift
//  AbysSwift
//
//  Created by aby on 2018/5/11.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import HandyJSON
import DTTools

class ClientInfoViewController: ABYBaseViewController {
    var room_id: Int16?
    var dataSource: Array = [
        (#imageLiteral(resourceName: "sex"), "性别：", ""),
        (#imageLiteral(resourceName: "address"), "地点：", ""),
        (#imageLiteral(resourceName: "device"), "终端：", ""),
        (#imageLiteral(resourceName: "source"), "来源：", "")
    ]
    var tags: [String] = ["女性消费者", "土豪", "穷游", "喜爱美食", "关心价格", "不介意价格"]
    var info: ClientInfo? {
        didSet {
           setInfo()
        }
    }
    var footerHeight: CGFloat {
        return tagView.totalHeight > W750(45) ? tagView.totalHeight + W375(10) : W750(45)
    }
   
    // 整个页面的Tab
    lazy var tabview: UITableView = {
        let tab = UITableView.init(frame: self.view.bounds, style: .plain)
        tab.delegate = self
        tab.dataSource = self
        tab.contentInsetAdjustmentBehavior = .never
        
        // 注册cell
        tab.tableHeaderView = headView
        tab.separatorStyle = .none
        tab.rowHeight = W375(50)
        tab.bounces = false
        tab.backgroundColor = UIColor.init(hexString: "ffffff")
        tab.register(ClientInfoCell.classForCoder(), forCellReuseIdentifier: "ClientInfoCell")
        return tab
    }()
   
    /// 返回用户信息的头部视图
    private lazy var headView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.width, height: W375(105)))
        view.backgroundColor = UIColor.white // 背景为白色
        view.addSubview(avatar)
        avatar.snp.makeConstraints({ (make) in
            make.left.equalTo(view.snp.left).offset(20)
            make.height.width.equalTo(W375(70))
            make.centerY.equalTo(view.snp.centerY)
        })
        view.addSubview(name)
        name.snp.makeConstraints({ (make) in
            make.centerY.equalTo(view)
            make.left.equalTo(avatar.snp.right).offset(W375(20))
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
        name.font = UIFont.systemFont(ofSize: 22)
        name.textColor = UIColor.init(hexString: "333333")
        name.text = "用户名"
        return name
    }()
    
    lazy var tagView: TagView = {
        let maxW = self.view.width - label.width - 40 - W375(40)
        let tagView = TagView.init(tags: tags, maxRowW: maxW, rowH: W375(45), marginX: W375(20))
        tagView.delegate = self
        return tagView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel.init()
        label.text = "备注："
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.init(hexString: "333333")
        label.sizeToFit()
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.title = "客户信息"
        // Do any additional setup after loading the view.
        view.addSubview(tabview)
        getCustomerInfo() // 获取用户信息
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.setNavigationBarTranslucent()
        self.setThemeNavigationBar()
    }
    func initFooterView() -> UIView {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(hexString: "ffffff")
        let imageView = UIImageView.init()
        imageView.image = #imageLiteral(resourceName: "remark")
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).offset(W375(15))
            make.left.equalTo(view.snp.left).offset(20)
            make.height.equalTo(W375(20))
            make.width.equalTo(W375(20))
        }
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerY.equalTo(imageView)
            make.left.equalTo(imageView.snp.right).offset(W375(20))
        }
        view.addSubview(tagView)
        tagView.snp.makeConstraints { (make) in
            make.left.equalTo(label.snp.right)
            make.top.equalTo(imageView.snp.top).offset(-12.5)
            make.width.equalTo(tagView.maxRowWidth)
            make.height.equalTo(tagView.totalHeight)
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
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView.init()
//        return view
//    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 44
//    }
    
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
        self.net.dt_request(request: DTRequest.request(api: Api.getCustomerInfo, params: ["customer_id": "\(room_id)"])) { (error, json) -> (Void) in
            guard let res = json else { return }
            DTLog("\(res)")
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
        self.tabview.reloadData()
    }
    
}

// MARK: -UITextViewDelegate, notification
extension ClientInfoViewController {
    
    @objc
    func remarkAction(sender: UIButton) -> Void {
//        if remark.isEditable {
//            remark.resignFirstResponder()
//            // 在这里提交备注
//            updateRemark()
//            remark.isEditable = false
//        } else {
//            remark.isEditable = true
//            remark.becomeFirstResponder()
//        }
    }
    
    func updateRemark() {
//        guard let room_id = self.room_id else {
//            return
//        }
//        let params: [String: Any] = [
////            "customer_id": "\(room_id)",
////            "remark": "\(remark.text ?? "")"
//        ]
//        showLoading()
//        self.networkManager.aby_request(request: UserRouter.request(api: UserAPI.updateCustomRemark, params: params)) { (json) -> (Void) in
//            self.hideLoading()
//            if json != nil {
//                self.showToast("修改备注成功")
//            } else {
//                self.showToast("修改备注失败")
//            }
//        }
    }
}

extension ClientInfoViewController: TagViewDelegate {
    func touchTagClose(tag: Int, title: String) {
        DTLog("点击了关闭按钮\(title)")
        tags.remove(at: tag)
        tagView.tags = tags
        tagView.updataTag()
    }
    
    func touchTagAdd(tag: Int) {
        /// 打开添加标签的页面
        let addVC = AddTagController()
        addVC.delegate = self
        self.navigationController?.pushViewController(addVC, animated: true)
    }
}

extension ClientInfoViewController: AddTagControllerdelegate {
    func add(tags: [String]) {
        // 实现添加的代码
        tagView.tags += tags
        tagView.updataTag()
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
