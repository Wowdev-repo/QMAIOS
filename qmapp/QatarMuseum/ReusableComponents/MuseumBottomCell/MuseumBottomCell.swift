//
//  MuseumBottomCell.swift
//  QatarMuseums
//
//  Created by Exalture on 23/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit

class MuseumBottomCell: UICollectionViewCell {
    
    @IBOutlet weak var itemButton: UIButton!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemNameSecondLine: UILabel!
    var cellItemBtnTapAction : (()->())?
    
    @IBOutlet weak var cellView: UIView!
    override func awakeFromNib() {
        itemName.font = UIFont.eventDescriptionFont
    }
    @IBAction func didTapCellButton(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.2,
                         animations: {
                            self.cellView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.1, animations: {
                                self.cellView.transform = CGAffineTransform.identity
                                
                            })
                            self.cellItemBtnTapAction?()
        })
        
    }
    
    @IBAction func cellButtonTouchDown(_ sender: UIButton) {
        //self.itemButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
       
    }
}
