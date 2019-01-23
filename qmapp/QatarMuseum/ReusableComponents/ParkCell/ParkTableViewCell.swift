//
//  ParkTableViewCell.swift
//  QatarMuseums
//
//  Created by Exalture on 22/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit

class ParkTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UITextView!
    @IBOutlet weak var timeTitleLabel: UILabel!
    @IBOutlet weak var locationsTitleLabel: UITextView!
    @IBOutlet weak var titleDescriptionLabel: UITextView!
    @IBOutlet weak var titleSecondDescriptionLabel: UITextView!
    @IBOutlet weak var timeDescriptionLabel: UITextView!
    @IBOutlet weak var titleLineView: UIView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var timeLineViewHeight: NSLayoutConstraint!
    @IBOutlet weak var locationLineViewHeight: NSLayoutConstraint!
    @IBOutlet weak var locationFirstLabel: UILabel!
    
    
    @IBOutlet weak var locationButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var parkImageView: UIImageView!
    @IBOutlet weak var favouriteViewHeight: NSLayoutConstraint!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var favouriteView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    
    
    @IBOutlet weak var subTitleTopConstraint: NSLayoutConstraint!
    var favouriteButtonAction : (() -> ())?
    var shareButtonAction : (() -> ())?
    var locationButtonTapAction : (() -> ())?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    //MARK: Public Arts List Data
    func setParksCellValues(parksList: ParksList,currentRow:Int?) {
        
        
        titleLabel.text = parksList.title?.uppercased()
        let parkDesc = parksList.description?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        titleDescriptionLabel.text = parkDesc?.replacingOccurrences(of: "&amp;", with: "&", options: .regularExpression, range: nil)
        
       // titleSecondDescriptionLabel.text =
        timeTitleLabel.text = NSLocalizedString("OPENING_TIME_TITLE",
                                                comment: "OPENING_TIME_TITLE in the Heritage detail")

            subTitleTopConstraint.constant = 0
            subTitleLabel.frame = CGRect(x: self.subTitleLabel.frame.origin.x, y: self.subTitleLabel.frame.origin.x, width: 0, height: 0)
            
        //}
//        if ((cellValues.value(forKey: "openingTimeDes")  != nil) && (cellValues.value(forKey: "openingTimeDes") as! String != ""))  {
//            timeTitleLabel.isHidden = false
//            timeDescriptionLabel.text = (cellValues.value(forKey: "openingTimeDes") as? String)
//            timeLineViewHeight.constant = 2
//        }
//        else {
//            timeTitleLabel.isHidden = true
//            timeDescriptionLabel.isHidden = true
//            timeLineViewHeight.constant = 0
//        }
//        if ((cellValues.value(forKey: "locationDes")  != nil) && (cellValues.value(forKey: "locationDes") as! String != ""))  {
//            locationsTitleLabel.isHidden = false
//            locationButton.isHidden = false
//            locationsTitleLabel.text =  NSLocalizedString("LOCATION_TITLE",
//                                                                                    comment: "LOCATION_TITLE in the Park detail")
//            locationButton.setTitle((cellValues.value(forKey: "locationDes") as? String), for: .normal)
//            locationLineViewHeight.constant = 2
//
//            locationButtonBottomConstraint.constant = 29
//        }
//        else {
//            locationsTitleLabel.isHidden = true
//            locationButton.isHidden = true
//            locationLineViewHeight.constant = 0
//
//            locationButtonBottomConstraint.constant = 0
//        }
        if (currentRow == 0) {
            locationsTitleLabel.isHidden = false
            locationButton.isHidden = false
            locationsTitleLabel.text =  NSLocalizedString("LOCATION_TITLE",
                                                          comment: "LOCATION_TITLE in the Park detail")
            let mapRedirectionMessage = NSLocalizedString("MAP_REDIRECTION_MESSAGE",
                                                          comment: "MAP_REDIRECTION_MESSAGE in the Dining detail")
            locationButton.setTitle(mapRedirectionMessage, for: .normal)
            locationLineViewHeight.constant = 2
            locationButtonBottomConstraint.constant = 29
        } else {
            locationsTitleLabel.isHidden = true
            locationButton.isHidden = true
            locationLineViewHeight.constant = 0
            locationButtonBottomConstraint.constant = 0
            
        }
        
        if let imageUrl = parksList.image{
            parkImageView.kf.setImage(with: URL(string: imageUrl))
        }
        
        
        
        //set font
        titleLabel.font = UIFont.closeButtonFont
        subTitleLabel.font = UIFont.collectionFirstDescriptionFont
        titleDescriptionLabel.font = UIFont.englishTitleFont
        titleSecondDescriptionLabel.font = UIFont.englishTitleFont
        timeTitleLabel.font = UIFont.closeButtonFont
        timeDescriptionLabel.font = UIFont.collectionFirstDescriptionFont
        locationFirstLabel.font = UIFont.sideMenuLabelFont
        locationButton.titleLabel?.font = UIFont.sideMenuLabelFont
        locationsTitleLabel.font = UIFont.closeButtonFont
        favouriteViewHeight.constant = 0
        favouriteView.isHidden = true
        shareView.isHidden = true
        favouriteButton.isHidden = true
        shareButton.isHidden = true
    }
   
    @IBAction func didTapFavourite(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.favouriteButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.1, animations: {
                                self.favouriteButton.transform = CGAffineTransform.identity
                                
                            })
                            self.favouriteButtonAction?()
        })
        
    }
    @IBAction func didTapShare(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.shareButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.1, animations: {
                                self.shareButton.transform = CGAffineTransform.identity
                                
                            })
                            self.shareButtonAction?()
        })
        
    }
    
    @IBAction func didTapLocation(_ sender: UIButton) {
        self.locationButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        locationButtonTapAction?()
    }
    @IBAction func locationButtonTouchDown(_ sender: UIButton) {
        self.locationButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
