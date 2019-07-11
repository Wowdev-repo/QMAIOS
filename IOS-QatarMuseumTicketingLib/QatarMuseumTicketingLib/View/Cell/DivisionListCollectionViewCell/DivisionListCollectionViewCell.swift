//
//  ExpositionListCollectionViewCell.swift
//  QMLibPreProduction
//
//  Created by Jeeva.S.K on 21/02/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
import FSPagerView

class DivisionListCollectionViewCell: FSPagerViewCell {

    @IBOutlet weak var divisionNameLbl: UILabel!
    @IBOutlet weak var highlighterView : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.layer.shadowRadius = 0
        
        highlighterView.layer.cornerRadius = 5.0
    }

}
