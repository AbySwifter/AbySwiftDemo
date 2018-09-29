//
//  BaseVCExtension.swift
//  AbysSwift
//
//  Created by aby on 2018/6/26.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation
import DTRequest


// MARK: - VC的延展，给一个计算属性，用于网络请求
extension UIViewController {
    /// 每个vc都有一个网络管理者
    var net: DTNetworkManager {
        return DTNetworkManager.share
    }
}
