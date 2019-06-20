//
//  MuseumListViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Manasa Parida on 5/3/19.
//  Copyright © Mannai Corporation. All rights reserved.
//

import UIKit


protocol MuseumSelectionDelegate: class {
    func selectedMuseumName(museumName:String,withSelectedIndex:Int)
}

class MuseumListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var museumSelectionDelegate : MuseumSelectionDelegate?
    @IBOutlet weak var popupview: UIView!
    @IBOutlet weak var popTitleLabel: UILabel!
    @IBOutlet weak var museumListTableView: UITableView!
    @IBOutlet weak var cancelButtonClick: UIButton!
    @IBOutlet weak var nextButtonClick: UIButton!
    
    // Museum Array List
    var museumArrayList = [Divisions]()
    
    // Save user selected museum to pass through next button click to clalander view
    var selectedMuseumName = ""
    var selectedIndexPath = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        museumListTableView.dataSource = self
        museumListTableView.delegate = self
        
        self.popTitleLabel.text = self.getLocalizedStr(str: "PLEASE SELECT A MUSEUM")
        self.cancelButtonClick.setTitle(self.getLocalizedStr(str: "Cancel"), for: .normal)
        self.nextButtonClick.setTitle(self.getLocalizedStr(str: "Next"), for: .normal)
        //self.cancelButtonClick.titleLabel?.text = self.getLocalizedStr(str: "Cancel")
        //self.nextButtonClick.titleLabel?.text = self.getLocalizedStr(str: "Next")
        
        // Apply radius to Popupview
        popupview.layer.cornerRadius = 10
        popupview.layer.masksToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        
        let indexPath = IndexPath(row: 0, section: 0)
        museumListTableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        museumSelectionDelegate?.selectedMuseumName(museumName: selectedMuseumName,withSelectedIndex:selectedIndexPath )
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return museumArrayList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "museumListCell", for: indexPath)
        cell.textLabel?.text = self.getLocalizedStr(str: museumArrayList[indexPath.row].name)
        if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            
             if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
            cell.textLabel?.font = UIFont.init(name: "DINNextLTPro-Regular", size: 12)
            }
             else{
               cell.textLabel?.font = UIFont.init(name: "DINNextLTArabic-Regular", size: 12)
            }
        }
        else {
            
            if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
                cell.textLabel?.font = UIFont.init(name: "DINNextLTPro-Regular", size: 15)
            }
            else{
                cell.textLabel?.font = UIFont.init(name: "DINNextLTArabic-Regular", size: 15)
            }
        }
        if QMTLLocalizationLanguage.currentAppleLanguage() == QMTLConstants.Language.AR_LANGUAGE {
            cell.textLabel?.textAlignment = .right
        }
        else{
             cell.textLabel?.textAlignment = .left
        }
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    
    // Select item from tableView
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.nextButtonClick.isUserInteractionEnabled = true
        self.nextButtonClick.alpha = 1.0
        selectedIndexPath = indexPath.row
        selectedMuseumName = museumArrayList[indexPath.row].name
        print(selectedMuseumName)
    }

    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
}
