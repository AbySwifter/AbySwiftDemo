//
//  KKIChatImageCell.swift
//  AbysSwift
//
//  Created by aby on 2018/5/8.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit

class KKChatImageCell: KKChatBaseCell {

    override var model: Message? {
        didSet {
            setModel() // 设置视图
        }
    }
    // MARK: - 定义属性
    lazy var chatImgView: UIImageView = {
        let chatImageView = UIImageView.init()
        chatImageView.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(imgTap))
        chatImageView.addGestureRecognizer(tapGes)
        return chatImageView
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bubbleView.addSubview(chatImgView)
        chatImgView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(bubbleView)
        }
    }
    @objc private func imgTap() -> Void {
        let obj = ["message": self.model!, "view": self.chatImgView] as [String: Any]
        NotificationCenter.default.post(name: Notification.Name.init(kNoteImageCellTap), object: nil, userInfo: obj)
    }
}

extension KKChatImageCell {
    var horizenImageWidth: CGFloat {
        return self.maxMsgWidth / 2
    }
    var verticalImageWidth: CGFloat {
        return self.maxMsgWidth / 3
    }
}


extension KKChatImageCell {
    func setModel() -> Void {
        self.model?.delegate = self
        guard model?.content?.type == MSG_ELEM.image else { return }
        guard let message = self.model else { return }
        let imageSize = message.content?.size ?? ImageSize.init(width: 100, height: 150)
        let size = getPictureSize(originale: imageSize) // 获取应该显示的图片的大小
        // 这里需要先判断是否是网络图片，然后显示
        if (message.content?.image?.contains("http"))! {
            chatImgView.kf.setImage(with: URL(string: message.content?.image ?? ""))
        } else {
            chatImgView.kf.setImage(with: URL(fileURLWithPath: message.content?.image ?? ""))
        }
        // 头像的通用样式
        avatar.snp.remakeConstraints { (make) in
            make.width.height.equalTo(self.avatarWidth)
            make.top.equalTo(self.snp.top).offset(verticalMargin)
        }
        // 发送者姓名
        senderName.snp.remakeConstraints { (make) in
            make.top.equalTo(msgContent.snp.top)
        }
        // 对bubblew的重新布局
        bubbleView.snp.remakeConstraints { (make) in
            make.top.equalTo(senderName.snp.bottom).offset(n_cOffset)
            make.bottom.equalToSuperview().offset(-10)
            make.size.equalTo(size)
        }
//        chatImgView.snp.remakeConstraints { (make) in
//            make.top.left.bottom.right.equalTo(bubbleView)
//        }
        // 发送结果的通用样式
        tipView.snp.remakeConstraints { (make) in
            make.centerY.equalTo(bubbleView.snp.centerY)
            make.width.height.equalTo(30)
        }
        // 消息内容的通用样式
        msgContent.snp.remakeConstraints { (make) in
            make.top.equalTo(avatar.snp.top)
            make.width.equalToSuperview().offset(-avatarTotalWidth)
            make.bottom.equalTo(bubbleView.snp.bottom).offset(10)
        }
        if message.isSelf {
            avatar.snp.makeConstraints { (make) in
                make.right.equalTo(self.snp.right).offset(-self.avatarMargin)
            }
            senderName.snp.makeConstraints { (make) in
                make.right.equalToSuperview()
            }
            bubbleView.snp.makeConstraints { (make) in
                make.right.equalToSuperview()
            }
            tipView.snp.makeConstraints { (make) in
                make.right.equalTo(bubbleView.snp.left)
            }
            msgContent.snp.makeConstraints { (make) in
                make.right.equalTo(avatar.snp.left).offset(-self.avatarToMsg)
            }
        } else {
            avatar.snp.makeConstraints { (make) in
                make.left.equalTo(self.snp.left).offset(self.avatarMargin)
            }
            senderName.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
            }
            bubbleView.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
            }
            msgContent.snp.makeConstraints { (make) in
                make.left.equalTo(avatar.snp.right).offset(self.avatarToMsg)
            }
        }
        self.layoutSubviews()
        self.model?.cellHeight = getCellHeight()
        // 绘制 imageView的bubble layer
        let stretchInset = UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)
        let strecchImage =  message.isSelf ? #imageLiteral(resourceName: "mebubble") : #imageLiteral(resourceName: "friendbubble")
        self.chatImgView.clipShape(stretchImage: strecchImage, stretchInsets: stretchInset)
        
        // 绘制coreImage 盖住图片
//        let bubbleCoverIamge = strecchImage.resizableImage(withCapInsets: stretchInset, resizingMode: .stretch)
//        bubbleView.image = bubbleCoverIamge
    }
    
    // 处理图片的尺寸
    func getPictureSize(originale: ImageSize) -> CGSize {
        var size: CGSize = CGSize(width: 100, height: 100) // 默认宽高
        let ratio = (originale.height ?? 0) / (originale.width ?? 1)
        if (originale.width ?? 0) >= (originale.height ?? 0) {
            // 横向图片
            size.width = self.horizenImageWidth
            size.height = self.horizenImageWidth * ratio
        } else {
            // 纵向图片
            size.width = self.verticalImageWidth
            size.height = self.verticalImageWidth * ratio
        }
        return size
    }
}
