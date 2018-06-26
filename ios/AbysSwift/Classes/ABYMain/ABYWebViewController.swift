//
//  ABYWebViewController.swift
//  AbysSwift
//
//  Created by aby on 2018/5/30.
//  Copyright © 2018年 Aby.wang. All rights reserved.
//

import UIKit
import WebKit
import JGProgressHUD
import DTTools

class ABYWebViewController: UIViewController {

    lazy var loading: JGProgressHUD = {
        let loading = JGProgressHUD.init(style: .extraLight)
        return loading
    }()
    
    var url: String? {
        didSet {
            // url改变的时候需要处理WebView
        }
    }// 需要加载的url
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration.init()
        let preference = WKPreferences.init()
        preference.javaScriptEnabled = true
        webConfiguration.preferences = preference
        //设置是否将网页内容全部加载到内存后再渲染
        webConfiguration.suppressesIncrementalRendering = false
        //设置HTML5视频是否允许网页播放 设置为false则会使用本地播放器
        webConfiguration.allowsInlineMediaPlayback = true
        //设置是否允许ariPlay播放
        webConfiguration.allowsAirPlayForMediaPlayback = true
        //设置是否允许画中画技术 在特定设备上有效
        webConfiguration.allowsPictureInPictureMediaPlayback = true
        
        let webView = WKWebView.init(frame: self.view.bounds, configuration: webConfiguration)
        webView.navigationDelegate = self
        
        return webView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(webView)
        self.view.backgroundColor = UIColor.init(hexString: "f5f5f5")
        // Do any additional setup after loading the view.
        if let urlstr = self.url {
            let tempStr = urlstr.replacingOccurrences(of: " ", with: "")
            guard let urlValue = URL.init(string: tempStr) else {
                self.showToast("链接地址有误")
                return
            }
            let request = URLRequest.init(url: urlValue)
            webView.load(request)
        } else {
            self.showToast("链接地址有误")
        }
        
    }

}

extension ABYWebViewController: WKNavigationDelegate {
    
    /// 页面开始加载的时候调用
    ///
    /// - Parameters:
    ///   - webView: 当前页面的webview
    ///   - navigation: 导航
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
         DTLog("开始加载")
        self.loading.show(in: self.view, animated: true)
    }
    
    /// 内容开始返回时调用
    ///
    /// - Parameters:
    ///   - webView: 当前页面的WebView
    ///   - navigation: 导航
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        DTLog("开始返回内容")
    }
    
    /// 内容加载完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DTLog("加载完成")
        self.loading.dismiss(animated: true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    /// 发送请求前是否条状
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
       decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    /// 收到响应后是否跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(WKNavigationResponsePolicy.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
    
    /// 证书配置与过滤
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
    }
}
