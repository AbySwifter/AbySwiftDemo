//
//  KKChatViewController+Notificaiton.swift
//  AbysSwift
//
//  Created by aby on 2018/5/9.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation

extension KKChatViewController {
    
    /// 注册通知
    func registerNotification() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(showImages(_:)), name: NSNotification.Name.init(kNoteImageCellTap), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTitle), name: Notification.Name.init(LIST_UPDATE), object: nil)
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
    fileprivate func changeTitle() -> Void {
        self.back.set(title: backTitle) // 设置标题
    }
}
