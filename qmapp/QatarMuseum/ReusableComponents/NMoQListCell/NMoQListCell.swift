//
//  NMoQListCell.swift
//  QatarMuseums
//
//  Created by Developer on 28/11/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import UIKit
import CocoaLumberjack

class NMoQListCell: UITableViewCell {
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setGradientLayer()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.font = UIFont.homeTitleFont
        dayLabel.font  = UIFont.settingsUpdateLabelFont
        dateLabel.font = UIFont.sideMenuLabelFont
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            titleLabel.textAlignment = .left
            dayLabel.textAlignment = .left
            dateLabel.textAlignment = .left
        } else {
            titleLabel.textAlignment = .right
            dayLabel.textAlignment = .right
            dateLabel.textAlignment = .right
        }
    }
    func setTourListDate(tourList: NMoQTour?,isTour: Bool?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        titleLabel.text = tourList?.subtitle
        dayLabel.text = tourList?.title
        if (isTour)! {
            dateLabel.text = changeDateFormat(dateString: tourList?.eventDate)
        } else {
            dateLabel.isHidden = true
        }
        

        if ((tourList?.images?.count)! > 0) {
            if let imageUrl = tourList?.images![0]{
                cellImageView.kf.setImage(with: URL(string: imageUrl))
            }
        } else {
            cellImageView.image = UIImage(named: "default_imageX2")
        }
        if (cellImageView.image == nil) {
            cellImageView.image = UIImage(named: "default_imageX2")
        }
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            titleLabel.textAlignment = .left
            dayLabel.textAlignment = .left
            dateLabel.textAlignment = .left
        } else {
            titleLabel.textAlignment = .right
            dayLabel.textAlignment = .right
            dateLabel.textAlignment = .right
        }
    }
    func setActivityListDate(activityList: NMoQActivitiesList?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        titleLabel.text = activityList?.subtitle
        dayLabel.text = activityList?.title
        dateLabel.isHidden = true
        if ((activityList?.images?.count)! > 0) {
            if let imageUrl = activityList?.images![0]{
                cellImageView.kf.setImage(with: URL(string: imageUrl))
            }
        } else {
            cellImageView.image = UIImage(named: "default_imageX2")
        }
        if (cellImageView.image == nil) {
            cellImageView.image = UIImage(named: "default_imageX2")
        }
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            titleLabel.textAlignment = .left
            dayLabel.textAlignment = .left
            dateLabel.textAlignment = .left
        } else {
            titleLabel.textAlignment = .right
            dayLabel.textAlignment = .right
            dateLabel.textAlignment = .right
        }
    }
    func setTourMiddleDate(tourList: NMoQTourDetail?) {
        dayLabel.font  = UIFont.homeTitleFont
        dayLabel.text = tourList?.title?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        titleLabel.isHidden = true
        dayLabel.isHidden = false
        dateLabel.isHidden = true
        //dayLabel.text = tourList?.title
        //dateLabel.text = changeDateFormat(dateString: tourList?.eventDate)
        
        if ((tourList?.imageBanner?.count)! > 0) {
            if let imageUrl = tourList?.imageBanner![0]{
                cellImageView.kf.setImage(with: URL(string: imageUrl))
            }
        } else {
            cellImageView.image = UIImage(named: "default_imageX2")
        }
        if (cellImageView.image == nil) {
           cellImageView.image = UIImage(named: "default_imageX2")
        }
    }
    func setTravelListData(travelListData: HomeBanner) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        dayLabel.font = UIFont.homeTitleFont
        dayLabel.text = travelListData.title
        titleLabel.isHidden = true
        dayLabel.isHidden = false
        dateLabel.isHidden = true
        if let imgUrl = travelListData.bannerLink {
            cellImageView.kf.setImage(with: URL(string: imgUrl))
            if(imgUrl == "") {
                cellImageView.image = UIImage(named: "default_imageX2")
            }
        } else {
            cellImageView.image = UIImage(named: "default_imageX2")
        }
    }
    func setFacilitiesListData(facilitiesListData: Facilities?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        dayLabel.font = UIFont.homeTitleFont
        dayLabel.text = facilitiesListData!.title!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "&amp;", with: "&", options: .regularExpression, range: nil)
        titleLabel.isHidden = true
        dayLabel.isHidden = false
        dateLabel.isHidden = true
        if ((facilitiesListData?.images?.count)! > 0) {
            if let imageUrl = facilitiesListData?.images![0]{
                cellImageView.kf.setImage(with: URL(string: imageUrl))
            }
        } else {
            cellImageView.image = UIImage(named: "default_imageX2")
        }
        if (cellImageView.image == nil) {
            cellImageView.image = UIImage(named: "default_imageX2")
        }
    }
    func setFacilitiesDetail(FacilitiesDetailData: FacilitiesDetail?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        dayLabel.font  = UIFont.homeTitleFont
        dayLabel.text = FacilitiesDetailData?.title?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        titleLabel.isHidden = true
        dayLabel.isHidden = false
        dateLabel.isHidden = true
        
        
        if ((FacilitiesDetailData?.images?.count)! > 0) {
            if let imageUrl = FacilitiesDetailData?.images![0]{
                cellImageView.kf.setImage(with: URL(string: imageUrl))
            }
        } else {
            cellImageView.image = UIImage(named: "default_imageX2")
        }
        if (cellImageView.image == nil) {
            cellImageView.image = UIImage(named: "default_imageX2")
        }
    }
    func setParkListData() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        dayLabel.font = UIFont.homeTitleFont
        dayLabel.text = "Playround"
        titleLabel.isHidden = true
        dayLabel.isHidden = false
        dateLabel.isHidden = true
//        if ((facilitiesListData?.images?.count)! > 0) {
//            if let imageUrl = facilitiesListData?.images![0]{
//                cellImageView.kf.setImage(with: URL(string: imageUrl))
//            }
//        } else {
//            cellImageView.image = UIImage(named: "default_imageX2")
//        }
        if (cellImageView.image == nil) {
            //cellImageView.image = UIImage(named: "default_imageX2")
            cellImageView.image = UIImage(named: "panelAndTalks")
        }
    }
    
    func setParkListData(parkList: NMoQPark) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        titleLabel.text = parkList.title?.htmlString
            //?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        dateLabel.isHidden = true
        if ((parkList.images?.count)! > 0) {
            if let imageUrl = parkList.images?[0]{
                cellImageView.kf.setImage(with: URL(string: imageUrl))
            }
        } else {
            cellImageView.image = UIImage(named: "default_imageX2")
        }
        if (cellImageView.image == nil) {
            cellImageView.image = UIImage(named: "default_imageX2")
        }
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            titleLabel.textAlignment = .left
            dayLabel.textAlignment = .left
            dateLabel.textAlignment = .left
        } else {
            titleLabel.textAlignment = .right
            dayLabel.textAlignment = .right
            dateLabel.textAlignment = .right
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setGradientLayer() {
        self.cellImageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let width = self.bounds.width
        let height = self.bounds.height
        let sHeight:CGFloat = 110.0
        let shadow = UIColor.black.withAlphaComponent(0.8).cgColor
        
        let bottomImageGradient = CAGradientLayer()
        bottomImageGradient.frame = CGRect(x: 0, y: height - sHeight, width: width, height: sHeight)
        bottomImageGradient.colors = [UIColor.clear.cgColor, shadow]
        cellImageView.layer.insertSublayer(bottomImageGradient, at: 0)
    }
    
}
