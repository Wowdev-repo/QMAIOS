//
//  NMoQTourDescriptionCell.swift
//  QatarMuseums
//
//  Created by Developer on 30/11/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import UIKit

class NMoQTourDescriptionCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }

    func setupUI() {
        titleLabel.font = UIFont.tourGuidesFont
        descriptionLabel.font = UIFont.englishTitleFont
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
