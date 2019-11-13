//
//  ReadBenefitsViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 12/04/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit

class ReadBenefitsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,QMTLTabViewControllerDelegate {
    
    //MARK:- Decleration
    var tabViewController = QMTLTabViewController()
    var subscriptionArticle = SubscriptionArticle()
    
    var basicBenefitDict = [Int:(String,String)]()
    var familyBenefitDict = [Int:(String,String)]()
    var plusBenefitDict = [Int:(String,String)]()
    
    var benefitDict = [Int:(String,String)]()
    
    var isFromSignUpPage = false
    
    //MARK:- IBOutlet
    
    @IBOutlet weak var headerImg : UIImageView!
    @IBOutlet weak var benefitsTableView : UITableView!
    @IBOutlet weak var memberShipName : UILabel!
    @IBOutlet weak var costLbl : UILabel!
    @IBOutlet weak var expiryDate : UILabel!
    @IBOutlet weak var subscribeIndicator : UILabel!
    @IBOutlet weak var i_BenefitsLbl : UILabel!
    
    //MARK:- View Defaults
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated:false)
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets.top = 20
        }
        // Do any additional setup after loading the view.
        
        setUpBenefitsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabViewController =  self.navigationController?.tabBarController as! QMTLTabViewController
        tabViewController.qmtlTabViewControllerDelegate = self
        tabViewController.topTabBarView.myProfileBtn.isHidden = true
        setUpView()
    }
    
    func setUpView(){
        
        localizationSetup()
        
        memberShipName.text = "\(getLocalizedStr(str: subscriptionArticle.name))"
        if subscriptionArticle.price == 0 {
             costLbl.text = getLocalizedStr(str: "Free")
        }else{
            costLbl.text = "QAR \(subscriptionArticle.price)"
        }
        
        
        let imgURLStr = "\(QMTLConstants.GantnerAPI.baseImgURLTest + subscriptionArticle.imgUrl)"
        //let url = URL(string: imgURLStr)
        //cell.culturePassImgView?.kf.setImage(with: url)
        
        headerImg?.kf.indicatorType = .activity
        headerImg?.kf.setImage(with: URL(string: imgURLStr))
        headerImg.layer.cornerRadius = 20.0
        headerImg.layer.masksToBounds = true
        setSelectedDict(dictFor: subscriptionArticle.id)
                
        if !isFromSignUpPage {
            if subscriptionArticle.id == QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.id{
                subscribeIndicator.isHidden = false
                
                if dateToString(date: QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.endDateTime) != dateToString(date: Date()){
                    expiryDate.text = "Valid for 1 year"
                }else{
                    expiryDate.text = ""
                }
            }else{
                subscribeIndicator.isHidden = true
                expiryDate.text = ""
            }
        }else{
            subscribeIndicator.isHidden = true
            expiryDate.text = ""
        }
        
        
    }
    
    func dateToString(date : Date) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func setUpBenefitsData(){
        basicBenefitDict[0] = ("FREE UNLIMITED MUSEUM ADMISSION","No")
        basicBenefitDict[1] = ("CP TOURS INCLUDING MARCHITECTURE","1 FREE PER YEAR")
        basicBenefitDict[2] = ("CP EXCLUSIVE WORKSHOPS","1 FREE PER YEAR")
        basicBenefitDict[3] = ("QM F&B","10% IDAM (LUNCH ONLY), 15% CAFÉS & KIOSKS")
        basicBenefitDict[4] = ("QM GIFT SHOPS","10% DISCOUNT")
        basicBenefitDict[5] = ("INQ-ONLINE SHOP","10% DISCOUNT")
        basicBenefitDict[6] = ("CASS ART QATAR","10% DISCOUNT")
        basicBenefitDict[7] = ("COMMUNITY CLASSES WITH PARTNERS","No")
        basicBenefitDict[8] = ("HEALTH & LEISURE DISCOUNTS","No")
        basicBenefitDict[9] = ("EXTERNAL PARTY EVENTS AT QM","No")
        basicBenefitDict[10] = ("Newsletter","Yes")
        basicBenefitDict[11] = ("SKIP THE LINE AT VENUES","Yes")
        
        familyBenefitDict[0] = ("FREE UNLIMITED MUSEUM ADMISSION","Yes")
        familyBenefitDict[1] = ("CP TOURS INCLUDING MARCHITECTURE","Unlimited tours Including Marchitecture")
        familyBenefitDict[2] = ("CP EXCLUSIVE WORKSHOPS","Unlimited workshops")
        familyBenefitDict[3] = ("QM F&B","10% IDAM (LUNCH ONLY), 15% CAFÉS & KIOSKS")
        familyBenefitDict[4] = ("QM GIFT SHOPS","20% DISCOUNT")
        familyBenefitDict[5] = ("INQ-ONLINE SHOP","20% DISCOUNT")
        familyBenefitDict[6] = ("CASS ART QATAR","15% DISCOUNT")
        familyBenefitDict[7] = ("COMMUNITY CLASSES WITH PARTNERS","15% DISCOUNT")
        familyBenefitDict[8] = ("HEALTH & LEISURE DISCOUNTS","10% DISCOUNT")
        familyBenefitDict[9] = ("EXTERNAL PARTY EVENTS AT QM","5% DISCOUNT")
        familyBenefitDict[10] = ("Newsletter","Yes")
        familyBenefitDict[11] = ("SKIP THE LINE AT VENUES","Yes")
        
        plusBenefitDict[0] = ("FREE UNLIMITED MUSEUM ADMISSION","Yes")
        plusBenefitDict[1] = ("CP TOURS INCLUDING MARCHITECTURE","Unlimited tours Including Marchitecture")
        plusBenefitDict[2] = ("CP EXCLUSIVE WORKSHOPS","Unlimited workshops")
        plusBenefitDict[3] = ("QM F&B","10% IDAM (LUNCH ONLY), 15% CAFÉS & KIOSKS")
        plusBenefitDict[4] = ("QM GIFT SHOPS","20% DISCOUNT")
        plusBenefitDict[5] = ("INQ-ONLINE SHOP","20% DISCOUNT")
        plusBenefitDict[6] = ("CASS ART QATAR","15% DISCOUNT")
        plusBenefitDict[7] = ("COMMUNITY CLASSES WITH PARTNERS","15% DISCOUNT")
        plusBenefitDict[8] = ("HEALTH & LEISURE DISCOUNTS","10% DISCOUNT")
        plusBenefitDict[9] = ("EXTERNAL PARTY EVENTS AT QM","5% DISCOUNT")
        plusBenefitDict[10] = ("Newsletter","Yes")
        plusBenefitDict[11] = ("SKIP THE LINE AT VENUES","Yes")
        
    }
    
    func setSelectedDict(dictFor : String){
        
        switch dictFor {
        case QMTLConstants.FindSubscriptionArticlesKeys.basicId, QMTLConstants.FindSubscriptionArticlesKeys.basicIdProd :
            benefitDict = basicBenefitDict
            break
        case QMTLConstants.FindSubscriptionArticlesKeys.familyId,QMTLConstants.FindSubscriptionArticlesKeys.familyIdProd :
            benefitDict = familyBenefitDict
            break
        case QMTLConstants.FindSubscriptionArticlesKeys.plusId,QMTLConstants.FindSubscriptionArticlesKeys.plusIdProd :
            benefitDict = plusBenefitDict
            break
        default:
            break
        }
        
        benefitsTableView.reloadData()
        
    }
    
    //MARK:- TabBar Delegate
    
    func backBtnSelected() {
        
        self.navigationController?.popViewController(animated: false)
        
    }
    
    func moveToTabRoot() {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    //MARK:- UITableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return benefitDict.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QMTLConstants.CellId.BenefitsTableViewCellID)
        
        let Key = benefitDict[indexPath.row]?.0
        let value = benefitDict[indexPath.row]?.1
        
        let titleLbl = cell?.viewWithTag(1) as! UILabel
        let valueLbl = cell?.viewWithTag(2) as! UILabel
        let indicationImgView = cell?.viewWithTag(10) as! UIImageView
        
        titleLbl.text = Key
        valueLbl.text = ""
        
        if value == "Yes" {
            let image = UIImage(named: "yes.png",
                                in: QMTLSingleton.sharedInstance.bundle,
                                compatibleWith: nil)
            indicationImgView.image = image
            indicationImgView.isHidden = false
        }else if value == "No" {
            let image = UIImage(named: "no.png",
                                in: QMTLSingleton.sharedInstance.bundle,
                                compatibleWith: nil)
            indicationImgView.image = image
            indicationImgView.isHidden = false
        }else{
            valueLbl.text = value
            indicationImgView.isHidden = true
        }

        titleLbl.decideTextDirection()
        
        /*valueLbl.decideTextDirection()
        
        if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
            valueLbl.textAlignment = .left
        }*/
        
        titleLbl.text = "\(getLocalizedStr(str: titleLbl.text!))"
        valueLbl.text = "\(getLocalizedStr(str: valueLbl.text!))"
        
        return cell!
    }
    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    func localizationSetup(){
        
        memberShipName.decideTextDirection()
        costLbl.decideTextDirection()
        expiryDate.decideTextDirection()
        subscribeIndicator.decideTextDirection()
        subscribeIndicator.text = NSLocalizedString(subscribeIndicator.text!, comment: "")
        i_BenefitsLbl.text = NSLocalizedString(i_BenefitsLbl.text!,comment: "")
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
