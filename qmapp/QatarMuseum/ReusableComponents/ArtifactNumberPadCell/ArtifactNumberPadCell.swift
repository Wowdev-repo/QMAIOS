//
//  ArtifactNumberPadCell.swift
//  QatarMuseums
//
//  Created by Developer on 20/08/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit

class ArtifactNumberPadCell: UICollectionViewCell {
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var numLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        // Initialization code
    }

    func setUpUI() {
        innerView.layer.borderWidth = 2.0
        innerView.layer.borderColor = UIColor.numberPadColor.cgColor
        numLabel.font = UIFont.artifactNumberFont
    }
}
