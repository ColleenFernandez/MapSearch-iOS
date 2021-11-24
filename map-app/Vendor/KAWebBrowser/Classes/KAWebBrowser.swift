//
//  KAWebBrowser.swift
//  KAWebBrowser
// 
//  Created by zhihuazhang on 2016/06/08.
//  Copyright © 2016年 Kapps Inc. All rights reserved.
//

import UIKit
import WebKit

private let KVOEstimatedProgress = "estimatedProgress"
private let KVOTitle = "title"

open class KAWebBrowser: UIViewController , WKNavigationDelegate{

    fileprivate lazy var webView: WKWebView = {
        let webView = WKWebView(frame: CGRect.zero)
        return webView
    }()
    
    fileprivate lazy var progressBar: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.tintColor = UIColor.black
        progressBar.alpha = 0
        return progressBar
    }()
    
    open class func navigationControllerWithBrowser() -> UINavigationController {
        let browser = KAWebBrowser()
        
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .stop, target: browser, action: #selector(closeButtonPressed))
        browser.navigationItem.leftBarButtonItem = closeBtn

        return UINavigationController(rootViewController: browser)
    }
    
    open func loadURLString(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        loadURL(url)
    }
    
    open func loadURL(_ url: URL) {
        let request = URLRequest(url: url)
        loadRequest(request)
    }
    
    open func loadRequest(_ request: URLRequest) {
        webView.load(request)
    }
    
    var str_title: String?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.addleftButton()
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: .alignAllLeft, metrics: nil, views: ["webView": webView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: .alignAllTop, metrics: nil, views: ["webView": webView]))
        
        webView.addObserver(self, forKeyPath: KVOTitle, options: .new, context: nil)
        
        guard let _ = navigationController else {
            print("need UINavigationController to show progressbar")
            return
        }
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        view.addSubview(progressBar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: progressBar, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[progressBar]|", options: .alignAllLeft, metrics: nil, views: ["progressBar": progressBar]))
        webView.navigationDelegate = self
        //addleftButton()
        
        if let title = self.str_title{
            self.title = title
        }
        
    }
    
    func addleftButton() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        let btn_back = UIButton(type: .custom)
        btn_back.setImage(UIImage.init(systemName: "chevron.left")!.withConfiguration(largeConfig).withRenderingMode(.alwaysTemplate).withTintColor(.black), for: .normal)
        btn_back.addTarget(self, action: #selector(gotoHome), for: .touchUpInside)
        btn_back.imageEdgeInsets = UIEdgeInsets(top: 6.5, left: 5, bottom: 6.5, right: 5)
        btn_back.tintColor = .black
        let barButtonItemBack = UIBarButtonItem(customView: btn_back)
        self.navigationItem.leftBarButtonItem = barButtonItemBack
    }
    
    @objc func gotoHome() {
        self.navigationController?.popViewController(animated: true)
    }

    fileprivate func updateProgressBar(_ progress: Float) {
        if progress == 1.0 {
            progressBar.setProgress(progress, animated: true)
            UIView.animate(withDuration: 1.5, animations: {
                self.progressBar.alpha = 0.0
                }, completion: { finished in
                    if finished {
                        self.progressBar.setProgress(0.0, animated: false)
                    }
            })
        } else {
            if progressBar.alpha < 1.0 {
                progressBar.alpha = 1.0
            }
            progressBar.setProgress(progress, animated: (progress > progressBar.progress) && true)
        }
    }
    
    @objc func closeButtonPressed() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    deinit{
        //webView.removeObserver(self, forKeyPath: KVOEstimatedProgress)
        //webView.removeObserver(self, forKeyPath: KVOTitle)
    }

    // MARK: - KVO
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == KVOEstimatedProgress {
            updateProgressBar(Float(webView.estimatedProgress))
        }
        
        if keyPath == KVOTitle {
            title = self.webView.title
        }
    }
}

extension UINavigationController {
    
    public func webBrowser() -> KAWebBrowser? {
        return viewControllers.first as? KAWebBrowser
    }
}

extension KAWebBrowser : WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        let dict = message.body as? Dictionary<String, String>
        print(dict)
        //let userdata = UserData((dict?["firstName"])!, (dict?["email"])!, (dict?["lastName"])!)
        /*if message.name == "sumbitToiOS" {
            self.sumbitToiOS(user: userdata)
        }*/
    }
}
