//
//  CulturePassTableViewCell.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 12/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit

protocol CulturePassTableViewCellDelegate :  class{
    func readBenefitTapped(cell : CulturePassTableViewCell)
}

class CulturePassTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
   
    var basicBenefitDict = [Int:(String,String)]()
    var familyBenefitDict = [Int:(String,String)]()
    var plusBenefitDict = [Int:(String,String)]()
    
    var benefitDict = [Int:(String,String)]()
    
    var isBenefitOpened = false
    
    var culturePassTableViewCellDelegate : CulturePassTableViewCellDelegate?
    
    //MARK:- IBOutlet
    
    @IBOutlet weak var benefitsTblView: UITableView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var culturePassImgView: UIImageView!
    @IBOutlet weak var readBenefitsContainerView: UIView!
    @IBOutlet weak var readBenifitsBtn: UIButton!
    
    @IBOutlet weak var subscribedIndicatorLbl : UILabel!
    @IBOutlet weak var expiresOnLbl : UILabel!

    @IBOutlet weak var subscriptionName : UILabel!
    @IBOutlet weak var subscriptionAmount : UILabel!
    
    //MARK:- View Defaults
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.layer.cornerRadius = 20.0
        containerView.layer.borderColor = UIColor.gray.cgColor
        containerView.layer.borderWidth = 1.0
        
        readBenefitsContainerView.layer.cornerRadius = 10.0
        subscribedIndicatorLbl.layer.cornerRadius = 5.0
        
        benefitsTblView.dataSource = self
        benefitsTblView.delegate = self
        
        self.benefitsTblView.register(UINib(nibName: QMTLConstants.NibName.benefitsTableViewCell, bundle: QMTLSingleton.sharedInstance.bundle), forCellReuseIdentifier: QMTLConstants.CellId.BenefitsTableViewCellID)
        
        
        basicBenefitDict[0] = ("CP Tours including Marchitecture","1 Free per year")
        basicBenefitDict[1] = ("CP exclusive Workshops","1 Free per year")
        basicBenefitDict[2] = ("Community Classes with partners","No")
        basicBenefitDict[3] = ("QM F&B","10%")
        basicBenefitDict[4] = ("QM Gift shops","No")
        basicBenefitDict[5] = ("Hospitality Partner Program","No")
        basicBenefitDict[6] = ("External party events at QM","No")
        basicBenefitDict[7] = ("Health & Leisure Discounts","No")
        basicBenefitDict[8] = ("Cass Art","No")
        basicBenefitDict[9] = ("Call Center","Yes")
        basicBenefitDict[10] = ("Newsletter","Yes")
        basicBenefitDict[11] = ("Skip the line at venues","Yes")
        
        familyBenefitDict[0] = ("CP Tours including Marchitecture","5 + 1 guest inclusive free subsequent discounted")
        familyBenefitDict[1] = ("CP exclusive Workshops","5 + 1 guest inclusive free subsequent discounted")
        familyBenefitDict[2] = ("Community Classes with partners","15% discount")
        familyBenefitDict[3] = ("QM F&B","10 % IDAM - 15% Cafe’s Discount")
        familyBenefitDict[4] = ("QM Gift shops","15% discount")
        familyBenefitDict[5] = ("Hospitality Partner Program","Preferred rate")
        familyBenefitDict[6] = ("External party events at QM","5% discount")
        familyBenefitDict[7] = ("Health & Leisure Discounts","10% discount")
        familyBenefitDict[8] = ("Cass Art","10% discount")
        familyBenefitDict[9] = ("Call Center","Yes")
        familyBenefitDict[10] = ("Newsletter","Yes")
        familyBenefitDict[11] = ("Skip the line at venues","Yes")
        
        plusBenefitDict[0] = ("CP Tours including Marchitecture","5 + 1 guest inclusive free subsequent discounted")
        plusBenefitDict[1] = ("CP exclusive Workshops","5 + 1 guest inclusive free subsequent discounted")
        plusBenefitDict[2] = ("Community Classes with partners","15% discount")
        plusBenefitDict[3] = ("QM F&B","10 % IDAM - 15% Cafe’s Discount")
        plusBenefitDict[4] = ("QM Gift shops","15% discount")
        plusBenefitDict[5] = ("Hospitality Partner Program","Preferred rate")
        plusBenefitDict[6] = ("External party events at QM","5% discount")
        plusBenefitDict[7] = ("Health & Leisure Discounts","10% discount")
        plusBenefitDict[8] = ("Cass Art","10% discount")
        plusBenefitDict[9] = ("Call Center","Yes")
        plusBenefitDict[10] = ("Newsletter","Yes")
        plusBenefitDict[11] = ("Skip the line at venues","Yes")
        
        readBenifitsBtn.setTitle("\(getLocalizedStr(str: readBenifitsBtn.titleLabel!.text!))", for: .normal)
    }
    
    func setSelectedDict(dictFor : String){
        
        switch dictFor {
        case QMTLConstants.FindSubscriptionArticlesKeys.basicId :
            benefitDict = basicBenefitDict
            break
        case QMTLConstants.FindSubscriptionArticlesKeys.familyId:
            benefitDict = familyBenefitDict
            break
        case QMTLConstants.FindSubscriptionArticlesKeys.plusId:
            benefitDict = plusBenefitDict
            break
        case QMTLConstants.FindSubscriptionArticlesKeys.staffBasic:
            benefitDict = basicBenefitDict
            break
        case QMTLConstants.FindSubscriptionArticlesKeys.staffPlus:
            benefitDict = plusBenefitDict
            break
        case QMTLConstants.FindSubscriptionArticlesKeys.promoPlus:
            benefitDict = plusBenefitDict
            break
        case QMTLConstants.FindSubscriptionArticlesKeys.staffFamily:
            benefitDict = familyBenefitDict
            break
        case QMTLConstants.FindSubscriptionArticlesKeys.promoFamily:
            benefitDict = familyBenefitDict
            break
        case QMTLConstants.FindSubscriptionArticlesKeys.limEdition:
            benefitDict = familyBenefitDict
            break
        default:
            break
        }
        
        benefitsTblView.reloadData()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- UITableView DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return benefitDict.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QMTLConstants.CellId.BenefitsTableViewCellID, for: indexPath) as! BenefitsTableViewCell
        
        let Key = benefitDict[indexPath.row]?.0
        let value = benefitDict[indexPath.row]?.1
        
        cell.titleLbl.text = Key
        cell.valueLbl.text = ""
        
        if value == "Yes" {
            let image = UIImage(named: "yes.png",
                                in: QMTLSingleton.sharedInstance.bundle,
                                compatibleWith: nil)
            cell.indicationImgView.image = image
            cell.indicationImgView.isHidden = false
        }else if value == "No" {
            let image = UIImage(named: "no.png",
                                in: QMTLSingleton.sharedInstance.bundle,
                                compatibleWith: nil)
            cell.indicationImgView.image = image
            cell.indicationImgView.isHidden = false
        }else{
            cell.valueLbl.text = value
            cell.indicationImgView.isHidden = true
        }
        
        return cell
    }
    
    //MARK:- IBAction
    
    @IBAction func readBenifitsBtnAction(_ sender: Any) {
        culturePassTableViewCellDelegate?.readBenefitTapped(cell: self)
    }
    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
}
