//
//  BenefitsTableViewCell.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 25/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit

class BenefitsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLbl : UILabel!
    @IBOutlet weak var valueLbl : UILabel!
    @IBOutlet weak var indicationImgView : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
