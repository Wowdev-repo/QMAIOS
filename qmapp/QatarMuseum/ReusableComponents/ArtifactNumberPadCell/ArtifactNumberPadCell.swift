//
//  ArtifactNumberPadCell.swift
//  QatarMuseums
//
//  Created by Wakralab on 20/08/18.
//  Copyright © 2018 Qatar museums. All rights reserved.
//

import UIKit
import CocoaLumberjack

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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        innerView.layer.borderWidth = 2.0
        innerView.layer.borderColor = UIColor.numberPadColor.cgColor
        numLabel.font = UIFont.artifactNumberFont
    }
}
