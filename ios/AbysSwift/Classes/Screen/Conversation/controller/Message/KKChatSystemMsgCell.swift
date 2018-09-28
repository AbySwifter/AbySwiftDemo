//
/**
* 好看的皮囊千篇一律，有趣的灵魂万里挑一
* 创建者: 王勇旭 于 2018/4/28
* Copyright © 2018年 Aby.wang. All rights reserved.
* 
*/

import UIKit

class KKChatSystemMsgCell: KKChatBaseCell {

	override var model: Message? {
		didSet {
			setModel()
		}
	}

	lazy var contentLable: UILabel = {
		let label = UILabel.init()
		label.font = UIFont.systemFont(ofSize: 12.0)
		label.textColor = UIColor.init(hexString: "8c8c8c")
		return label
	}()

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.timeContent.isHidden = true
        self.msgContent.isHidden = true
        self.addSubview(contentLable)
        contentLable.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(60)
            make.right.equalToSuperview().offset(-60)
        }
        contentLable.numberOfLines = 0
        contentLable.textAlignment = .center
    }
	override func getCellHeight() -> CGFloat {
		return 50.0
	}
}

extension KKChatSystemMsgCell {
	fileprivate func setModel() {
		guard let msg = self.model else { return }
		let str = "\(msg.timeStr) \(msg.content?.text ?? "")"
		contentLable.text = str
		contentLable.sizeToFit()
		model?.cellHeight = getCellHeight()
	}
}
