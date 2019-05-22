//
//  TicketPickerView.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 18/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit


protocol TicketPickerViewDelegate: class {
    func selectedCount(count : Int, indexChosen : Int)
    func dismissView()
}

class TicketPickerView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- Decleration
    var ticketPickerViewDelegate : TicketPickerViewDelegate?
    var indexChosen = 0
    var ticketCount = 0
    
    @IBOutlet weak var ticketPickerTblView: UITableView!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var typeLblLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var typeLblTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tblViewCenterYConstraint: NSLayoutConstraint!
    
    //MARK:- Functions

    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        
        
    }
    
    class func instanceFromNib() -> UIView {
        
        return UINib(nibName: "TicketPickerView", bundle: QMTLSingleton.sharedInstance.bundle).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    func setupView(){
        localizationSetup()
        ticketPickerTblView.layer.cornerRadius = 10.0
        
        ticketPickerTblView.delegate = self
        ticketPickerTblView.dataSource = self        
        
        ticketPickerTblView.register(UINib(nibName: QMTLConstants.NibName.ticketPickerTableViewCell, bundle: QMTLSingleton.sharedInstance.bundle), forCellReuseIdentifier: QMTLConstants.CellId.ticketPickerTableViewCellID)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        backView.addGestureRecognizer(tap)
    }
    
    func setTypeName(typeName : String, indexChosen : Int, totalItemCnt : Int , typeNameLblPoint : CGPoint, countLblPoint : CGPoint){
        typeLbl.text = getLocalizedStr(str: typeName)
        self.indexChosen = indexChosen
        
        let thisViewPoint = self.superview?.convert(self.frame.origin, to: nil)

        print("(self.superview?.frame.size.height)! = \((self.superview?.frame.size.height)!)")
        print("self.frame.origin.y = \(self.frame.origin.y)")
        print("typeNameLblPoint.y = \(typeNameLblPoint.y)")
        print("thisViewPoint.y = \(thisViewPoint!.y)")
        print("typeNameLblPoint.x = \(typeNameLblPoint.x)")
        print("thisViewPoint.x = \(thisViewPoint!.x)")
        
        if QMTLLocalizationLanguage.currentAppleLanguage() == QMTLConstants.Language.AR_LANGUAGE {
            print("Lanuage AR")
            typeLblLeadingConstraint.constant = self.frame.size.width - (typeNameLblPoint.x + typeLbl.frame.size.width + 20)
            tblViewTrailingConstraint.constant = self.frame.size.width - (countLblPoint.x + 45 + 50)

        }else{
            print("Lanuage EN")
            typeLblLeadingConstraint.constant = typeNameLblPoint.x
            tblViewTrailingConstraint.constant = self.frame.size.width - (countLblPoint.x + 45)

        }
        
        typeLblTopConstraint.constant = typeNameLblPoint.y - thisViewPoint!.y
        
        tblViewHeightConstraint.constant = 300
        
        if (indexChosen == 0) {
            tblViewCenterYConstraint.constant = 100
        }else if (indexChosen == totalItemCnt - 1) {
            tblViewCenterYConstraint.constant = -100
        }
        
        ticketPickerTblView.layoutIfNeeded()
        typeLbl.layoutIfNeeded()
    }
    
    func setPositionForSubViews(rect : CGRect){
        
        typeLbl.frame = frame
    }
    
    func setTicketCount(count : Int){
        ticketCount = count
        
        if count < 6 {
            tblViewHeightConstraint.constant = CGFloat(count * 50)
            tblViewCenterYConstraint.constant = 0
        }
        ticketPickerTblView.layoutIfNeeded()
        self.ticketPickerTblView.reloadData()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        ticketPickerViewDelegate?.dismissView()
    }
    
    //MARK:- TableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ticketCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: QMTLConstants.CellId.ticketPickerTableViewCellID, for: indexPath) as! TicketPickerTableViewCell
                
        cell.countLbl.text = "\(indexPath.row)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("TicketPicker tableView didSelectRowAt = \(indexPath.row)")
        
        ticketPickerViewDelegate?.selectedCount(count: indexPath.row, indexChosen: self.indexChosen)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    func localizationSetup(){
        typeLbl.decideTextDirection()
    }
    

}
