//
//  HomeCollectionViewCell.swift
//  QatarMuseum
//
//  Created by Exalture on 06/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import Kingfisher
import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var homeImageView: UIImageView!
    @IBOutlet weak var homeTitleLabel: UILabel!
    @IBOutlet weak var tourGuideImage: UIImageView!
    let networkReachability = NetworkReachabilityManager()
    override func layoutSubviews() {
        super.layoutSubviews()
        setGradientLayer()
    }
    override func awakeFromNib() {
       if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            homeTitleLabel.textAlignment = .left
        } else {
            homeTitleLabel.textAlignment = .right
        }
    }
    func setHomeCellData(home: Home) {
        let titleString = home.name
        homeTitleLabel.text = titleString
        homeTitleLabel.font = UIFont.homeTitleFont
        //Added Tour guide icon for MIA in home page
        if ((home.id == "63") || (home.id == "61") || (home.id == "66") || (home.id == "96") || (home.id == "635") || (home.id == "638")) {
            tourGuideImage.isHidden = false
        }
        else { //
            tourGuideImage.isHidden = true
        }
            if let imageUrl = home.image {
            homeImageView.kf.setImage(with: URL(string: imageUrl))
        }
        if (homeImageView.image == nil) {
            homeImageView.image = UIImage(named: "default_imageX2")
        }
    }
    
    func setScienceTourGuideCellData(homeCellData: TourGuide) {
        homeTitleLabel.font = UIFont.homeTitleFont
        homeTitleLabel.text = homeCellData.title
        tourGuideImage.isHidden = false
        if (homeCellData.nid == "12216") || (homeCellData.nid == "12226") {
            tourGuideImage.isHidden = true
        } else {
            tourGuideImage.isHidden = false
        }
        if let multimedia = homeCellData.multimediaFile{
            if (multimedia.count > 0) {
                if (homeCellData.multimediaFile![0] != nil) {
                    homeImageView.kf.setImage(with: URL(string: homeCellData.multimediaFile![0]))
                }
            }
        }
        if(homeImageView.image == nil) {
           homeImageView.image = UIImage(named: "default_imageX2")
        }
        homeImageView.contentMode = .scaleAspectFill
        
    }
    func setTourGuideCellData(museumsListData: Home) {
        homeTitleLabel.font = UIFont.homeTitleFont
        
        homeTitleLabel.text = museumsListData.name
        if (museumsListData.isTourguideAvailable == "True") {
            tourGuideImage.isHidden = false
        } else {
            tourGuideImage.isHidden = true
        }
        if let imageUrl = museumsListData.image{
            homeImageView.kf.setImage(with: URL(string: imageUrl))
        }
        if(homeImageView.image == nil) {
            homeImageView.image = UIImage(named: "default_imageX2")
        }
        
        
    }
    
    func setGradientLayer() {
        self.homeImageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let width = self.bounds.width
        let height = self.bounds.height
        let sHeight:CGFloat = 60.0
        let shadow = UIColor.black.withAlphaComponent(0.6).cgColor
        let bottomImageGradient = CAGradientLayer()
        bottomImageGradient.frame = CGRect(x: 0, y: height - sHeight, width: width, height: sHeight)
        bottomImageGradient.colors = [UIColor.clear.cgColor, shadow]
        homeImageView.layer.insertSublayer(bottomImageGradient, at: 0)
    }
}
