//
//  ArticlItem.swift
//  AbysSwift
//
//  Created by aby on 2018/5/29.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import HandyJSON

class ArticlItem: HandyJSON {
    var description: String?
    var title: String?
    var image: String?
    var url: String?
    required init() {}
    
    convenience init(object: ArticlItemObject) {
        self.init()
        self.description = object.descriptionTitle
        self.title = object.title
        self.image = object.image
        self.url = object.url
    }
    
    func toObject() -> ArticlItemObject {
        let obj = ArticlItemObject.init()
        obj.descriptionTitle = self.description
        obj.image = self.image
        obj.title = self.title
        obj.url = self.url ?? newGUID() // url不能为空
        return obj
    }
}
