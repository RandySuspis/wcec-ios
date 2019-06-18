//
//  WebViewViewController.swift
//  WCEC
//
//  Created by GEM on 8/6/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class WebViewViewController: BaseViewController {

    var webView: WKWebView!
    var package: NSDictionary!
    var progressView: UIProgressView!
    var myContext = 0
    var stringUrl = ""
    //init
    override func loadView() {
        //add webview
        webView = WKWebView()
//        webView.navigationDelegate = self
        view = webView
        
        //add progresbar to navigation bar
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        progressView.tintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        navigationController?.navigationBar.addSubview(progressView)
        let navigationBarBounds = self.navigationController?.navigationBar.bounds
        progressView.frame = CGRect(x: 0, y: navigationBarBounds!.size.height - 2, width: navigationBarBounds!.size.width, height: 2)
    }
    
    //deinit
    deinit {
        //remove all observers
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        //remove progress bar from navigation bar
        progressView.removeFromSuperview()
    }
    
    //viewcontroller
    override func viewDidLoad() {
        guard let myRequest = myRequest() else { return }
        webView.load(myRequest)
        webView.allowsBackForwardNavigationGestures = true
        // // add observer for key path
        webView.addObserver(self, forKeyPath: "title", options: .new, context: &myContext)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: &myContext)
    }
    
    //observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let change = change else { return }
        if context != &myContext {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == "title" {
            if let title = change[NSKeyValueChangeKey.newKey] as? String {
                self.navigationItem.title = title
            }
            return
        }
        if keyPath == "estimatedProgress" {
            if let progress = (change[NSKeyValueChangeKey.newKey] as AnyObject).floatValue {
                progressView.progress = progress;
            }
            return
        }
    }
    
    //compute your url request
    func myRequest() -> URLRequest? {
        guard let url = URL(string: stringUrl) else {
            return nil
        }
        return URLRequest(url: url)
    }

}

