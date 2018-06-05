//
//  KKChatViewController+Notificaiton.swift
//  AbysSwift
//
//  Created by aby on 2018/5/9.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation
import SwiftyJSON

extension KKChatViewController {
    
    /// 注册通知
    func registerNotification() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(showImages(_:)), name: NSNotification.Name.init(kNoteImageCellTap), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTitle), name: Notification.Name.init(LIST_UPDATE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showArticle(_:)), name: Notification.Name.init(KNoteArticleCellTap), object: nil)
    }
    
    // 移除通知
    func removeNotification() {
        // 移除通知
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init(kNoteImageCellTap), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init(LIST_UPDATE), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init(KNoteArticleCellTap), object: nil)
    }
    
    @objc
    fileprivate func showImages(_ notification: Notification) -> Void {
        guard let dic = notification.userInfo as? [String : Any]  else {
            return
        }
        let message = dic["message"] as? Message
        if let msg = message {
            let imageVC = KKPhotoBrowserViewController()
            imageVC.imagePath = msg.content?.image ?? ""
            let viewOrigin = dic["view"] as! UIImageView
            imageVC.cc_setZoomTransition(originalView: viewOrigin)
            imageVC.cc_swipeBackDisabled = true
            self.present(imageVC, animated: true, completion: nil)
        }
    }
    
    @objc
    fileprivate func showArticle(_ notification: Notification) -> Void {
        let url = notification.object as? String
        ABYPrint("点击的URL是：\(url ?? "")")
        let articleVC = ABYWebViewController.init()
        articleVC.url = url
        self.navigationController?.pushViewController(articleVC, animated: true)
    }
    
    @objc
    fileprivate func changeTitle() -> Void {
        self.back.set(title: backTitle) // 设置标题
    }
}

extension KKChatViewController: BridgeCenterDelegate {
    func onJSONString(value: String) {
        self.sendCustomMsg(value: value)
    }
    
    fileprivate func sendCustomMsg(value: String) -> Void {
//        guard let json = JSON.init(parseJSON: value) else { return }
        if self.conversation?.room_id != nil {
            let msg = Message.init(custom: value, room_id: (self.conversation?.room_id)!)
            msg.deliver() // 投递消息，此时不需要插入会话列表，在收到消息的时候，再插入会话列表
        }
    }
}
