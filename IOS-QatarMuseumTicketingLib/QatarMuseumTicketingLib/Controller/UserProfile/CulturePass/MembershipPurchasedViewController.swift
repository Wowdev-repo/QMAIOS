//
//  MembershipPurchasedViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 16/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
import SwiftyJSON

class MembershipPurchasedViewController: UIViewController,QMTLTabViewControllerDelegate,APIServiceResponse, APIServiceProtocolForConnectionError {

    //MARK:- Decleration
    var tabViewController = QMTLTabViewController()
    var apiServices = QMTLAPIServices()
    
    var checkoutBasketResponseJsonValue : JSON = []
    
    var paymentId = ""
    
    //MARK:- IBOutlet
    
    @IBOutlet weak var thumbnailImgView: UIImageView!
    @IBOutlet weak var memberShipNameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var memberIdLbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var inContainerView: UIView!
    @IBOutlet weak var dotViewOne: UIView!
    @IBOutlet weak var dotViewTwo: UIView!
    
    @IBOutlet weak var transactionIdLbl: UILabel!
    @IBOutlet weak var paymentMethodLbl: UILabel!
    @IBOutlet weak var transactionIdHeadLbl: UILabel!
    @IBOutlet weak var paymentMethodHeadLbl: UILabel!
    
    @IBOutlet weak var i_titleLbl: UILabel!
    @IBOutlet weak var i_subTitleLbl: UILabel!
    
    @IBOutlet weak var okBtn: UIButton!

    
    //MARK:- Controller Defaults
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:false)
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets.top = 20
        }
        apiServices.delegateForConnectionError = self
        apiServices.delegateForAPIServiceResponse = self
        
        stupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabViewController =  self.navigationController?.tabBarController as! QMTLTabViewController
        tabViewController.qmtlTabViewControllerDelegate = self
        tabViewController.topTabBarView.myProfileBtn.isHidden = false
        QMTLSingleton.sharedInstance.userInfo.isSubscribed = true
    }
    
    func stupView(){
        localizationSetup()
        
        transactionIdLbl.text = paymentId
        
        containerView.layer.cornerRadius = 10.0
        inContainerView.layer.cornerRadius = 10.0
        dotViewOne.layer.cornerRadius = 10.0
        dotViewTwo.layer.cornerRadius = 10.0
        okBtn.layer.cornerRadius = 25;

        
        drawDottedLine(start: CGPoint(x: 0, y: inContainerView!.frame.size.height - 0.2), end: CGPoint(x: self.view.frame.size.width, y: inContainerView!.frame.size.height - 0.2), view: inContainerView!)
        
        let imgURLStr = "\(QMTLConstants.GantnerAPI.baseImgURLTest + QMTLSingleton.sharedInstance.memberShipInfo.division.imgUrl)"
        thumbnailImgView.kf.indicatorType = .activity
        thumbnailImgView.kf.setImage(with: URL(string: imgURLStr))

        memberShipNameLbl.text = getLocalizedStr(str: QMTLSingleton.sharedInstance.memberShipInfo.division.name)
        userNameLbl.text = QMTLSingleton.sharedInstance.userInfo.name
        
        if (QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.parentId != "") {
            apiServices.cancelMembershipSubscription(subscriptionIdStr: QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.parentId, serviceFor: QMTLConstants.ServiceFor.CancelSubscription, view: self.view)
        } else {
            apiServices.checkoutBasketForMembership(searchCriteria: [:], serviceFor:QMTLConstants.ServiceFor.checkoutBasketForMembership , view: self.view)
        }
        
        
        if paymentId.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            transactionIdLbl.isHidden = true
            paymentMethodLbl.isHidden = true
        }else{
            transactionIdLbl.isHidden = false
            paymentMethodLbl.isHidden = false
        }
    }
    
    //MARK:-
    
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(red: 221.0/255.0, green: 221.0/255.0, blue: 221.0/255.0, alpha: 1.0).cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [7, 3] // 7 is the length of dash, 3 is length of the gap.
        
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }

    //MARK:- API Service Delegate
    
    func connectionError(ConnectionErrInfo errInfo: String?, StatusCode statusCode: Int) {
        print("Membership Purchased Error ResponseJSON = \(String(describing: errInfo))")
    }
    
    func responseWith(ResponseJSON json: JSON, StatusCode statusCode: Int, ServiceFor serviceFor: String) {
        print("\(serviceFor) Success ResponseJSON = \(json)")
        
        if statusCode == 200 {
            switch serviceFor {
            case QMTLConstants.ServiceFor.CancelSubscription:
                apiServices.checkoutBasketForMembership(searchCriteria: [:], serviceFor:QMTLConstants.ServiceFor.checkoutBasketForMembership , view: self.view)
                break
            case QMTLConstants.ServiceFor.checkoutBasketForMembership:
                checkoutBasketResponseJsonValue = json
                checkoutBasket()
                break
            default:
                break
            }
        }
        
        
    }
    
    func checkoutBasket(){
        
        let result = checkoutBasketResponseJsonValue[QMTLConstants.BasketKey.result].dictionaryValue
        let validationResult = result[QMTLConstants.BasketKey.basketValidationResult]?.dictionaryValue
        let isValid = validationResult![QMTLConstants.BasketKey.isValid]?.boolValue
        if !isValid! {
        }else{

            self.apiServices.cpPurchaseMail(toEmail: QMTLSingleton.sharedInstance.userInfo.email, type: QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.name, username: QMTLConstants.QMAPI.userName, password: QMTLConstants.QMAPI.password, serviceFor: QMTLConstants.ServiceFor.CPPurchaseMail, view: self.view)

            
            let salesItems = result[QMTLConstants.BasketKey.salesItems]?.arrayValue
            
            for salesItemObj in salesItems! {
                
                let salesDetails = salesItemObj[QMTLConstants.BasketKey.saleDetails].arrayValue
                var index = 0
                for _ in salesDetails {
                    
                    memberIdLbl.text = "\(getLocalizedStr(str: "Membership ID")) \(salesItemObj[QMTLConstants.BasketKey.barcodes].arrayValue[index].stringValue)"
                    
                    dateLbl.text = dateToString(date: stringToDate(dateStr: salesItemObj[QMTLConstants.BasketKey.date].stringValue))
                    
                    index = index + 1
                }
            }
        }
        
    }
    
    
    func stringToDate(dateStr : String) -> Date{
        
        let string = dateStr
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: string) ?? Date()
        return date
    }
    
    func dateToString(date : Date) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    
    //MARK:- IBAction
    @IBAction func okBtnAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    

    //MARK:- TabBar Delegate
    
    func backBtnSelected() {
        self.navigationController?.popToRootViewController(animated: false)
    }
    func moveToTabRoot() {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    func localizationSetup(){
        
        transactionIdLbl.decideTextDirection()
        paymentMethodLbl.decideTextDirection()
        transactionIdHeadLbl.decideTextDirection()
        paymentMethodHeadLbl.decideTextDirection()
        
        i_titleLbl.text = getLocalizedStr(str: i_titleLbl.text!)
        i_subTitleLbl.text = getLocalizedStr(str: i_subTitleLbl.text!)
        
        transactionIdLbl.text = getLocalizedStr(str: transactionIdLbl.text!)
        paymentMethodLbl.text = getLocalizedStr(str: paymentMethodLbl.text!)
        transactionIdHeadLbl.text = getLocalizedStr(str: transactionIdHeadLbl.text!)
        paymentMethodHeadLbl.text = getLocalizedStr(str: paymentMethodHeadLbl.text!)
        
        okBtn.setTitle(getLocalizedStr(str: okBtn.titleLabel!.text!), for: .normal)
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
