//
//  LoginPopupPage.swift
//  QatarMuseums
//
//  Created by Exalture on 18/10/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import UIKit
protocol GreetingsPopUpProtocol
{
    func greetingsPopupCloseButtonPressed()
    func acceptNowButtonPressed()
    func acceptLaterButtonPressed()
}
class GreetingsPopupPage: UIView {
    
    @IBOutlet var greetingsPopup: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var greetingsPopupInnerView: UIView!
    @IBOutlet weak var acceptNowButton: UIButton!
    @IBOutlet weak var acceptLaterButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var greetingsPopupHeight: NSLayoutConstraint!
    
    var greetingsPopupDelegate : GreetingsPopUpProtocol?
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
        Bundle.main.loadNibNamed("GreetingsPopupView", owner: self, options: nil)
        addSubview(greetingsPopup)
        greetingsPopup.frame = self.bounds
        greetingsPopup.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        setUpUI()
    }
    func setUpUI() {
        greetingsPopupInnerView.layer.cornerRadius = 20.0
        self.backgroundColor = UIColor.popupBackgroundWhite
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        titleLabel.font = UIFont.tryAgainFont
        descriptionLabel.font = UIFont.heritageTitleFont
        acceptNowButton.titleLabel?.font = UIFont.headerFont
        acceptLaterButton.titleLabel?.font = UIFont.headerFont
    }
    func showGreetingsMessage() {
        titleLabel.text = NSLocalizedString("GREETINGS", comment: "GREETINGS in Greetings popup")
        descriptionLabel.text = NSLocalizedString("GREETINGS_DESCRIPTION", comment: "GREETINGS_DESCRIPTION in  Greetings popup")
        acceptNowButton.setTitle(NSLocalizedString("ACCEPT_NOW", comment: "ACCEPT_NOW in  Greetings popup"), for: .normal)
        acceptLaterButton.setTitle(NSLocalizedString("ACCEPT_LATER", comment: "ACCEPT_LATER in  Greetings popup"), for: .normal)
    }
    @IBAction func didTapacceptLaterButton(_ sender: UIButton) {
        self.acceptLaterButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        greetingsPopupDelegate?.acceptLaterButtonPressed()
    }
    @IBAction func didTapacceptNowButton(_ sender: UIButton) {
        self.acceptNowButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        greetingsPopupDelegate?.acceptNowButtonPressed()
    }
    
    @IBAction func didTapClose(_ sender: UIButton) {
        self.closeButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        greetingsPopupDelegate?.greetingsPopupCloseButtonPressed()
    }
    @IBAction func popupCloseTouchDown(_ sender: UIButton) {
        self.closeButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    @IBAction func acceptLaterButtonTouchDown(_ sender: UIButton) {
        self.acceptLaterButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    @IBAction func acceptNowButtonTouchDown(_ sender: UIButton) {
        self.acceptNowButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
}
