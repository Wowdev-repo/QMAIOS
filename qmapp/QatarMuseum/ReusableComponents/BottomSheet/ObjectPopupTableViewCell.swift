//
//  ObjectPopupTableViewCell.swift
//  QatarMuseums
//
//  Created by Wakralab on 10/09/18.
//  Copyright © 2018 Qatar museums. All rights reserved.
//

import UIKit
import CocoaLumberjack

class ObjectPopupTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var popupImgeView: UIImageView!
    
    @IBOutlet weak var productionTitle: UILabel!
    @IBOutlet weak var productionDateTitle: UILabel!
    @IBOutlet weak var periodTitle: UILabel!
    @IBOutlet weak var productionText: UILabel!
    @IBOutlet weak var productionDateText: UILabel!
    @IBOutlet weak var periodText: UILabel!
    @IBOutlet weak var viewDetailsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setPopupDetails(mapDetails: TourGuideFloorMap) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        title.text = mapDetails.title?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&#039;", with: "", options: .regularExpression, range: nil)
        productionTitle.text = NSLocalizedString("PRODUCTION_LABEL", comment: "PRODUCTION_LABEL  in the Popup")
        productionDateTitle.text = NSLocalizedString("PRODUCTION_DATES_LABEL", comment: "PRODUCTION_DATES_LABEL  in the Popup")
        periodTitle.text = NSLocalizedString("PERIOD_STYLE_LABEL", comment: "PERIOD_STYLE_LABEL  in the Popup")
        viewDetailsLabel.text = NSLocalizedString("VIEW_DETAIL_BUTTON_TITLE", comment: "VIEW_DETAIL_BUTTON_TITLE  in the Popup")
        
        productionText.text = mapDetails.production
        productionDateText.text = mapDetails.productionDates
        periodText.text = mapDetails.periodOrStyle
        
        if let imageUrl = mapDetails.image {
            popupImgeView.kf.setImage(with: URL(string: imageUrl))
        }
        if(popupImgeView.image == nil) {
            popupImgeView.image = UIImage(named: "default_imageX2")
        }
        title.font = UIFont.tryAgainFont
        productionTitle.font = UIFont.eventCellTitleFont
        productionDateTitle.font = UIFont.eventCellTitleFont
        periodTitle.font = UIFont.eventCellTitleFont
        productionText.font = UIFont.downloadLabelFont
        productionDateText.font = UIFont.downloadLabelFont
        periodText.font = UIFont.downloadLabelFont
        viewDetailsLabel.font = UIFont.downloadLabelFont
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
