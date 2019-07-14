//
//  MyVisitsTableViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 15/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toast_Swift


class MyVisitsTableViewController: UITableViewController,QMTLTabViewControllerDelegate,APIServiceResponse, APIServiceProtocolForConnectionError {

    //MARK:- Decleration
    var toastStyle = ToastStyle()
    
    var tabViewController = QMTLTabViewController()
    var apiServices = QMTLAPIServices()
    
    var listDivisionsResponseJsonValue : JSON = []
    var myVisitsResponseJsonValue : JSON = []
    
    var divisionsList = [Divisions]()
    var findOranisedVisitsArr = [FindOrganisedVisit]()
    var selectedOranisedVisits = FindOrganisedVisit()
    
    @IBOutlet weak var i_titleLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:false)
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets.top = 20
        }
        apiServices.delegateForConnectionError = self
        apiServices.delegateForAPIServiceResponse = self
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 500
        
        toastStyle.messageColor = .white
        toastStyle.backgroundColor = .darkGray
        
        doAPICall()
        
        localizationSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabViewController =  self.navigationController?.tabBarController as! QMTLTabViewController
        tabViewController.qmtlTabViewControllerDelegate = self
        tabViewController.topTabBarView.backBtn.isHidden = false
        
    }
    
    func doAPICall() {
        
        if QMTLSingleton.sharedInstance.userInfo.isLoggedIn {
            apiServices.getDivisionList(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.listDivisions, view: self.view)
        }else{
            showToast(message: "No tickets available to show")
        }
        
    }
    
    //MARK:- API Service Delegate
    
    func connectionError(ConnectionErrInfo errInfo: String?, StatusCode statusCode: Int) {
        print("My Visit Error ResponseJSON = \(String(describing: errInfo))")
    }
    
    func responseWith(ResponseJSON json: JSON, StatusCode statusCode: Int, ServiceFor serviceFor: String) {
        print("\(serviceFor) Success ResponseJSON = \(json)")
        
        if statusCode == 200 {
            switch serviceFor {
            case QMTLConstants.ServiceFor.findOrganisedVisits:
                myVisitsResponseJsonValue = json
                setupMyVisitsValues()
                break
            case QMTLConstants.ServiceFor.listDivisions:
                listDivisionsResponseJsonValue = json
                setUpDivisionList()
                break
            default:
                break
            }
        }
        
        
    }
    
    func setUpDivisionList(){
        let divisionArr = listDivisionsResponseJsonValue[QMTLConstants.ListDivisionKeys.divisions].arrayValue
        
        for division in divisionArr {
            let divisionObj = Divisions()
            divisionObj.id = division[QMTLConstants.ListDivisionKeys.id].stringValue
            divisionObj.name = division[QMTLConstants.ListDivisionKeys.name].stringValue
            
            divisionsList.append(divisionObj)
        }
        
        if divisionsList.count > 0 {
            
            apiServices.findOrganisedVisits(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.findOrganisedVisits, view: self.view)
        }
        
        
    }
    
    
    func setupMyVisitsValues(){
        
        let organisedVisits = myVisitsResponseJsonValue[QMTLConstants.FindOrganisedVisitsKeys.organisedVisits].arrayValue
        
        if organisedVisits.count > 0 {
            
            for visit in organisedVisits {
                
                let findOrganisedVisit = FindOrganisedVisit()
                
                findOrganisedVisit.id = visit[QMTLConstants.FindOrganisedVisitsKeys.id].stringValue
                findOrganisedVisit.startDate = stringToDate(dateStr: visit[QMTLConstants.FindOrganisedVisitsKeys.startDate].stringValue)
                findOrganisedVisit.endDate = stringToDate(dateStr: visit[QMTLConstants.FindOrganisedVisitsKeys.endDate].stringValue)
                
                let periodReservations = visit[QMTLConstants.FindOrganisedVisitsKeys.periodReservations].arrayValue
                
                var periodItemArr = [PriceItem]()
                
                for period in periodReservations {
                    
                    let periodItem = PriceItem()
                    
                    periodItem.name = period[QMTLConstants.FindOrganisedVisitsKeys.articleName].stringValue
                    periodItem.ticketPicked = period[QMTLConstants.FindOrganisedVisitsKeys.quantity].intValue
                    findOrganisedVisit.divisionId = period[QMTLConstants.FindOrganisedVisitsKeys.divisionIdOnExposition].stringValue
                    
                    periodItemArr.append(periodItem)
                }
                
                findOrganisedVisit.periodInfo = periodItemArr
                
                findOranisedVisitsArr.append(findOrganisedVisit)
            }
            
            tableView.reloadData()
            
        }else{
            
            showToast(message: "Ticket history not available")
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
    
    func getMuseumName(divisionID : String) -> String {
        
        var museumName = ""
        
        for division in divisionsList {
            
            if division.id == divisionID {
                museumName = division.name
                break
            }
        }
        
        return museumName
    }
    
    //MARK:- Show Toast
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height/2 - 17, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.darkGray
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = getLocalizedStr(str: message)
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
//    func showToast(message : String){
//
//
//
//        self.view.makeToast(getLocalizedStr(str: message) , duration: 2.0, position: .center, style: toastStyle)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
//            self.view.hideAllToasts()
//        })
//    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return findOranisedVisitsArr.count
    }

    /*
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }*/
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QMTLConstants.CellId.myVisitsTableViewControllerCell, for: indexPath)

        // Configure the cell...
        
        let containerView = cell.viewWithTag(100)
        let statusContainerView = cell.viewWithTag(101)
        
        let statusLbl = cell.viewWithTag(10) as! UILabel
        let museumNameLbl = cell.viewWithTag(11) as! UILabel
        let dateLbl = cell.viewWithTag(12) as! UILabel
        let ticketIdLbl = cell.viewWithTag(13) as! UILabel
        let ticketInfo = cell.viewWithTag(14) as! UILabel

        ticketIdLbl.text = ""
        
        containerView?.layer.cornerRadius = 10.0
        statusContainerView?.layer.cornerRadius = 10.0
        
        let visit = findOranisedVisitsArr[indexPath.row]
        
        dateLbl.text = dateToString(date: visit.startDate)
        
        var ticketInfoStr = ""
        
        for period in visit.periodInfo {
            
            if QMTLLocalizationLanguage.currentAppleLanguage() == QMTLConstants.Language.AR_LANGUAGE {
                 ticketInfoStr = "\(getLocalizedStr(str: period.name)) x \(period.ticketPicked),\(ticketInfoStr)"
            }
            else{
                 ticketInfoStr = "\(getLocalizedStr(str: period.name)) x \(period.ticketPicked),\(ticketInfoStr)"
            }
            
           
        }
        
        ticketInfoStr.remove(at: ticketInfoStr.lastIndex(of: ticketInfoStr.last!)!)
        
        ticketInfo.text = ticketInfoStr
        
        if dateToString(date: visit.startDate) == dateToString(date: Date()){
            statusLbl.text = getLocalizedStr(str: "Today")
            statusContainerView?.backgroundColor = UIColor(red: 118.0/255.0, green: 172.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        }else if visit.startDate > Date() {
            statusLbl.text = getLocalizedStr(str: "Upcoming")
            statusContainerView?.backgroundColor = UIColor(red: 118.0/255.0, green: 172.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        }else{
            statusContainerView?.backgroundColor = UIColor.darkGray
            statusLbl.text = getLocalizedStr(str: "Completed")
        }
        
        museumNameLbl.text = getLocalizedStr(str: getMuseumName(divisionID: visit.divisionId))
        
        museumNameLbl.decideTextDirection()
        dateLbl.decideTextDirection()
        ticketIdLbl.decideTextDirection()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOranisedVisits = findOranisedVisitsArr[indexPath.row]
        
        self.performSegue(withIdentifier: QMTLConstants.Segue.seguePrintTicketViewController, sender: nil)

    }
                                                                                                
    //MARK:- TabBar Delegate
    
    func backBtnSelected() {
        self.navigationController?.popViewController(animated: false)
    }
    func moveToTabRoot() {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    func localizationSetup(){
        
        i_titleLbl.text = getLocalizedStr(str: i_titleLbl.text!)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == QMTLConstants.Segue.seguePrintTicketViewController{
            
            let printTicketViewController:PrintTicketViewController = segue.destination as! PrintTicketViewController
            
            printTicketViewController.ticketForIdStr = selectedOranisedVisits.id
            printTicketViewController.isFromMyVisits = true
        }
    }
    

}
