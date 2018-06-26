//
//  ChatVoiceView.swift
//  AbysSwift
//
//  Created by aby on 2018/5/2.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import ImageIO

class KKChatVoiceView: UIView {
    /// 中心视图
    private lazy var centerView: UIView = {
        let centerV = UIView()
        centerV.backgroundColor = UIColor.init(r: 0, g: 0, b: 0, a: 0.5) // 黑色遮罩
        centerV.layer.cornerRadius = 10.0
        return centerV
    }()
    /// 提示信息
    private lazy var noteLabel: UILabel = {
        let noteL = UILabel.init()
        noteL.text = "松开手指，取消发送"
        noteL.font = UIFont.systemFont(ofSize: 14.0)
        noteL.textColor = UIColor.white
        noteL.textAlignment = .center
        noteL.layer.cornerRadius = 2
        noteL.layer.masksToBounds = true
        return noteL
    }()
    /// 取消录音的视图
    private lazy var cancelImgView: UIImageView = {
        let cancelImgV = UIImageView.init(image: #imageLiteral(resourceName: "RecordCancel"))
        return cancelImgV
    }()
    /// 录音时间太短的视图
    private lazy var tooShortImgView: UIImageView = {
        let tooShootImgV = UIImageView.init(image: #imageLiteral(resourceName: "MessageTooShort"))
        return tooShootImgV
    }()
    /// 录音的视图
    lazy var recordingView: UIImageView = {
        let recordingV = UIImageView.init()
        recordingV.contentMode = .scaleAspectFit
        let result = getAnimationImages()
        recordingV.animationImages = result.0
        recordingV.animationDuration = result.1
        recordingV.animationRepeatCount = 0
//        recordingV.startAnimating()
        return recordingV
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup() // 初始化执行的方法
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // 获取播放的gif图（简单播放）
    fileprivate func getAnimationImages() -> ([UIImage], Double) {
        var images = [UIImage]()
        var gifDuration = 0.0
        guard let path = Bundle.main.path(forResource: "recording", ofType: "gif") else {
            return (images, gifDuration)
        }
        guard let data = NSData.init(contentsOfFile: path) else { return (images, gifDuration) }
        guard let imageSource = CGImageSourceCreateWithData(data, nil) else { return (images, gifDuration) }
        let imageCount = CGImageSourceGetCount(imageSource)
        
        for i in 0..<imageCount {
            guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, nil) else { return (images, gifDuration) }
            let image = UIImage.init(cgImage: imageRef, scale: UIScreen.main.scale, orientation: .up)
            guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) else {return (images, gifDuration)}
            guard let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary else { return (images, gifDuration) }
            guard let frameDuration = (gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber) else { return (images, gifDuration) }
            gifDuration += frameDuration.doubleValue
            images.append(image)
        }
        return (images, gifDuration)
    }
}

extension KKChatVoiceView {
    /// 初始化
    private func setup() -> Void {
        self.addSubview(centerView)
        centerView.addSubview(noteLabel)
        centerView.addSubview(tooShortImgView)
        centerView.addSubview(cancelImgView)
        centerView.addSubview(recordingView)
        // 布局
        centerView.snp.makeConstraints { (make) in
            make.width.height.equalTo(150) // 在375的设计图上是150的宽度
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY).offset(-30)
        }
        noteLabel.snp.makeConstraints { (make) in
            make.left.equalTo(centerView.snp.left).offset(8)
            make.right.equalTo(centerView.snp.right).offset(-8)
            make.top.equalTo(recordingView.snp.bottom).offset(15)
            make.height.equalTo(20)
        }
        recordingView.snp.makeConstraints { (make) in
            make.width.height.equalTo(100)
            make.centerX.equalTo(centerView.snp.centerX)
            make.top.equalTo(centerView.snp.top)
        }
        tooShortImgView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(recordingView)
        }
        cancelImgView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(recordingView)
        }
    }
}

extension KKChatVoiceView {
    
    /// 录音中
    func recording() -> Void {
        self.isHidden = false
        self.tooShortImgView.isHidden = true
        self.recordingView.isHidden = false
        self.cancelImgView.isHidden = true
        self.noteLabel.backgroundColor = UIColor.clear
        self.noteLabel.text = "手指上滑，取消发送"
        self.recordingView.startAnimating()
    }

    /// 上滑取消
    func slideToCancelRecord() -> Void {
        self.isHidden = false
        self.tooShortImgView.isHidden = true
        self.recordingView.isHidden = true
        self.cancelImgView.isHidden = false
        self.noteLabel.backgroundColor = UIColor.clear
        self.noteLabel.text = "松开手指，取消发送"
        self.recordingView.stopAnimating()
    }
    
    /// 录音时间太短
    func messageTooShort() {
        self.isHidden = false
        self.tooShortImgView.isHidden = false
        self.recordingView.isHidden = true
        self.cancelImgView.isHidden = true
        self.noteLabel.text = "说话时间太短"
        // 0.5秒后消失
        let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) /  Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.endRecord()
        }
    }
    
    /// 结束录音
    func endRecord() -> Void {
        self.isHidden = true
    }
}
