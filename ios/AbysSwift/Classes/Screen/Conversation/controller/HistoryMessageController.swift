//
//  HistoryMessageController.swift
//  AbysSwift
//
//  Created by aby on 2018/5/15.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import MJRefresh

class HistoryMessageController: ABYBaseViewController {
    
    var page: Int = 1
    var end: Bool {
        return self.page * 10 >= self.totalCount
    }
    var room_id: Int16 = 0
    var totalCount: Int = -1
    var conversation: Conversation?
    /// 消息控制器
    lazy var messageVC: KKMessageViewController = {
        let messageVC = KKMessageViewController()
        messageVC.isChatView = false
        messageVC.loadMoreAction = {
            self.getHistoryList()
        }
        messageVC.setTable()
        self.view.addSubview(messageVC.view)
        messageVC.view.snp.makeConstraints({ (make) in
            make.left.right.top.bottom.equalTo(self.view)
        })
        messageVC.conversation = self.conversation
        messageVC.showBot = true
        return messageVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // FIXME: 添加等待的loading
        self.showLoading()
        getHistoryList() // 加载历史消息
    }
}

extension HistoryMessageController {
    /// 分页加载历史记录
    func getHistoryList() -> Void {
        guard !self.end || self.totalCount == -1 else {
            messageVC.chatListView.mj_header.state = .noMoreData
            return
        }
        let params: [String: Any] = [
            "room_id": self.room_id,
            "order": "desc",
            "page" : self.page,
            "page_size": 10,
            "current_id": Account.share.current_id,
        ]
        self.net.dt_request(request: DTRequest.request(api: Api.historyList, params: params)) { (error, json) -> (Void) in
            if let res = json {
                self.totalCount = res["data"]["message_count"].int ?? 0
                guard let tempList = res["data"]["message_list"].arrayObject else { return }
                guard let msgList = [Message].deserialize(from: tempList) else { return }
                if self.page == 1 {
                    
                    self.messageVC.setMessage(list: msgList as! [Message])
                } else {
                    self.messageVC.addMessageRemote(list: msgList as! [Message])
                }
                self.page += 1
            }
            if self.page == 1 {
                self.hideLoading()
            }
            self.messageVC.chatListView.mj_header.endRefreshing()
        }
    }
}

extension KKMessageViewController: ABYEmptyDataSetable {
    
    /// 设置空视图的方法
    fileprivate func setTable() {
        aby_EmptyDataSet(chatListView) { () -> ([ABYEmptyDataSetAttributeKeyType : Any]) in
            return [
                .tipStr:"没有历史消息",
                .verticalOffset: -150,
                .allowScroll: false,
                .tipColor: UIColor.init(hexString: "666666")
            ]
        }
    }
}

