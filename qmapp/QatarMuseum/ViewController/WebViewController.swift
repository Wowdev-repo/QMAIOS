//
//  WebViewController.swift
//  QatarMuseum
//
//  Created by Exalture on 07/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import UIKit
import WebKit
import Crashlytics
import CocoaLumberjack
import Firebase
class WebViewController: UIViewController,UIWebViewDelegate,LoadingViewProtocol {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var loadingView: LoadingView!
    var webViewUrl: URL? = nil
    var titleString: String? = nil
    let networkReachability = NetworkReachabilityManager()
    var baseUrlString : URL?
    var content : String?
    override func viewDidLoad() {
    DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

    loadingView.isHidden = false
    loadingView.showLoading()
        loadingView.loadingViewDelegate = self
        super.viewDidLoad()
        if ((titleString != nil) && (titleString != "")) {
            self.titleLabel.text = titleString
        }
        titleLabel.font = UIFont.headerFont
        if  (networkReachability?.isReachable)! {
            let requestObj = URLRequest(url: webViewUrl!)
            self.webView.loadRequest(requestObj)
        } else {
            self.showNoNetwork()
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.view_did_load,
            AnalyticsParameterItemName: titleString ?? "",
            AnalyticsParameterContentType: "cont"
            ])
        webView.delegate = self
        webView.backgroundColor = UIColor.whiteColor
        webView.scrollView.bounces = false
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingView.stopLoading()
        loadingView.isHidden = true
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
       loadingView.stopLoading()
        loadingView.isHidden = true
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        loadingView.stopLoading()
        loadingView.isHidden = true
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        loadingView.stopLoading()
        loadingView.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func didTapClose(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    //MARK: LoadingView Delegate
    func tryAgainButtonPressed() {
        if  (networkReachability?.isReachable)! {
            loadingView.isHidden = false
            self.loadingView.hideNoDataView()
            
            loadingView.showLoading()
            let requestObj = URLRequest(url: webViewUrl!)
            self.webView.loadRequest(requestObj)
        }
    }
    func showNoNetwork() {
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
    }

}
