//
//  BenefitLabelCell.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 22/08/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
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

