//
//  LoginPopupPage.swift
//  QatarMuseums
//
//  Created by Exalture on 18/10/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import UIKit
@objc protocol LoginPopUpProtocol
{
    func popupCloseButtonPressed()
    func loginButtonPressed()
    @objc optional func forgotButtonPressed()
}
class LoginPopupPage: UIView {
    
    @IBOutlet var loginPopup: UIView!
    
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginPopupInnerView: UIView!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    var loginPopupDelegate : LoginPopUpProtocol?
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    private func commonInit()
    {
        Bundle.main.loadNibNamed("LoginPopupView", owner: self, options: nil)
        addSubview(loginPopup)
        loginPopup.frame = self.bounds
        loginPopup.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        setUpUI()
    }
    func setUpUI() {
        loginPopupInnerView.layer.cornerRadius = 20.0
        self.backgroundColor = UIColor.popupBackgroundWhite
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        titleLabel.font = UIFont.headerFont
        userNameText.font = UIFont.startTourFont
        passwordText.font = UIFont.startTourFont
        loginButton.titleLabel?.font = UIFont.startTourFont
        forgotButton.titleLabel?.font = UIFont.discoverButtonFont
        passwordText.isSecureTextEntry = true
        
        titleLabel.text = NSLocalizedString("CULTUREPASS_LOGIN", comment: "CULTUREPASS_LOGIN in the Login page")
        loginButton .setTitle(NSLocalizedString("LOGIN", comment: "LOGIN in the Login page"), for: .normal)
        forgotButton .setTitle(NSLocalizedString("FORGOT_PASSWORD", comment: "FORGOT_PASSWORD in the Login page"), for: .normal)
        userNameText.placeholder = NSLocalizedString("LOGIN_USERNAME", comment: "LOGIN_USERNAME in the Login page")
        passwordText.placeholder = NSLocalizedString("LOGIN_PASSWORD", comment: "LOGIN_PASSWORD in the Login page")
    }
    @IBAction func didTapForgotPwd(_ sender: UIButton) {
        self.forgotButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        loginPopupDelegate?.forgotButtonPressed!()
    }
    @IBAction func didTapLogin(_ sender: UIButton) {
        self.loginButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        loginPopupDelegate?.loginButtonPressed()
    }
    
    @IBAction func didTapClose(_ sender: UIButton) {
        self.closeButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        loginPopupDelegate?.popupCloseButtonPressed()
    }
    @IBAction func popupCloseTouchDown(_ sender: UIButton) {
        self.closeButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    @IBAction func forgotButtonTouchDown(_ sender: UIButton) {
        self.forgotButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    @IBAction func loginButtonTouchDown(_ sender: UIButton) {
        self.loginButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
}
