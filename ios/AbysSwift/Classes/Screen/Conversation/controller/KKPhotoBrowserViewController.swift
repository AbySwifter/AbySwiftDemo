//
//  KKPhotoBrowserViewController.swift
//  AbysSwift
//
//  Created by aby on 2018/5/9.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit

class KKPhotoBrowserViewController: ABYBaseViewController {

    // MARK: 定义属性
    lazy var imageView: UIImageView = {
        let imageV: UIImageView = UIImageView.init(frame: self.view.bounds)
        imageV.isUserInteractionEnabled = true
        imageV.contentMode = .scaleAspectFit
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(dismissSelf))
        imageV.addGestureRecognizer(tap)
        self.view.addSubview(imageV)
        return imageV
    }()
    var imagePath: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        showImage()
        // Do any additional setup after loading the view.
    }
    
    func showImage() {
        var url: URL!
        if self.imagePath.contains("http") {
            url = URL.init(string: self.imagePath)
        } else {
            url = URL.init(fileURLWithPath: self.imagePath)
        }
        self.imageView.kf.setImage(with: url)
    }
    
    @objc func dismissSelf() {
        self.dismiss(animated: true) {
            
        }
    }
}
