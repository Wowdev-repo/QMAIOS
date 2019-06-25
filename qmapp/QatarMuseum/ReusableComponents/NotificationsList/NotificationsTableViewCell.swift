//
//  NotificationsTableViewCell.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 19/07/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import UIKit


class NotificationsTableViewCell: UITableViewCell {

    @IBOutlet weak var notificationLabel: UILabel!
    
    @IBOutlet weak var detailArrowButton: UIButton!
    @IBOutlet weak var innerView: UIView!
    
    var notificationDetailSelection : (()->())?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        detailArrowButton.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")

        // Configure the view for the selected state
    }
    @IBAction func didTapList(_ sender: UIButton) {
        notificationDetailSelection?()
    }
    
}
