//
//  String+qq.swift
//  AbysSwift
//
//  Created by aby on 2018/8/15.
//  Copyright © 2018 Aby.wang. All rights reserved.
//

import Foundation

extension String {

    mutating func emojiParse(emojiDic: Dictionary<String, String>) -> Void {
        for (key, value) in emojiDic {
            if self.contains(key) {
               self = self.replacingOccurrences(of: key, with: value)
            }
        }
    }
}
