//
//  LoginPopupPage.swift
//  QatarMuseums
//
//  Created by Exalture on 18/10/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import UIKit
protocol InvitationAcceptedPopupProtocol
{
    //func invitationAcceptPopupClose()
    func invitationAcceptClose()
}
class InvitationAcceptedPopup: UIView {
    
    @IBOutlet var invitationPopup: UIView!
    @IBOutlet weak var invitationText: UITextView!
    @IBOutlet weak var invitationPopupInnerView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var closeMessage: UIButton!
    @IBOutlet weak var inviteAcceptPopupHeight: NSLayoutConstraint!
    
    var invitationAcceptedPopupDelegate : InvitationAcceptedPopupProtocol?
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
        
//        if subviews.count == 0 {
//            let nib = UINib(nibName: NSStringFromClass(type(of: self).self), bundle: nil)
//            let subview = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
//            subview?.frame = bounds
//            if let aSubview = subview {
//                addSubview(aSubview)
//            }
//        }
        
        
        Bundle.main.loadNibNamed("InvitationAcceptedPopup", owner: self, options: nil)
        addSubview(invitationPopup)
        invitationPopup.frame = self.bounds
        invitationPopup.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        setUpUI()
    }
    func setUpUI() {
        invitationPopupInnerView.layer.cornerRadius = 20.0
        self.backgroundColor = UIColor.popupBackgroundWhite
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        invitationText.font = UIFont.invitationTextFont
        closeButton.titleLabel?.font = UIFont.headerFont
    }
    func showInvitationAcceptMessage() {
        
        invitationText.text = NSLocalizedString("ACCEPT_DESCRIPTION", comment: "ACCEPT_DESCRIPTION in  InvitationAcceptPopup popup")
        closeButton.setTitle(NSLocalizedString("CLOSEBUTTON_TITLE", comment: "CLOSEBUTTON_TITLE in  InvitationAcceptPopup popup"), for: .normal)
       
    }

    @IBAction func didTapCloseMessage(_ sender: UIButton) {
        self.closeButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        invitationAcceptedPopupDelegate?.invitationAcceptClose()
    }
    
    @IBAction func didTapClose(_ sender: UIButton) {
        self.closeButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        //invitationAcceptedPopupDelegate?.invitationAcceptPopupClose()
    }
    @IBAction func popupCloseTouchDown(_ sender: UIButton) {
        self.closeButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
//    @IBAction func forgotButtonTouchDown(_ sender: UIButton) {
//        self.acceptLaterButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
//    }
    @IBAction func closeMessageTouchDown(_ sender: UIButton) {
        self.closeButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
}
