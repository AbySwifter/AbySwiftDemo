//
//  BaseVCExtension.swift
//  AbysSwift
//
//  Created by aby on 2018/6/26.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import Foundation
import DTRequest


// MARK: - 基类的延展
extension ABYBaseViewController {
    var net: DTNetworkManager {
        return DTNetworkManager.share
    }
}
