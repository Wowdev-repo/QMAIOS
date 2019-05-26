//
//  NMoQParkTopTableViewCell.swift
//  QatarMuseums
//
//  Created by Exalture on 22/03/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import UIKit
import CocoaLumberjack

class NMoQParkTopTableViewCell: UITableViewCell {
    @IBOutlet weak var topCellLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setTopCellDescription (topDescription: String?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        topCellLabel?.numberOfLines = 0
        selectionStyle = .none
        textLabel?.textAlignment = .center
        backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        topCellLabel!.font = UIFont.collectionFirstDescriptionFont
        topCellLabel.text = topDescription?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil)
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
