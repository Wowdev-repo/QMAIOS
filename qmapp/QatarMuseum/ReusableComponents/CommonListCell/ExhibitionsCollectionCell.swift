//
//  ExhibitionsCollectionCell.swift
//  QatarMuseum
//
//  Created by Exalture on 10/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Kingfisher
import UIKit
import CocoaLumberjack

class ExhibitionsCollectionCell: UITableViewCell {
    @IBOutlet weak var exhibitionImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var openCloseView: UIView!
    @IBOutlet weak var openCloseLabel: UILabel!
    var isFavourite : Bool = false
    var exhibitionCellItemBtnTapAction : (()->())?
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            titleLabel.textAlignment = .left
            dateLabel.textAlignment = .left
            addressLabel.textAlignment = .left
        } else {
            titleLabel.textAlignment = .right
            dateLabel.textAlignment = .right
            addressLabel.textAlignment = .right
        }
    }
    //MARK: HomeExhibitionList data
    func setExhibitionCellValues(exhibition: Exhibition) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        setGradientLayer()
        openCloseView.layer.cornerRadius = 12
        titleLabel.text = exhibition.name?.uppercased()
        //Hide Date and Location from Exhibition List page.
//        dateLabel.text = ((exhibition.startDate?.uppercased())!).replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) + " - " + ((exhibition.endDate?.uppercased())!).replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        //addressLabel.text = exhibition.location?.uppercased()
        
        dateLabel.text = exhibition.displayDate
        titleLabel.font = UIFont.heritageTitleFont
        dateLabel.font = UIFont.downloadLabelFont
        addressLabel.font = UIFont.exhibitionDateLabelFont
        if (exhibition.isFavourite == true) {
            favouriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
        } else {
            favouriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
        }
        openCloseView.isHidden = false
        openCloseLabel.isHidden = false
        openCloseLabel.font = UIFont.closeButtonFont
        let nowOpenString = NSLocalizedString("NOW_OPEN_TITLE", comment: "NOW_OPEN_TITLE in the exhibition page")
        if (exhibition.status?.lowercased() == nowOpenString.lowercased())  {
            openCloseView.backgroundColor = UIColor.yellow
            openCloseLabel.text = exhibition.status
            openCloseLabel.textColor = UIColor.black
        } else {
            openCloseView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.45)
            openCloseLabel.text = exhibition.status
            openCloseLabel.textColor = UIColor.white
        }
        if let imageUrl = exhibition.image {
            exhibitionImageView.kf.setImage(with: URL(string: imageUrl))
        }
        if (exhibitionImageView.image == nil) {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
    }
    
    //MARK: MuseumExhibitionList data
    func setMuseumExhibitionCellValues(exhibition: Exhibition) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        setGradientLayer()
        openCloseView.layer.cornerRadius = 12
        titleLabel.text = exhibition.name?.uppercased()
        dateLabel.text = ((exhibition.startDate?.uppercased())!).replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) + " - " + ((exhibition.endDate?.uppercased())!).replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        addressLabel.text = exhibition.location?.uppercased()
        titleLabel.font = UIFont.heritageTitleFont
        dateLabel.font = UIFont.downloadLabelFont
        addressLabel.font = UIFont.exhibitionDateLabelFont
        if (exhibition.isFavourite == true) {
            favouriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
        } else {
            favouriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
        }
        let nowOpenString = NSLocalizedString("NOW_OPEN_TITLE", comment: "NOW_OPEN_TITLE in the exhibition page")
        if (exhibition.status?.lowercased() == nowOpenString.lowercased()) {
            openCloseView.backgroundColor = UIColor.yellow
            openCloseLabel.text = exhibition.status
            openCloseLabel.textColor = UIColor.black
        } else {
            openCloseView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.45)
            openCloseLabel.text = exhibition.status
            openCloseLabel.textColor = UIColor.white
        }
        if let imageUrl = exhibition.image {
            // exhibitionImageView.kf.indicatorType = .activity
            exhibitionImageView.kf.setImage(with: URL(string: imageUrl))
        }
        if (exhibitionImageView.image == nil) {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
    }
    
    func setGradientLayer() {
        self.exhibitionImageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let width = self.bounds.width
        let height = self.bounds.height
        let sHeight:CGFloat = 110.0
        let shadow = UIColor.black.withAlphaComponent(0.8).cgColor
        
        let bottomImageGradient = CAGradientLayer()
        bottomImageGradient.frame = CGRect(x: 0, y: height - sHeight, width: width, height: sHeight)
        bottomImageGradient.colors = [UIColor.clear.cgColor, shadow]
        exhibitionImageView.layer.insertSublayer(bottomImageGradient, at: 0)
    }
    
    @IBAction func didTapExhibitionCellButton(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        exhibitionCellItemBtnTapAction?()
        self.favouriteButton.transform = CGAffineTransform(scaleX:1, y: 1)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    @IBAction func favoriteTouchDownPressed(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.favouriteButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        if (isFavourite) {
            favouriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
            isFavourite = false
        } else {
            favouriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
            isFavourite = true
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    
}
