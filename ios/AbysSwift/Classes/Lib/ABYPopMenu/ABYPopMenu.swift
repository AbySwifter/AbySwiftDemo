//
/**
* 好看的皮囊千篇一律，有趣的灵魂万里挑一
* 创建者: 王勇旭 于 2018/4/26
* Copyright © 2018年 Aby.wang. All rights reserved.
* 4.0
*  ┏┓　　　┏┓
*┏┛┻━━━┛┻┓
*┃　　　　　　　┃
*┃　　　━　　　┃
*┃　┳┛　┗┳　┃
*┃　　　　　　　┃
*┃　　　┻　　　┃
*┃　　　　　　　┃
*┗━┓　　　┏━┛
*　　┃　　　┃神兽保佑
*　　┃　　　┃代码无BUG！
*　　┃　　　┗━━━┓
*　　┃　　　　　　　┣┓
*　　┃　　　　　　　┏┛
*　　┗┓┓┏━┳┓┏┛
*　　　┃┫┫　┃┫┫
*　　　┗┻┛　┗┻┛
*/

import UIKit
import DTTools

//fileprivate let kMenuTableViewWidth: CGFloat = 140.0
fileprivate let kMenuItemMargin: CGFloat = 20.0
fileprivate let kMenuItemHeight: CGFloat = 30.0
fileprivate let kImageRightMargin: CGFloat = 10.0
fileprivate let kMenuItemImageWidth: CGFloat = 18.0
fileprivate let kSeparatorHeight: CGFloat = 0.5
fileprivate let kMenuTabTopMargin:CGFloat = 8.0
fileprivate let kMenuTabBottomMargin: CGFloat = 20.0
fileprivate let KMenuSubY:CGFloat = 12.0
fileprivate let kMenuItemShowLineHeight: CGFloat = kMenuItemHeight + 15.0

/// 导航栏弹出菜单
/// - 以传入的数组为基础，进行布局
class ABYPopMenu: UIView {
    /// 需要展示的菜单
	var menus: [ABYPopMenuItem]?
    /// 当前菜单的父视图
	weak var currentSuperView: UIView?
    var targetPoint: CGPoint? // FIXME: 暂时没有用到，下一步完善
	private var indexPath: IndexPath!

    /// 分隔线的展示间距
	var lineNumber: Int!

    /// 最大宽度
	var maxWidth: CGFloat {
		var temp: ABYPopMenuItem = ABYPopMenuItem.init(image: nil, title: "")
		for item in self.menus! {
			if item.textWidth > temp.textWidth {
				temp = item
			}
		}
		let width = kMenuItemMargin * 2 + kMenuItemImageWidth + kImageRightMargin + temp.textWidth;
		return width
	}

	private var offset_x: CGFloat {
		let m_width = maxWidth
		return (self.targetPoint?.x ?? self.bounds.width - 10) - m_width
	}

	private var offset_y: CGFloat {
		return targetPoint?.y ?? 5
	}
	/// 点击菜单item的事件回传
    ///     - param:
    ///         - index: item下标；menuItem: 菜单栏
	var popMenuDidSelectedBlock: ((_ index: Int, _ menuItem: ABYPopMenuItem) -> ())?
	// MARK: 懒加载
	private lazy var menuContainerView: UIImageView = {
        let container = UIImageView.init(image: #imageLiteral(resourceName: "rightMenu").resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), resizingMode: .tile))
		var number = (self.menus?.count ?? 0) / self.lineNumber
		if (self.menus?.count ?? 0) % self.lineNumber == 0 {
			number -= 1
		}
		let moreHeight = CGFloat(number) * (kMenuItemShowLineHeight - kMenuItemHeight)
		let m_height = CGFloat(self.menus?.count ?? 0) * kMenuItemHeight + kMenuTabTopMargin + kMenuTabBottomMargin + moreHeight
		container.frame = CGRect.init(x: self.offset_x, y: self.offset_y, width: self.maxWidth, height: m_height)
		return container
	}()
	private lazy var menuTableView: UITableView = {
		let tableView = UITableView.init(frame: CGRect(x:kMenuItemMargin, y:kMenuTabTopMargin, width: maxWidth - kMenuItemMargin * 2, height: self.menuContainerView.bounds.height - kMenuTabTopMargin), style: .plain)
		tableView.backgroundColor = UIColor.clear
		tableView.separatorColor = UIColor.clear
		tableView.separatorStyle = .none // 分割线
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = kMenuItemHeight
		tableView.isScrollEnabled = false
		return tableView
	}()
	// MARK: -重载init方法
    /// 弹出菜单的初始化方法
    ///
    /// - Parameters:
    ///     - menus: ABYPopMenuItem 菜单数组
    ///     - lineNumber: Int 隔多少行有分割线
    ///     - targetPoint: CGPoint 弹出的位置（貌似没有实现）
    /// - Returns:
    ///     初始化方法
	init(menus: [ABYPopMenuItem], lineNumber: Int = 2, targetPoint: CGPoint = CGPoint.zero) {
		super.init(frame: CGRect.zero)
		self.menus = menus
		self.lineNumber = lineNumber
		self.targetPoint = targetPoint
		self.setup()
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder) has not been implemented")
	}
	private func setup() -> Void {
		self.frame = UIScreen.main.bounds
		self.backgroundColor = UIColor.clear
		menuContainerView.addSubview(menuTableView)
		menuContainerView.isUserInteractionEnabled = true
		// 添加背景图
		self.addSubview(menuContainerView)
	}

    /// 在window上展示菜单
	func showMenuOnWindow() {
		self.showMenu(on: UIApplication.shared.keyWindow!)
	}

    /// 展示菜单
    ///
    /// - Parameters:
    ///   - view: 要展示的view
    ///   - opacity: 透明度
	func showMenu(on view: UIView, opacity: CGFloat = 0.3) {
		currentSuperView = view
		self.backgroundColor = UIColor.init(hexString: "000000", alpha: opacity)
		self.showMenu()
	}

	fileprivate func showMenu() {
		guard let curSuperView = currentSuperView else {
			return
		}
		if !curSuperView.subviews.contains(self) {
			alpha = 0.0
			currentSuperView?.addSubview(self)
			UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
				self.alpha = 1.0
			})
		} else {
			self.removeFromSuperview()
//			self.dismissPopMenuAnimatedOnMenu(selected: false)
		}
	}

    /// Dismiss当前菜单
    ///
    /// - Parameter selected: 貌似没有用到的一个参数，写注释的时候我也不知道这个参数是干什么的了
	func dismissPopMenuAnimatedOnMenu(selected: Bool) {
		UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [unowned self] in
			self.alpha = 0.0
		}) { (_) in
			self.removeFromSuperview()
		}
	}

    // 重写拦截的方法，保证点击tableView的正常
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first
		let localPoint = touch?.location(in: self)
		if self.menuContainerView.frame.contains(localPoint!) {
			hitTest(localPoint!, with: event)
		} else {
			self.dismissPopMenuAnimatedOnMenu(selected: false)
		}
	}

	deinit {
		DTLog("我被销毁了")
	}
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension ABYPopMenu: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.menus?.count ?? 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellID = "PopMenuCellID"
		var popItem: ABYMenuItemCell? = tableView.dequeueReusableCell(withIdentifier: cellID) as? ABYMenuItemCell
		if popItem == nil {
			popItem = ABYMenuItemCell.init(style: .default, reuseIdentifier: cellID)
		}
		let showLine = (indexPath.row + 1) % lineNumber == 0 && ((indexPath.row + 1) < (self.menus?.count ?? 0))
		popItem?.setup(item: (self.menus?[indexPath.row])!, at: indexPath, showLine: showLine)
		return popItem!
	}
	// cell的点击事件
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.indexPath = indexPath
		self.dismissPopMenuAnimatedOnMenu(selected: true)
		// 回调
		popMenuDidSelectedBlock?(indexPath.row, self.menus![indexPath.row])
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let showLine = (indexPath.row + 1) % lineNumber == 0 && ((indexPath.row + 1) < (self.menus?.count ?? 0))
		return showLine ? kMenuItemShowLineHeight : kMenuItemHeight
	}
}


/// 菜单的Item模型
class ABYPopMenuItem: NSObject {
    /// Icon占位图
	var image: UIImage?

    /// 标题
	var title: String?

    /// item的初始化方法
    ///
    /// - Parameters:
    ///   - image: Icon图
    ///   - title: 标题
	init(image: UIImage?, title: String?) {
		super.init()
		self.image = image
		self.title = title
	}

    /// 富文本title
	var attributeTitle: NSAttributedString {
        let attribute = NSAttributedString.init(string: self.title ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "666666"), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0)])
		return attribute
	}


    /// 计算标题的宽度
	fileprivate var textWidth: CGFloat {
		let size: CGRect = self.attributeTitle.boundingRect(with: CGSize.init(width:  kScreenWidth, height: KScreenHeight), options: .usesFontLeading, context: nil)
		return size.width
	}
}


/// 菜单的item cell
class ABYMenuItemCell: UITableViewCell {

    /// 菜单的Item
	var popMeneItem: ABYPopMenuItem?
	var title: UILabel = UILabel.init()
	var icon: UIImageView = UIImageView.init()
	// 自制的分割线
	lazy var separator: UIView = { [unowned self] in
		let sFrame = CGRect.init(x: 0, y: self.frame.height - kSeparatorHeight, width:self.frame.size.width , height: kSeparatorHeight)
		let separtor = UIView.init(frame: sFrame)
		separtor.backgroundColor = UIColor.init(hexString: "cccccc")
		return separtor
	}()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = UIColor.clear
		contentView.removeFromSuperview()
		self.selectionStyle = .none
		let imageFrame = CGRect.init(x: 0, y: KMenuSubY, width: kMenuItemImageWidth, height: kMenuItemImageWidth)
		self.addSubview(icon)
		icon.frame = imageFrame
		icon.contentMode = .scaleAspectFit
		let titleFrame = CGRect.init(x: kMenuItemImageWidth + kImageRightMargin, y: KMenuSubY, width: 0, height: 0)
		self.addSubview(title)
		title.frame = titleFrame
		self.addSubview(separator)
	}
	func setup(item: ABYPopMenuItem, at indexPath: IndexPath, showLine: Bool) -> Void {
		self.popMeneItem = item
		icon.image = popMeneItem?.image
		title.attributedText = popMeneItem?.attributeTitle
		title.sizeToFit()
		title.centerY = icon.centerY
		self.separator.isHidden = !showLine
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) han not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		var frame = self.separator.frame
		frame.size.width = self.width
		self.separator.frame = frame
	}
}
