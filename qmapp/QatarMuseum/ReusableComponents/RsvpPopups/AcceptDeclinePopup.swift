//
//  LoginPopupPage.swift
//  QatarMuseums
//
//  Created by Exalture on 18/10/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import UIKit
protocol DeclinePopupProtocol
{
    func declinePopupCloseButtonPressed()
    func yesButtonPressed()
    func noButtonPressed()
}
class AcceptDeclinePopup: UIView {
    
    @IBOutlet var declinePopup: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var declinePopupInnerView: UIView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var titleLineLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var popupViewHeight: NSLayoutConstraint!
    
    var declinePopupDelegate : DeclinePopupProtocol?
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
        Bundle.main.loadNibNamed("AcceptDeclinePopup", owner: self, options: nil)
        addSubview(declinePopup)
        declinePopup.frame = self.bounds
        declinePopup.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        setUpUI()
    }
    func setUpUI() {
        declinePopupInnerView.layer.cornerRadius = 20.0
        self.backgroundColor = UIColor.popupBackgroundWhite
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        titleLabel.font = UIFont.tryAgainFont
        descriptionLabel.font = UIFont.heritageTitleFont
        yesButton.titleLabel?.font = UIFont.headerFont
        noButton.titleLabel?.font = UIFont.headerFont
    }
    func showAcceptDeclineMessage() {
        titleLabel.text = NSLocalizedString("CONFIRMATION", comment: "CONFIRMATION in accept decline popup")
        descriptionLabel.text = NSLocalizedString("DECLINE_DESCRIPTION", comment: "DECLINE_DESCRIPTION in accept decline popup")
        yesButton.setTitle(NSLocalizedString("YES", comment: "YES in accept decline popup"), for: .normal)
        noButton.setTitle(NSLocalizedString("NO", comment: "NO in accept decline popup"), for: .normal)
    }
    func showUnregisterYesOrNoMessage() {
        titleLabel.isHidden = true
        descriptionLabel.text = NSLocalizedString(UNREGISTER_CONFIRMATION_MESSAGE, comment: "UNREGISTERmesage in accept decline popup")
        titleLineLabel.isHidden = true
        yesButton.setTitle(YES, for: .normal)
        noButton.setTitle(NO, for: .normal)
    }
    @IBAction func didTapNoButton(_ sender: UIButton) {
        self.noButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        declinePopupDelegate?.noButtonPressed()
    }
    @IBAction func didTapYesButton(_ sender: UIButton) {
        self.yesButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        declinePopupDelegate?.yesButtonPressed()
    }
    
    @IBAction func didTapClose(_ sender: UIButton) {
        self.closeButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        declinePopupDelegate?.declinePopupCloseButtonPressed()
    }
    @IBAction func popupCloseTouchDown(_ sender: UIButton) {
        self.closeButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    @IBAction func noButtonTouchDown(_ sender: UIButton) {
        self.noButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    @IBAction func yesButtonTouchDown(_ sender: UIButton) {
        self.yesButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
}
