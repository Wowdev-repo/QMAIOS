//
//  EventPopupView.swift
//  QatarMuseum
//
//  Created by Exalture on 08/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit
import CocoaLumberjack
protocol EventPopUpProtocol
{
    func eventCloseButtonPressed()
    func addToCalendarButtonPressed()
}
class EventPopupView: UIView {

    @IBOutlet var eventPopUp: UIView!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var eventPopupInnerView: UIView!
    @IBOutlet weak var addToCalendarButton: UIButton!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventPopupHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLine: UIView!
    
    @IBOutlet weak var eventDescription: UILabel!
    var eventPopupDelegate : EventPopUpProtocol?
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
        Bundle.main.loadNibNamed("EventPopUp", owner: self, options: nil)
        addSubview(eventPopUp)
        eventPopUp.frame = self.bounds
        eventPopUp.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        setUpUI()
    }
    func setUpUI() {
        
        eventPopupInnerView.layer.cornerRadius = 20.0
        self.backgroundColor = UIColor.popupBackgroundWhite
        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        eventTitle.font = UIFont.eventPopupTitleFont
        eventDescription.font = UIFont.settingsUpdateLabelFont
        addToCalendarButton.titleLabel?.font = UIFont.closeButtonFont
        
        
    }
    func loadRegistrationPopup() {
        eventTitle.isHidden = true
        titleLine.isHidden = true
        eventDescription.font = UIFont.collectionFirstDescriptionFont
        eventDescription.text = NSLocalizedString("REGISTER_GREETING_MESSAGE", comment: "REGISTER_GREETING_MESSAGE Label in the Popup")
        
        let buttonTitle = NSLocalizedString("POPUP_ADD_BUTTON_TITLE", comment: "POPUP_ADD_BUTTON_TITLE Label in the Popup")
        addToCalendarButton.setTitle(buttonTitle, for: .normal)
    }
    @IBAction func didTapEventCloseButton(_ sender: UIButton) {
        eventPopupDelegate?.eventCloseButtonPressed()
        self.closeButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    @IBAction func eventCloseTouchDown(_ sender: UIButton) {
        self.closeButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    @IBAction func didTapAddToCalendar(_ sender: UIButton) {
        eventPopupDelegate?.addToCalendarButtonPressed()
         self.addToCalendarButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    @IBAction func addToCalendarTouchDown(_ sender: UIButton) {
        self.addToCalendarButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
}
