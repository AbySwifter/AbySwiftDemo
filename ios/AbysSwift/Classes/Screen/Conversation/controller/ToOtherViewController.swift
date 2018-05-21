//
//  ToOtherViewController.swift
//  AbysSwift
//
//  Created by aby on 2018/5/15.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import HandyJSON
import MJRefresh

class ToOtherViewController: ABYBaseViewController {

    var room_id: Int?
    
    lazy var tableView: UITableView = {
        let tab = UITableView.init(frame: self.view.bounds)
        view.addSubview(tab)
        tab.delegate = self
        tab.dataSource = self
        tab.separatorStyle = .none
        tab.rowHeight = W750(170)
        tab.register(OtherInfoCell.classForCoder(), forCellReuseIdentifier: "OtherInfoCell")
        let header: MJRefreshNormalHeader = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(getOtherList))
        header.lastUpdatedTimeLabel.isHidden = true // 隐藏时间
        header.setTitle("下拉刷新", for: MJRefreshState.idle)
        header.setTitle("松开刷新", for: .pulling)
        header.setTitle("加载中...", for: .refreshing)
        header.setTitle("没有新的内容", for: .noMoreData)
        tab.mj_header = header
        return tab
    }()
    
    var list: [OtherInfo?] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setTable()
        getOtherList()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setThemeNavigationBar()
        self.navigationItem.title = "客服列表"
    }
    
    @objc
    func getOtherList() -> Void {
        let params = [
            "current_id": Account.share.current_id,
        ]
        self.showLoading()
        self.networkManager.aby_request(request: UserRouter.request(api: UserAPI.switchServiceList, params: params)) { (json) -> (Void) in
            self.hideLoading()
            if let res = json {
                if let array = res["data"]["online_services"].arrayObject {
                    self.list = [OtherInfo].deserialize(from: array) ?? []
                    self.tableView.reloadData() // 更新视图
                }
            }
        }
    }
    
    func toOther(otherID: Int) -> Void {
        let current_id = Account.share.current_id
        let session_id = Account.share.session_id
        let switch_id = String(otherID)
        let room_id = String(self.room_id ?? 0)
        let params: [String: Any] = [
            "current_id": current_id,
            "session_id": session_id,
            "switch_id": switch_id,
            "room_id": room_id
        ]
        self.networkManager.aby_request(request: UserRouter.request(api: UserAPI.switchService, params: params)) { (json) -> (Void) in
            if let res = json {
                if res["state"].intValue == 200 {
                    self.showToast("转接客服成功")
                    ConversationManager.distance.removeConversation(room_id: Int16(self.room_id ?? 0))
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                }
            } else {
                self.showToast("转接客服出错")
            }
        }
    }
}

// MARK: -tableView的代理
extension ToOtherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OtherInfoCell") as! OtherInfoCell
        if let model = list[indexPath.row] {
            cell.setCellWith(model: model)
        }
        cell.click = { (otherID: Int) -> Void in
            self.toOther(otherID: otherID)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
}

extension ToOtherViewController: ABYEmptyDataSetable {
    /// 设置空视图的方法
    fileprivate func setTable() {
        aby_EmptyDataSet(tableView) { () -> ([ABYEmptyDataSetAttributeKeyType : Any]) in
            return [
                .tipStr:"暂时没有其他在线客服...",
                .verticalOffset: -150,
                .allowScroll: false
            ]
        }
        
        aby_tapEmptyView(tableView) { (view) in
            ABYPrint("点击了空视图")
            self.getOtherList()
        }
    }
}

struct OtherInfo: HandyJSON {
    var id: Int?
    var avatar: String?
    var name: String?
}
