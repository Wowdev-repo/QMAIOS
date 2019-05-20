//
//  TermsAndConditionViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 16/04/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit

class TermsAndConditionViewController: UIViewController,QMTLTabViewControllerDelegate {
    
    //MARK:- Decleration
    var tabViewController = QMTLTabViewController()
    
    @IBOutlet weak var tANDcContainerView: UIView!
    @IBOutlet weak var i_1: UILabel!
    @IBOutlet weak var contentTxtView: UITextView!
    
    @IBOutlet weak var okBtn: UIButton!
    
    //MARK:- ViewDefaults
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:false)
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets.top = 20
        }
        
        tANDcContainerView.layer.cornerRadius = 10.0
        
        if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
            contentTxtView.text = TandCcontent.content.en
            contentTxtView.textAlignment = .left
        }else{
            contentTxtView.text = TandCcontent.content.ar
            contentTxtView.textAlignment = .right
        }
        
        // Do any additional setup after loading the view.
        
        localizationSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabViewController =  self.navigationController?.tabBarController as! QMTLTabViewController
        tabViewController.qmtlTabViewControllerDelegate = self
        tabViewController.topTabBarView.myProfileBtn.isHidden = true
        
        
        if QMTLSingleton.sharedInstance.userInfo.isLoggedIn{
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        contentTxtView.setContentOffset(.zero, animated: true)

    }
    
    
    
    //MARK:- TabView Delegate
    func backBtnSelected() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- IBAction
    @IBAction func okBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    func localizationSetup(){
        
        i_1.text = getLocalizedStr(str: i_1.text!)
        okBtn.setTitle(getLocalizedStr(str: okBtn.titleLabel!.text!), for: .normal)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
