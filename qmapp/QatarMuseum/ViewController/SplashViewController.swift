//
//  SplashViewController.swift
//  QatarMuseums
//
//  Created by Wakralab on 12/06/18.
//  Copyright © 2018 Qatar museums. All rights reserved.
//

import Crashlytics
import UIKit
import CocoaLumberjack
import Firebase

class CPSplashViewController: UIViewController {

    @IBOutlet weak var splashImageView: UIImageView!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()
        self.splashImageView.image = UIImage.gifImageWithName("QMLogo")
        _ = Timer.scheduledTimer(timeInterval: 1.5,
                                                         target: self,
                                                         selector: #selector(CPSplashViewController.loadHome),
                                                         userInfo: nil,
                                                         repeats: false)
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.view_did_load,
            AnalyticsParameterItemName: "Splash Screen",
            AnalyticsParameterContentType: "cont"
            ])
        
       
    }
   
   @objc func loadHome() {
        splashImageView.stopAnimating()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.performSegue(withIdentifier: "splashToHomeSegue", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
