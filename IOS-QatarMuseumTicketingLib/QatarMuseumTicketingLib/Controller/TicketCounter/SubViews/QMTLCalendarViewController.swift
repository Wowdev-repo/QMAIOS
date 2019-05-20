//
//  QMTLCalendarViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 27/02/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
//import FSCalendar

protocol QMTLCalendarViewControllerDelegate: class {
    func selectedDate(selectedDate: Date)
}

class QMTLCalendarViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,FSCalendarDelegate,FSCalendarDataSource {
    
    //MARK:- Decleration
    var qmtlCalendarViewControllerDelegate : QMTLCalendarViewControllerDelegate?

    var startDate = Date()
    var endDate = Date()
    
    @IBOutlet weak var datePickerView: FSCalendar?
   
    //MARK:- Controller Defaults
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:false)
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        
        datePickerView?.delegate = self
        datePickerView?.dataSource = self
   
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewSetup()
    }
    
    func viewSetup(){
    
        datePickerView!.layoutIfNeeded()
        
        datePickerView!.appearance.titleWeekendColor = UIColor(red: 241/255, green: 60/255, blue: 134/255, alpha: 1)
  
        if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
            datePickerView!.locale = Locale(identifier: "en")
            datePickerView!.calendarHeaderView.calendar.locale =  Locale(identifier: "en")
            datePickerView!.appearance.titleFont = UIFont.init(name: "DINNextLTPro-Bold", size: 19)
        }
        else {
            
            //For RTL
            datePickerView!.locale = Locale(identifier: "ar")
            datePickerView!.calendarHeaderView.calendar.locale = Locale(identifier: "ar")
            datePickerView!.calendarHeaderView.collectionViewLayout.collectionView?.semanticContentAttribute = .forceLeftToRight
            datePickerView!.transform = CGAffineTransform(scaleX: -1, y: 1)
            datePickerView!.setCurrentPage(Date(), animated: false)
            datePickerView!.appearance.titleFont = UIFont.init(name: "DINNextLTArabic-Bold", size: 18)
            datePickerView!.appearance.weekdayFont =  UIFont.init(name: "DINNextLTArabic-Regular", size: 13)
            
//            datePickerView!.locale = Locale(identifier: "en")
//            datePickerView!.calendarHeaderView.calendar.locale =  Locale(identifier: "en")
//            datePickerView!.appearance.titleFont = UIFont.init(name: "DINNextLTPro-Bold", size: 19)
//
        }
        

    }
    
    func reloadCalendarView() {
        datePickerView?.reloadData()
    }
    
    //MARK:- FSCalendar
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    func maximumDate(for calendar: FSCalendar) -> Date {
        return endDate
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        qmtlCalendarViewControllerDelegate!.selectedDate(selectedDate: date)
    }
    
    //MARK:- UITableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        let cellID = QMTLConstants.CellId.eventListTableViewCell
        cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        return cell
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
