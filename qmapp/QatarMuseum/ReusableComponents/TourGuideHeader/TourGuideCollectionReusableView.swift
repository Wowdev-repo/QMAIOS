//
//  TourGuideCollectionReusableView.swift
//  QatarMuseums
//
//  Created by Exalture on 17/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit

class TourGuideCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var tourGuideText: UITextView!
    @IBOutlet weak var tourGuideTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tourGuideTitle.font = UIFont.tourGuidesFont
        tourGuideText.font = UIFont.englishTitleFont
    }
}
