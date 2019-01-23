//
//  CollectionDetailCell.swift
//  QatarMuseums
//
//  Created by Exalture on 18/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit

class CollectionDetailCell: UITableViewCell {
    @IBOutlet weak var firstTitle: UILabel!
    @IBOutlet weak var firstDescription: UITextView!
    @IBOutlet weak var secondTitle: UITextView!
    @IBOutlet weak var secondSubTitle: UITextView!
    @IBOutlet weak var secondDescription: UITextView!
    @IBOutlet weak var thirdDescription: UITextView!
    @IBOutlet weak var fourthDescription: UITextView!
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
    
    
    var favouriteButtonAction : (()->())?
    var shareButtonAction : (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        favouriteHeight.constant = 0
    }
    
    func setCollectionCellValues(collectionValues : CollectionDetail,currentRow: Int) {
        firstTitle.font = UIFont.settingsUpdateLabelFont
        firstDescription.font = UIFont.collectionFirstDescriptionFont
        secondTitle.font = UIFont.closeButtonFont
        secondSubTitle.font = UIFont.collectionSubTitleFont
        secondDescription.font = UIFont.englishTitleFont
        thirdDescription.font = UIFont.englishTitleFont
        fourthDescription.font = UIFont.englishTitleFont
        
        firstTitle.text = collectionValues.categoryCollection?.uppercased().replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        //firstDescription.text = collectionValues.collectionDescription?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil)
        secondTitle.text = collectionValues.title?.uppercased().replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        //secondSubTitle.text = collectionValues.about?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil)
        secondDescription.text = collectionValues.body?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        //thirdDescription.text = collectionValues.shortDesc?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil)
        //fourthDescription.text = collectionValues.longDesc?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil)
        if let imageUrl = collectionValues.image {
            firstImageView.kf.setImage(with: URL(string: imageUrl))
        }
        if (firstImageView.image == nil) {
            firstImageView.image = UIImage(named: "default_imageX2")
        }
//        if let imageUrl = collectionValues.imageMain {
//            secondImageView.kf.setImage(with: URL(string: imageUrl))
//        }
//        if (firstImageView.image == nil) {
//            secondImageView.image = UIImage(named: "default_imageX2")
//        }
        
        if (currentRow == 0) {
            firstTitle.isHidden = false
            firstDescription.isHidden = false
            firstTitleLine.isHidden = false
            //firstTitleTopConstraint.constant = 30
            fistViewTopConstraint.constant = 20
            titleview.isHidden = false
            titleview.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: titleview.frame.height)
            firstTitle.isHidden = false
            firstTitleLine.isHidden = false
            firstDescription.isHidden = false
            //descriptionBottomConstraint.constant = 10
            //desctionTopConstraint.constant = 13
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
    
}
