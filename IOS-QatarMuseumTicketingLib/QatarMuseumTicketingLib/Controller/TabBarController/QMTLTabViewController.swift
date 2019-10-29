//
//  QMTLTabViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 11/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
import KeychainSwift
import Kingfisher

@objc protocol QMTLTabViewControllerDelegate: class {
    func backBtnSelected()
    
    @objc optional func moveToTabRoot()
    @objc optional func bottomBtnAction()
}

class QMTLTabViewController: UITabBarController, TopTabBarViewDelegate {

    //MARK:- Decleration
    var qmtlTabViewControllerDelegate : QMTLTabViewControllerDelegate?
    var topTabBarView = TopTabBarView()
    let keychain = KeychainSwift()
    
    var bottomBtn: UIButton!
    var dummyBottomView : UIView!
    
    private var myToolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        if (UserDefaults.standard.string(forKey: "KEYCHAINSTR") == "" || UserDefaults.standard.string(forKey: "KEYCHAIN") == nil ){
            
            self.clearUserSession();
             UserDefaults.standard.set("SET", forKey: "KEYCHAIN") //setObject
        }
        

        
       
        
        self.navigationItem.setHidesBackButton(true, animated:false)
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
        self.tabBar.isHidden = true
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets.top = 20
        }
        
        QMTLSingleton.sharedInstance.initialViewControllerToCall = UserDefaults.standard.string(forKey: QMTLConstants.viewController.initialViewControllerKey) ?? ""
        setupToolBar()
        
        setupUserDetail()
        openInitialViewController()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        setupGlobalAppearance()
    }
    override func viewWillDisappear(_ animated: Bool) {
        QMTLSingleton.sharedInstance.ticketInfo.prices.removeAll()
        
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
        KingfisherManager.shared.cache.cleanExpiredDiskCache()
    }
    
    // MARK: - Appearance.
    func setupGlobalAppearance(){
        //global Appearance settings
        if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
            let customFont = UIFont(name: QMTLConstants.App.regularFontEn, size: 17)!
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: customFont], for: .normal)
            UITextField.appearance().substituteFontName = QMTLConstants.App.regularFontEn
            UILabel.appearance().substituteFontName = QMTLConstants.App.regularFontEn
            UILabel.appearance().substituteFontNameBold = QMTLConstants.App.boldFontEn
            QMTLTabViewController.applyToUIButton();
        }
        else{
            let customFont = UIFont(name: QMTLConstants.App.regularFontAr, size: 17)!
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: customFont], for: .normal)
            UITextField.appearance().substituteFontName = QMTLConstants.App.regularFontAr
            UILabel.appearance().substituteFontName = QMTLConstants.App.regularFontAr
            UILabel.appearance().substituteFontNameBold = QMTLConstants.App.boldFontAr
            QMTLTabViewController.applyToUIButton();
        }
       
    }

    static func applyToUIButton(a: UIButton = UIButton.appearance()) {
        if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
        a.titleLabelFont = UIFont(name: QMTLConstants.App.regularFontEn, size:17.0)
        // other UIButton customizations
        }
        else{
            a.titleLabelFont = UIFont(name: QMTLConstants.App.regularFontAr, size:17.0)
        }
    }
    func setupToolBar(){
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        topTabBarView = TopTabBarView.instanceFromNib() as! TopTabBarView
        topTabBarView.topTabBarViewDelegate = self
        topTabBarView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 45)
        self.view.addSubview(topTabBarView)
        
        if ((QMTLLocalizationLanguage.currentAppleLanguage()) != "en") {
            topTabBarView.backBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        
        var bottomSafeAreaHeight: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows[0]
            let safeFrame = window.safeAreaLayoutGuide.layoutFrame
            bottomSafeAreaHeight = window.frame.maxY - safeFrame.maxY
        }
        
        dummyBottomView = UIView(frame: CGRect(x: 0, y: (self.view.frame.size.height - bottomSafeAreaHeight), width: self.view.frame.size.width, height: 100))
        dummyBottomView.backgroundColor = .black
        self.view.addSubview(dummyBottomView)
        
        bottomBtn = UIButton(frame: CGRect(x: 25, y: (self.view.frame.size.height - bottomSafeAreaHeight) - 60, width: self.view.frame.size.width-50, height: 50))
        bottomBtn.backgroundColor = .black
        bottomBtn.setTitle("", for: .normal)
        bottomBtn.setTitleColor(.white, for: .normal)
        bottomBtn.layer.cornerRadius = 25;
        bottomBtn.addTarget(self, action: #selector(bottomBtnAction), for: .touchUpInside)
         self.view.addSubview(bottomBtn)
        
        bottomBtn.isHidden = true
    }
    
    func clearUserSession(){
        print("cleanUserSession called")
        
        QMTLSingleton.sharedInstance.userInfo.id = ""
        QMTLSingleton.sharedInstance.userInfo.name = ""
        QMTLSingleton.sharedInstance.userInfo.email = ""
        QMTLSingleton.sharedInstance.userInfo.phone = ""
        QMTLSingleton.sharedInstance.userInfo.username = ""
        QMTLSingleton.sharedInstance.userInfo.password = ""
        QMTLSingleton.sharedInstance.userInfo.isLoggedIn = false
        QMTLSingleton.sharedInstance.userInfo.isSubscribed = false
        
        self.keychain.set("", forKey: QMTLConstants.UserValues.username)
        self.keychain.set("", forKey: QMTLConstants.UserValues.password)
        self.keychain.set("", forKey: QMTLConstants.UserValues.personId)
        self.keychain.set("", forKey: QMTLConstants.UserValues.name)
        self.keychain.set("", forKey: QMTLConstants.UserValues.email)
        self.keychain.set("", forKey: QMTLConstants.UserValues.phone)
        self.keychain.set(false, forKey: QMTLConstants.UserValues.isLoggedIn)
    }
    
    func setupUserDetail(){
        
        if self.keychain.getBool(QMTLConstants.UserValues.isLoggedIn) ?? false {
                QMTLSingleton.sharedInstance.userInfo.isLoggedIn =
                    self.keychain.getBool(QMTLConstants.UserValues.isLoggedIn) ?? false
                QMTLSingleton.sharedInstance.userInfo.username = self.keychain.get(QMTLConstants.UserValues.username) ?? ""
                QMTLSingleton.sharedInstance.userInfo.password = self.keychain.get(QMTLConstants.UserValues.password) ?? ""
                QMTLSingleton.sharedInstance.userInfo.id = self.keychain.get(QMTLConstants.UserValues.personId) ?? ""
                
                QMTLSingleton.sharedInstance.userInfo.name = self.keychain.get(QMTLConstants.UserValues.name) ?? ""
                QMTLSingleton.sharedInstance.userInfo.email = self.keychain.get(QMTLConstants.UserValues.email) ?? ""
                QMTLSingleton.sharedInstance.userInfo.phone = self.keychain.get(QMTLConstants.UserValues.phone) ?? ""
         
        }
        
        
    }
    
    func openInitialViewController(){
        
        if QMTLSingleton.sharedInstance.initialViewControllerToCall != "" {
         
            switch QMTLSingleton.sharedInstance.initialViewControllerToCall {
            case QMTLConstants.viewController.QMTLTicketCounterContainerViewController:
                self.selectedIndex = 0
                break
            case QMTLConstants.viewController.UserProfileTableViewController:
                self.selectedIndex = 1
                break
            default:
                break
            }
            
        }
        
    }
    
    // called when UIBarButtonItem is clicked.
    @objc func onClickBarButton(sender: UIBarButtonItem) {
        
        switch sender.tag {
        case 1:
            self.view.backgroundColor = UIColor.green
        case 2:
            self.view.backgroundColor = UIColor.blue
        case 3:
            self.view.backgroundColor = UIColor.red
        default:
            print("ERROR!!")
        }
    }

    //MARK:- IBAction
    
    @IBAction func bottomBtnAction(_ sender: Any)  {
        qmtlTabViewControllerDelegate?.bottomBtnAction!()
    }
    
    
    //MARK:- TabBarViewDelegates
    
    func backBtnSelected() {
        print("Tab backBtnSelected")
        qmtlTabViewControllerDelegate?.backBtnSelected()
    }
    
    func ticketBtnSelected() {
        print("Tab ticketBtnSelected")
        self.selectedIndex = 0
    }
    
    func notificationBtnSelected() {
        print("Tab notificationBtnSelected")
    }
    
    func myProfileBtnSelected() {
        print("Tab myProfileBtnSelected")
        
        if self.selectedIndex == 1 {
            qmtlTabViewControllerDelegate?.moveToTabRoot!()
        }
        
        self.selectedIndex = 1
    }
    
    func menuBtnSelected() {
        
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

//MARK: UILabel extension
extension UILabel {
    func decideTextDirection () {        
        if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
            self.textAlignment = NSTextAlignment.left
        }else{
            self.textAlignment = NSTextAlignment.right
        }
    }
}

//MARK: UIView extension
extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

@IBDesignable
public class QMARoundedButton: UIButton {
    
    @IBInspectable var cornerRadius:CGFloat = 0.0 {
        didSet {
            setRadius()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var circular: Bool = false {
        didSet {
            setRadius()
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        setRadius()
    }
    
    private func setRadius() {
        layer.cornerRadius = circular ? self.bounds.width/2 : cornerRadius
        layer.masksToBounds = layer.cornerRadius > 0
    }
}

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhones_4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_X_XS = "iPhone X or iPhone XS"
        case iPhone_XR = "iPhone XR"
        case iPhone_XSMax = "iPhone XS Max"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhones_4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1792:
            return .iPhone_XR
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhones_X_XS
        case 2688:
            return .iPhone_XSMax
        default:
            return .unknown
        }
    }
}
