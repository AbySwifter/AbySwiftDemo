//
//  UIDevice+Extension.swift
//  AbysSwift
//
//  Created by aby on 2018/5/10.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation

extension UIDevice {
    public func isX() -> Bool {
        let size: CGSize = CGSize.init(width: 375, height: 812)
        if UIScreen.main.bounds.size.equalTo(size) {
            return true
        } else {
            return false
        }
    }
}
