//
//  CollectionDetailCell.swift
//  QatarMuseums
//
//  Created by Exalture on 18/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit
import CocoaLumberjack

class CollectionDetailCell: UITableViewCell {
    @IBOutlet weak var firstTitle: UILabel!
    @IBOutlet weak var firstDescription: UITextView!
    @IBOutlet weak var secondTitle: UITextView!
    @IBOutlet weak var secondDescription: UITextView!
    @IBOutlet weak var thirdDescription: UITextView!
    @IBOutlet weak var fourthDescription: UITextView!
    //@IBOutlet weak var firstImageView: UIImageView!
    
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var favouriteHeight: NSLayoutConstraint!
    @IBOutlet weak var favouriteView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var firstTitleLine: UIView!
    @IBOutlet weak var fistViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var titleview: UIView!
    @IBOutlet weak var descriptionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstLineTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var desctionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstLineHeight: NSLayoutConstraint!
    @IBOutlet weak var firstViewHeight: NSLayoutConstraint!
    @IBOutlet weak var secondTitleLine: UILabel!
    
    
    var favouriteButtonAction : (()->())?
    var shareButtonAction : (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        favouriteHeight.constant = 0
    }
    
    func setCollectionCellValues(collectionValues : CollectionDetail,currentRow: Int) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        firstTitle.font = UIFont.settingsUpdateLabelFont
        firstDescription.font = UIFont.collectionFirstDescriptionFont
        secondTitle.font = UIFont.closeButtonFont
        secondDescription.font = UIFont.englishTitleFont
        thirdDescription.font = UIFont.englishTitleFont
        fourthDescription.font = UIFont.englishTitleFont
        secondTitleLine.isHidden = true
        firstTitle.text = collectionValues.categoryCollection?.uppercased().replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        secondTitle.text = collectionValues.title?.uppercased().replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        secondDescription.text = collectionValues.body?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        if let imageUrl = collectionValues.image {
            firstImageView.kf.setImage(with: URL(string: imageUrl))
        }
        if (firstImageView.image == nil) {
            firstImageView.image = UIImage(named: "default_imageX2")
        }
        if (currentRow == 0) {
            firstTitle.isHidden = false
            firstDescription.isHidden = false
            firstTitleLine.isHidden = false
            fistViewTopConstraint.constant = 20
            titleview.isHidden = false
            titleview.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: titleview.frame.height)
            firstTitle.isHidden = false
            firstTitleLine.isHidden = false
            firstDescription.isHidden = false
            firstLineTopConstraint.constant = 8
            firstLineHeight.constant = 3
            firstViewHeight.constant = 82
        }
        else {
            firstTitle.isHidden = true
            firstDescription.isHidden = true
            firstTitleLine.isHidden = true
            firstTitle.text = ""
            firstDescription.text = ""
            fistViewTopConstraint.constant = 0
            descriptionBottomConstraint.constant = 0
            desctionTopConstraint.constant = 0
            firstLineTopConstraint.constant = 0
            firstLineHeight.constant = 0
            titleview.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            titleview.isHidden = true
            firstTitle.isHidden = true
            firstTitleLine.isHidden = true
            firstDescription.isHidden = true
            firstViewHeight.constant = 10
        }
        
    }
    func setParkPlayGroundValues(parkPlaygroundDetails: NMoQParkDetail?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        firstTitle.font = UIFont.settingsUpdateLabelFont
        firstDescription.font = UIFont.collectionFirstDescriptionFont
        secondTitle.font = UIFont.heritageTitleFont
        secondDescription.font = UIFont.englishTitleFont
        thirdDescription.font = UIFont.englishTitleFont
        fourthDescription.font = UIFont.englishTitleFont
        
        secondTitle.text = parkPlaygroundDetails?.title?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        fourthDescription.text = parkPlaygroundDetails?.parkDesc?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        firstImageView.image = nil
        if ((parkPlaygroundDetails?.images?.count)! > 0) {
            if let imageUrl = parkPlaygroundDetails?.images![0]{
                firstImageView.kf.setImage(with: URL(string: imageUrl))
                self.layoutIfNeeded()
            }
        } else {
            firstImageView.image = UIImage(named: "default_imageX2")
        }
        if (firstImageView.image == nil) {
            firstImageView.image = UIImage(named: "default_imageX2")
        }
        
            firstTitle.isHidden = false
            firstDescription.isHidden = true
            firstTitleLine.isHidden = false
            firstTitle.text = ""
            firstDescription.text = ""
            fistViewTopConstraint.constant = 0
            descriptionBottomConstraint.constant = 0
            desctionTopConstraint.constant = 0
            firstLineTopConstraint.constant = 0
            firstLineHeight.constant = 0
            titleview.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            titleview.isHidden = true
            firstTitle.isHidden = true
            firstTitleLine.isHidden = true
            firstDescription.isHidden = true
            firstViewHeight.constant = 10
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func didTapFavourite(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
    
}
