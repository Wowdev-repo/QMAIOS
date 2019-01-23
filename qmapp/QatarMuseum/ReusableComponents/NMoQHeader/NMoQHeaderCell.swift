//
//  NMoQHeaderCell.swift
//  QatarMuseums
//
//  Created by Exalture on 29/11/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import UIKit

class NMoQHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var bannerImg: UIImageView!
    @IBOutlet weak var bannerTitle: UITextView!
    override func awakeFromNib() {
        bannerTitle.font = UIFont.eventPopupTitleFont
    }
    func setBannerData(bannerData: HomeBanner) {
        bannerTitle.text = bannerData.bannerTitle
        if let imageUrl = bannerData.bannerLink {
            if(imageUrl != "") {
                bannerImg.kf.setImage(with: URL(string: imageUrl))
            }else {
                bannerImg.image = UIImage(named: "default_imageX2")
            }
            
        }
        else {
            bannerImg.image = UIImage(named: "default_imageX2")
        }
    }
}
