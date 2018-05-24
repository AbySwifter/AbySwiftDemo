//
//  RealmManager.swift
//  AbysSwift
//
//  Created by aby on 2018/5/17.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//
 import RealmSwift

class ABYRealmManager {
    static let instance = ABYRealmManager.init()
    private init() {
        // 配置realm的config
        var config = Realm.Configuration.init()
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("KKRealm.realm") // 更改默认名称
        ABYPrint("数据库的路径为\(config.fileURL!)")
        config.schemaVersion = 9
        //数据库发生迁移的时候需要处理的事情
        config.migrationBlock = {(migration, oldSchemaVersion ) in
            // 在这里进行版本构架的迭代处理
            ABYPrint("数据库发生了迁移，旧的版本为\(oldSchemaVersion)")
        }
        Realm.Configuration.defaultConfiguration = config
    }
    // 获取数据库的对象
    lazy var realm: Realm? = {
        do {
            return try Realm()
        } catch let error as NSError {
            ABYPrint("初始化数据库出错：\(error)")
            return nil
        }
    }()
    
    /// 退出登录以后，就清空数据库
    func clearStore() -> Void {
        guard let realm = self.realm else { return }
        try? realm.write {
            realm.deleteAll() // 清空数据库
        }
    }
}

