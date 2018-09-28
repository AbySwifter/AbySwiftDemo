//
//  NotificationViewController.swift
//  AbysSwift
//
//
//  Created by aby on 2018/6/19.
//Copyright © 2018年 Aby.wang. All rights reserved.
//
// @class NotificationViewController
// @abstract 提醒设置页面
// @discussion 提醒设置提示
//

import UIKit
import UserNotifications

/// 通知设置页面
class NotificationViewController: UIViewController {

    lazy var cover: UIImageView = {
        let coverView = UIImageView.init()
        coverView.image = #imageLiteral(resourceName: "notification_ios")
        coverView.contentMode = UIView.ContentMode.scaleAspectFit
        return coverView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = UIColor.init(hexString: "666666")
        label.textAlignment = .center
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let content = UILabel.init()
        content.lineBreakMode = NSLineBreakMode.byWordWrapping
        content.numberOfLines = 0
        content.textAlignment = .center
        content.font = UIFont.systemFont(ofSize: 14.0)
        content.textColor = UIColor.hexInt(0xA9A9A9)
        return content
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(cover)
        cover.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(W375(130))
            make.width.equalTo(W375(96))
            make.height.equalTo(W375(81))
        }
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(cover.snp.bottom).offset(41)
        }
        view.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.width.lessThanOrEqualTo(self.view.width * 3 / 4)
        }
        // Do any additional setup after loading the view.
        // FIXME: 临时的代码
        titleLabel.text = "已打开通知"
        contentLabel.text = "您已经打开消息提醒，如果想关闭消息提醒，需要在 设置-通知 中手动设置"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkNotification() -> Void {
        UNUserNotificationCenter.current().getNotificationSettings { (setting) in
            DispatchQueue.main.async(execute: {
                if setting.authorizationStatus == .authorized {
                    // 打开了通知
                } else {
                    // 没有打开通知
                }
            })
        }
    }
}
