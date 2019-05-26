//
//  DiningDetailTableViewCell.swift
//  QatarMuseums
//
//  Created by Exalture on 29/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit
import CocoaLumberjack

class DiningDetailTableViewCell: UITableViewCell,UITextViewDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeTitleLabel: UILabel!
    @IBOutlet weak var locationsTitleLabel: UILabel!
    @IBOutlet weak var titleDescriptionLabel: UITextView!
    @IBOutlet weak var timeDescriptionLabel: UILabel!
    @IBOutlet weak var titleLineView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var locationFirstLabel: UILabel!
    @IBOutlet weak var visitMIAText: UITextView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var favoriteBtnViewHeight: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!

    var favBtnTapAction : (()->())?
    var shareBtnTapAction : (()->())?
    var locationButtonAction: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        favoriteBtnViewHeight.constant = 0
    }
    
    func setDiningDetailValues(diningDetail: Dining) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        titleLabel.text = diningDetail.name?.uppercased()
        titleDescriptionLabel.text = diningDetail.description?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        timeTitleLabel.isHidden = false
        let toVariable = NSLocalizedString("TO",
                                           comment: "TO in the Dining detail")
        if ((diningDetail.openingtime != nil) && (diningDetail.closetime != nil)) {
            timeDescriptionLabel.text = (diningDetail.openingtime)! + " " + toVariable + " " + (diningDetail.closetime)!
        }
        
        titleLineView.isHidden = false
        locationsTitleLabel.isHidden = false
        locationButton.isHidden = false
        timeTitleLabel.text = NSLocalizedString("OPENING_TIME_TITLE",
                                                comment: "OPENING_TIME_TITLE in the Heritage detail")
        locationsTitleLabel.text = NSLocalizedString("LOCATION_TITLE",
                                                     comment: "LOCATION_TITLE in the Dining detail")
        titleLabel.font = UIFont.eventPopupTitleFont
        titleDescriptionLabel.font = UIFont.englishTitleFont
        timeTitleLabel.font = UIFont.closeButtonFont
        timeDescriptionLabel.font = UIFont.sideMenuLabelFont
        locationsTitleLabel.font = UIFont.closeButtonFont
        locationFirstLabel.font = UIFont.sideMenuLabelFont
        locationButton.titleLabel?.font = UIFont.sideMenuLabelFont
        let mapRedirectionMessage = NSLocalizedString("MAP_REDIRECTION_MESSAGE",
                                                      comment: "MAP_REDIRECTION_MESSAGE in the Dining detail")
        locationButton.setTitle(mapRedirectionMessage, for: .normal)
        locationFirstLabel.text = diningDetail.location
        //For HyperLink in textview
        /*
        let yourAttributes = [kCTForegroundColorAttributeName: UIColor.black, kCTFontAttributeName: UIFont.englishTitleFont]
        let moreInformationMessage = NSLocalizedString("MORE_INFORMATION_MESSAGE",
                                                       comment: "MORE_INFORMATION_MESSAGE in the Dining detail")
        let partOne = NSMutableAttributedString(string: moreInformationMessage, attributes: yourAttributes as [NSAttributedStringKey : Any])
        let yourAttributes2 = [kCTForegroundColorAttributeName: UIColor.viewMyFavDarkPink, kCTFontAttributeName: UIFont.englishTitleFont]
        let miaString = NSLocalizedString("MIA_TITLE",
                                          comment: "MIA_TITLE in the Dining detail")
        let parttwo = NSMutableAttributedString(string: miaString, attributes: yourAttributes2 as [NSAttributedStringKey : Any])
        let combination = NSMutableAttributedString()
        combination.append(partOne)
        combination.append(parttwo)
        
         let linkAttributes: [NSAttributedStringKey: Any] = [
                    .link: NSURL(string: "http://www.mia.org.qa/en/visiting/idam")!,
                    NSAttributedStringKey.foregroundColor: UIColor.profilePink,
                    NSAttributedStringKey.underlineStyle: NSNumber.init(value: Int8(NSUnderlineStyle.styleSingle.rawValue)),
                    NSAttributedStringKey.font : UIFont.englishTitleFont
                ]
        
        combination.setAttributes(linkAttributes, range: NSMakeRange(53, 4))
        self.visitMIAText.delegate = self
        
        self.visitMIAText.attributedText = combination
        self.visitMIAText.isUserInteractionEnabled = true
        self.visitMIAText.isEditable = false
        visitMIAText.tintColor = UIColor.viewMyFavDarkPink
        self.visitMIAText.textAlignment = .center
 */
        titleDescriptionLabel.textAlignment = .center
       

    }
    @IBAction func didTapFavouriteButton(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.favoriteButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.1, animations: {
                                self.favoriteButton.transform = CGAffineTransform.identity
                                
                            })
                            self.favBtnTapAction?()
        })
        
    }
    @IBAction func didTapShareButton(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.shareButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.1, animations: {
                                self.shareButton.transform = CGAffineTransform.identity
                                
                            })
                            self.shareBtnTapAction?()
        })
        
    }
   
    @IBAction func didTapLocation(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
         self.locationButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.locationButtonAction?()
        
    }
    
    @IBAction func locationButtonTouchDown(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.locationButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
