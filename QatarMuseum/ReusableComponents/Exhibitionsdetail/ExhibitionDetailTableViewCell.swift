//
//  ExhibitionDetailTableViewCell.swift
//  QatarMuseums
//
//  Created by Exalture on 12/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit

class ExhibitionDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var detailSecondLabel: UILabel!
    @IBOutlet weak var exbtnDateLabel: UILabel!
    @IBOutlet weak var exbtnTimeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var exhibitionTimingTitle: UILabel!
    @IBOutlet weak var locationsTitle: UILabel!
    @IBOutlet weak var contactTitle: UILabel!
    @IBOutlet weak var contactDescriptionLabel: UILabel!
    @IBOutlet weak var centerImageView: UIImageView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var centerImgHeight: NSLayoutConstraint!
    
    var favBtnTapAction : (()->())?
    var shareBtnTapAction : (()->())?
    var locationButtonAction: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellUI()
    }

    func setupCellUI() {
        titleLabel.textAlignment = .center
        descriptionLabel.textAlignment = .center
        detailSecondLabel.textAlignment = .center
        exhibitionTimingTitle.textAlignment = .center
        exbtnDateLabel.textAlignment = .center
        exbtnTimeLabel.textAlignment = .center
        locationsTitle.textAlignment = .center
        locationLabel.textAlignment = .center
        contactTitle.textAlignment = .center
        contactDescriptionLabel.textAlignment = .center
        
        titleLabel.font = UIFont.settingsUpdateLabelFont
        descriptionLabel.font = UIFont.englishTitleFont
        detailSecondLabel.font = UIFont.englishTitleFont
        exhibitionTimingTitle.font = UIFont.closeButtonFont
        exbtnDateLabel.font = UIFont.sideMenuLabelFont
        exbtnTimeLabel.font = UIFont.sideMenuLabelFont
        locationsTitle.font = UIFont.closeButtonFont
        locationButton.titleLabel?.font = UIFont.sideMenuLabelFont
        contactTitle.font = UIFont.closeButtonFont
        contactDescriptionLabel.font = UIFont.sideMenuLabelFont
    }
    
    func setHomeExhibitionDetail(exhibition: Exhibition) {
        titleLabel.text = exhibition.name?.uppercased()
        descriptionLabel?.text = exhibition.shortDescription
        detailSecondLabel.text = exhibition.longDescription
        exbtnDateLabel.text = "15 MARCH 2018 - 1 JUNE 2018"
        exbtnTimeLabel.text = "Saturday to Sunday:9:00AM - 7:00PM\n Fridays: 1:30PM to 7:00PM"
        locationLabel.text = exhibition.location?.uppercased()
        centerImgHeight.constant = 0
        centerImageView.isHidden = true
    }
    
    func setMuseumExhibitionDetail() {
        titleLabel.text = "Powder And Damask"
        descriptionLabel?.text = "This exhibition showcases Islamic arms and armour from the private collection of Fadel Al Mansoori. Including both edged weapons and firearms, the objects on display range from the 17th to the 19th century, and were produced primarily in greater Turkey, Iran and India. \n Powder and Damask explores the art of craftsmanship which reached unrewcedented levels in these regions under the ottoman, Safavid and Mughal empires, and consideres these objects not only as weapons but as works of art."
        detailSecondLabel.text = "without degrading their functionality, arms and armour in Islamic lands became an art that found its place in the hands of sultans, high-ranking commanders and elite members of society."
        exbtnDateLabel.text = "27th August 2017 Until 12th May 2018"
        exbtnTimeLabel.text = "Saturday to Sunday:9:00AM - 7:00PM\n Fridays: 1:30PM to 7:00PM"
        locationLabel.text = "MUSEUM OF ISLAMIC ART"
        centerImgHeight.constant = 150
        centerImageView.isHidden = false
        centerImageView.image = UIImage(named: "powder_and_damask_2")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBAction func didTapFavouriteButton(_ sender: UIButton) {
        self.favoriteButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        favBtnTapAction?()
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        self.shareButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        shareBtnTapAction?()
    }
    
    @IBAction func favouriteTouchDown(_ sender: UIButton) {
        self.favoriteButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @IBAction func shareTouchDown(_ sender: UIButton) {
        self.shareButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @IBAction func locationTouchDown(_ sender: UIButton) {
        self.locationButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @IBAction func didTapLocation(_ sender: UIButton) {
        self.locationButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        locationButtonAction?()
    }
    
}
