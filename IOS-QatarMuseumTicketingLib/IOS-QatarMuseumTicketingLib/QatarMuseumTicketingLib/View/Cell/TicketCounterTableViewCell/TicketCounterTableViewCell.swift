//
//  ticketCounterTableViewCell.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 30/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit

protocol TicketCounterTableViewCellDelegate :  class{
    func ticketCountBtnTapped(cell : TicketCounterTableViewCell)
    func showOrHideDescBtnTapped(cell : TicketCounterTableViewCell)
}

class TicketCounterTableViewCell: UITableViewCell {

    var ticketCounterTableViewCellDelegate : TicketCounterTableViewCellDelegate?
    
    var descShowingInPriceItem = PriceItem()
    
    var isDescShowing = false
    
    @IBOutlet weak var priceTypeNameLbl:UILabel!
    @IBOutlet weak var unitPriceLbl:UILabel!
    @IBOutlet weak var totalAmountLbl:UILabel!
    
    @IBOutlet weak var ticketCountBtn:UIButton!
    @IBOutlet weak var showOrHideDescBtn:UIButton!
    
    @IBOutlet weak var containerView:UIView!
    @IBOutlet weak var roundViewOne:UIView!
    @IBOutlet weak var roundViewTwo:UIView!
    
    @IBOutlet weak var seperatorImgView:UIImageView!
    @IBOutlet weak var descLblView : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- IBAction
    
    @IBAction func ticketCountBtnAction(_ sender: Any) {
       print("ticketCountBtnAction")
        ticketCounterTableViewCellDelegate?.ticketCountBtnTapped(cell: self)
    }
    
    @IBAction func showOrHideDescBtnAction(_ sender: Any) {
        print("showOrHideDescBtnAction")
        ticketCounterTableViewCellDelegate?.showOrHideDescBtnTapped(cell: self)
    }

}
