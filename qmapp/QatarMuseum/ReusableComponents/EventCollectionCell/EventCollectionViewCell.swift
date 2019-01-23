//
//  EventCollectionViewCell.swift
//  QatarMuseum
//
//  Created by Exalture on 08/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var firstTitle: UILabel!
    @IBOutlet weak var titleLineView: UILabel!
    @IBOutlet weak var secondTitleLabel: UILabel!
    @IBOutlet weak var timingLabel: UILabel!
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var verticalLineView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var groupSizeLabel: UILabel!
    @IBOutlet weak var viewDetails: UIButton!
    
    var viewDetailsBtnAction : (()->())?
    
    func setEventCellValues(event:EducationEvent) {
        firstTitle.font = UIFont.eventCellTitleFont
        secondTitleLabel.font = UIFont.eventCellTitleFont
        timingLabel.font = UIFont.exhibitionDateLabelFont
        descriptionLabel.font = UIFont.exhibitionDateLabelFont
        viewDetails.titleLabel?.font = UIFont.exhibitionDateLabelFont
        
        firstTitle.textColor = UIColor.eventTitlePink
        titleLineView.backgroundColor = UIColor.eventTitlePink
        secondTitleLabel.textColor = UIColor.eventTitlePink
        verticalLineView.backgroundColor = UIColor.eventlisBlue
        timingLabel.isHidden = false
        titleLineView.isHidden = true
        groupSizeLabel.isHidden = false
        let eventTitle = event.title?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil).uppercased()
        firstTitle.text = eventTitle?.replacingOccurrences(of: "&#039;", with: "'", options: .regularExpression, range: nil)
        let dateValue = event.fieldRepeatDate
//        if(dateValue != nil) {
//        if((dateValue?.count)! > 0) {
//            descriptionLabel.text = event.fieldRepeatDate?[0].replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil)
//        }
//        }
        let eventDesc = event.introductionText?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        descriptionLabel.text = eventDesc?.replacingOccurrences(of: "&#039;", with: "'", options: .regularExpression, range: nil)

        //secondTitleLabel.text = event.title?.uppercased()
       // descriptionLabel.text = event.shortDesc
//        if ((event.startTime != nil) && (event.endtime != nil)) {
//            let sTime = setTimeFormat(timeString: event.startTime!)
//            let eTime = setTimeFormat(timeString: event.endtime!)
//            timingLabel.text = "Timimgs:" + sTime! + "\n" + eTime!
//        }
        viewDetails.setTitle(NSLocalizedString("VIEW_DETAIL_BUTTON_TITLE", comment: "VIEW_DETAIL_BUTTON_TITLE  in the event view"), for: .normal)
    }
    func setEducationCalendarValues(educationEvent: EducationEvent) {
        firstTitle.font = UIFont.eventCellTitleFont
        secondTitleLabel.font = UIFont.eventCellTitleFont
        timingLabel.font = UIFont.exhibitionDateLabelFont
        descriptionLabel.font = UIFont.exhibitionDateLabelFont
        groupSizeLabel.font = UIFont.exhibitionDateLabelFont
        viewDetails.titleLabel?.font = UIFont.exhibitionDateLabelFont
        titleLineView.isHidden = true
        firstTitle.textColor = UIColor.black
        titleLineView.backgroundColor = UIColor.black
        secondTitleLabel.textColor = UIColor.black
        verticalLineView.backgroundColor = UIColor.darkGray
        
        timingLabel.isHidden = true
       
        groupSizeLabel.isHidden = false
       
//        firstTitle.text = educationEvent.institution
//        secondTitleLabel.text = educationEvent.title?.uppercased()
//        descriptionLabel.text = educationEvent.shortDesc
//        if (educationEvent.maxGroupSize != nil) {
//            groupSizeLabel.text = "Max. group size " + educationEvent.maxGroupSize!
//        }
        let eventTitle = educationEvent.title?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil).uppercased()
        firstTitle.text = eventTitle?.replacingOccurrences(of: "&#039;", with: "'", options: .regularExpression, range: nil)
        let dateValue = educationEvent.fieldRepeatDate
//        if(dateValue != nil) {
//        if((dateValue?.count)! > 0) {
//            descriptionLabel.text = educationEvent.fieldRepeatDate?[0].replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil)
//        }
//        }
        let eventDesc = educationEvent.introductionText?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil)
        descriptionLabel.text = eventDesc?.replacingOccurrences(of: "&#039;", with: "'", options: .regularExpression, range: nil)
        viewDetails.setTitle(NSLocalizedString("VIEW_DETAIL_BUTTON_TITLE", comment: "VIEW_DETAIL_BUTTON_TITLE  in the event view"), for: .normal)
    }
    
    @IBAction func didTapViewDetails(_ sender: UIButton) {
        self.viewDetails.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.viewDetailsBtnAction?()
    }
    @IBAction func viewDetailsButtonTouchDown(_ sender: UIButton) {
        self.viewDetails.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    func setTimeFormat(timeString : String) -> String? {
        let inFormatter = DateFormatter()
        inFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        inFormatter.dateFormat = "HH:mm"
        
        let outFormatter = DateFormatter()
        outFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        outFormatter.dateFormat = "hh:mm a"
        
        
        let date = inFormatter.date(from: timeString)!
        let outStr = outFormatter.string(from: date)
        return outStr
    }
    
}
