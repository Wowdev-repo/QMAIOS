//
//  PaymentGatewayViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 19/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
import WebKit
import JGProgressHUD
import SwiftyJSON

protocol PaymentGatewayViewControllerDelegate: class {
    func paymentSucceeded(paymentId : String)
}

class PaymentGatewayViewController: UIViewController, WKNavigationDelegate, APIServiceResponse, APIServiceProtocolForConnectionError {
    
    //MARK:- Decleration
    
    let window: UIWindow? = UIApplication.shared.windows[0]

    var apiServices = QMTLAPIServices()
    
    var paymentGatewayViewControllerDelegate : PaymentGatewayViewControllerDelegate?
    let hud = JGProgressHUD(style: .extraLight)
    var tabViewController = QMTLTabViewController()
    
    var paymentId = ""
    
    var isViewPopped = false
    var isFromMemberShipRenewal = false
    
    //MARK:- IBOutlet
    @IBOutlet weak var pgwWebView: WKWebView!
    

    //MARK:- Controller Defaults
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        apiServices.delegateForConnectionError = self
        apiServices.delegateForAPIServiceResponse = self
        
        pgwWebView.navigationDelegate = self
        
        if self.view !=  nil{
            hud.hudView.frame = apiServices.hud.frame
        }
        
        apiServices.getPaymentGateWayLink(serviceFor: QMTLConstants.ServiceFor.paymentGateWayURL, isFromMemberShipRenewal: isFromMemberShipRenewal, view: self.view)
        
        hud.show(in: window!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabViewController =  self.navigationController?.tabBarController as! QMTLTabViewController
        tabViewController.topTabBarView.isHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabViewController.topTabBarView.isHidden = false
    }
    
    //MARK:- API Service Delegate
    
    func connectionError(ConnectionErrInfo errInfo: String?, StatusCode statusCode: Int) {
        print("Payment Error ResponseJSON = \(String(describing: errInfo))")
        self.navigationController?.popViewController(animated: false)
    }
    
    func responseWith(ResponseJSON json: JSON, StatusCode statusCode: Int, ServiceFor serviceFor: String) {
        print("\(serviceFor) Success ResponseJSON = \(json)")
        
        pgwWebView.load(URLRequest(url: URL(string: json.stringValue)!))
        
        hud.show(in: window!)
    }
    
    //MARK:- WebView Delegate
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        hud.dismiss()
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
    
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        hud.show(in: window!)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
         hud.dismiss()
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void)
    {
        if(navigationAction.navigationType == .other)
        {
            if navigationAction.request.url != nil
            {
                print("navigationAction.request.url! = \(navigationAction.request.url!)")
                let urlStr = "\(navigationAction.request.url!)"
                let arr = urlStr.components(separatedBy: "?")
                
                if arr.count > 1{
                    if arr[1].contains("paymentId") {
                        let paramStr = arr[1]
                        print("paramStr = \(paramStr)")
                        let paramArr = paramStr.components(separatedBy: "&")
                        print("paramArr = \(paramArr)")
                        for param in paramArr {
                            print("param = \(param)")
                            let sepParam = param.components(separatedBy: "=")
                            print("sepParam = \(sepParam)")
                            print("sepParam[0] = \(sepParam[0])")
                            if sepParam[0] == "paymentId" {
                                paymentId = sepParam[1]
                                print("sepParam[1] = \(sepParam[1])")
                                break
                            }
                        }
                    }
                }
                
                guard let url = navigationAction.request.url else { return }
                if url.absoluteString.contains("/apipaymentFailure")
                {
                    self.paymentFailedAlertAlert()
                }
                else if url.absoluteString.contains("/apipaymentSuccess")
                {
                    if !isViewPopped {
                        isViewPopped = true
                        
                        QMTLSingleton.sharedInstance.ticketInfo.paymentId = paymentId
                        paymentGatewayViewControllerDelegate?.paymentSucceeded(paymentId: paymentId)
                    }
                }
                
            }
        }
        decisionHandler(.allow)
    }
    
    func paymentFailedAlertAlert() {
        
        let alert = UIAlertController(title: "Payment Failed?", message: "Your Payment Request has been been failed. Please try again",         preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
