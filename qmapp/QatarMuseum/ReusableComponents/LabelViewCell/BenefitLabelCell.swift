//
//  BenefitLabelCell.swift
//  QatarMuseums
//
//  Created by Developer on 22/08/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit

class BenefitLabelCell: UITableViewCell {
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var benefitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        // Initialization code
    }
    
    func setUpUI() {
        benefitLabel.font = UIFont.englishTitleFont
    }
}

