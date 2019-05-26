//
//  NMoQHeaderCell.swift
//  QatarMuseums
//
//  Created by Exalture on 29/11/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import UIKit

class NMoQHeaderCell: UITableViewCell {
    
    @IBOutlet weak var bannerImg: UIImageView!
    @IBOutlet weak var bannerTitle: UITextView!
    override func awakeFromNib() {
        bannerTitle.font = UIFont.eventPopupTitleFont
    }
    func setBannerData(bannerData: HomeBanner) {
        bannerTitle.textColor = UIColor.gray
        bannerTitle.text = bannerData.bannerTitle
        if let imageUrl = bannerData.bannerLink {
            if(imageUrl != "") {
                bannerImg.kf.setImage(with: URL(string: imageUrl))
                bannerTitle.textColor = UIColor.white
            }else {
                bannerImg.image = UIImage(named: "default_imageX2")
            }
            
        }
        else {
            bannerImg.image = UIImage(named: "default_imageX2")
        }
    }
}
