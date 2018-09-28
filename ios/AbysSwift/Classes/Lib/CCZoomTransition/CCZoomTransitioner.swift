//
//  CCZoomTransitioner.swift
//  CCGitHubPro
//
//  Created by bo on 20/12/2016.
//  Copyright © 2016 bo. All rights reserved.
//

import UIKit


/// 实现了UIViewControllerTransitioningDelegate
class CCZoomTransitioner : NSObject, UIViewControllerTransitioningDelegate {

    /// 动画初始化的视图
    var transitOriginalView : UIView? = nil
    
    /// 即将模态出现的VC
    var presentationController : CCSwipBackPresentationController? = nil
    
    /// 滑动返回的开关
    var swipeBackDisabled : Bool = false

    /// MARK: - 代理方法（UIViewControllerTransitioningDelegate）
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let trans = CCZoomAnimatedTransitioning()
        trans.transitOriginalView = self.transitOriginalView;
        trans.isPresentation = true;
        return trans;
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let trans = CCZoomAnimatedTransitioning()
        trans.transitOriginalView = self.transitOriginalView;
        trans.isPresentation = false;
        return trans;
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.presentationController?.swipBackTransitioning
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        self.presentationController = CCSwipBackPresentationController.init(presentedViewController: presented, presenting: presenting)
        return self.presentationController
    }
}
