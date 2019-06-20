//
//  HeritageDetailCell.swift
//  QatarMuseums
//
//  Created by Exalture on 21/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit
import CocoaLumberjack
import MapKit

class HeritageDetailCell: UITableViewCell {
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var titleLabel: UITextView!
    
    @IBOutlet weak var locationLine: UIView!
    @IBOutlet weak var titleLineView: UIView!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var middleTitleLabel: UILabel!
    @IBOutlet weak var titleDescriptionLabel: UITextView!
    @IBOutlet weak var midTitleDescriptionLabel: UITextView!
    @IBOutlet weak var sundayTimeLabel: UITextView!
    @IBOutlet weak var fridayTimeLabel: UILabel!
    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var middleLabelLine: UIView!
    @IBOutlet weak var titleBottomOnlyConstraint: NSLayoutConstraint!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var locationFirstLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var openingTimeTitleLabel: UILabel!
    @IBOutlet weak var openingTimeLine: UIView!
    @IBOutlet weak var contactTitleLabel: UILabel!
    @IBOutlet weak var contactLine: UIView!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var locationFirstLabel: UILabel!
    @IBOutlet weak var subTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var locationTotalTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationTotalBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var favoriteBtnViewHeight: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var favBtnTapAction : (()->())?
    var shareBtnTapAction : (()->())?
    var locationButtonTapAction : (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUi()
        pageControl.isHidden = true
        // setPublicArtsDetailCellData()
        //setHeritageDetailCellData()
    }
    
    func setUi() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        titleLabel.font = UIFont.settingsUpdateLabelFont
        titleDescriptionLabel.font = UIFont.englishTitleFont
        subTitleLabel.font = UIFont.englishTitleFont
        middleTitleLabel.font  = UIFont.englishTitleFont
        midTitleDescriptionLabel.font = UIFont.englishTitleFont
        openingTimeTitleLabel.font = UIFont.closeButtonFont
        sundayTimeLabel.font = UIFont.sideMenuLabelFont
        fridayTimeLabel.font = UIFont.sideMenuLabelFont
        locationTitleLabel.font = UIFont.closeButtonFont
        fridayLabel.font = UIFont.sideMenuLabelFont
        locationButton.titleLabel?.font = UIFont.sideMenuLabelFont
        contactTitleLabel.font = UIFont.closeButtonFont
        contactLabel.font = UIFont.sideMenuLabelFont
        favoriteBtnViewHeight.constant = 0
    }
    
    func setHeritageDetailData(heritageDetail: Heritage) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        titleBottomOnlyConstraint.isActive = false
        middleTitleLabel.isHidden = false
        midTitleDescriptionLabel.isHidden = false
        middleLabelLine.isHidden = true
        openingTimeTitleLabel.isHidden = false
        sundayTimeLabel.isHidden = false
        fridayTimeLabel.isHidden = false
        contactTitleLabel.isHidden = false
        locationFirstLabelHeight.constant = 0
        titleLineView.isHidden = false
        openingTimeLine.isHidden = true
        contactLine.isHidden = true
        locationLine.isHidden = false
        // locationTotalBottomConstraint.isActive = true
        // locationTotalBottomConstraint.constant = 40
        locationTotalTopConstraint.isActive = true
        locationTotalTopConstraint.constant = 40
        
        titleLabel.text = heritageDetail.name?.uppercased()
        if (heritageDetail.shortdescription != nil) {
            let shortDesc = replaceString(originalString: heritageDetail.shortdescription!, expression: "<[^>]+>|&nbsp;")
            titleDescriptionLabel.text = shortDesc
        }
        if (heritageDetail.longdescription != nil) {
            let longDesc = replaceString(originalString: heritageDetail.longdescription!, expression: "<[^>]+>|&nbsp;")
            midTitleDescriptionLabel.text = longDesc
        }
        
        locationTitleLabel.text = NSLocalizedString("LOCATION_TITLE",
                                                    comment: "LOCATION_TITLE in the Heritage detail")
        /* Hide bcz no opening time  and contectattribute in api*/
        /*  openingTimeTitleLabel.text = NSLocalizedString("OPENING_TIME_TITLE",
         comment: "OPENING_TIME_TITLE in the Heritage detail")
         contactTitleLabel.text = NSLocalizedString("CONTACT_TITLE",
         comment: "CONTACT_TITLE in the Heritage detail") */
        
        let mapRedirectionMessage = NSLocalizedString("MAP_REDIRECTION_MESSAGE",
                                                      comment: "MAP_REDIRECTION_MESSAGE in the Dining detail")
        // locationButton.setTitle(mapRedirectionMessage, for: .normal)
        
        
        var latitudeString  = String()
        var longitudeString = String()
        var latitude : Double?
        var longitude : Double?
        
        if (heritageDetail.latitude != nil && heritageDetail.latitude != "" && heritageDetail.longitude != nil && heritageDetail.longitude != "") {
            latitudeString = heritageDetail.latitude!
            longitudeString = heritageDetail.longitude!
            if latitudeString != "0° 0\' 0\" N" && longitudeString != "0° 0\' 0\" E" {
                
                if let lat : Double = Double(latitudeString) {
                    latitude = lat
                }
                if let long : Double = Double(longitudeString) {
                    longitude = long
                }
                if longitude == nil || latitude == nil {
                    latitude = convertDMSToDDCoordinate(latLongString: latitudeString)
                    longitude = convertDMSToDDCoordinate(latLongString: longitudeString)
                }
                let location = CLLocationCoordinate2D(latitude: latitude ?? 0.0,
                                                      longitude: longitude ?? 0.0)
                
                // 2
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: location, span: span)
                mapView.setRegion(region, animated: true)
                // let viewRegion = MKCoordinateRegionMakeWithDistance(location, 0.05, 0.05)
                //mapView.setRegion(viewRegion, animated: false)
                //3
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                //annotation.title = aboutData.name
                annotation.subtitle = heritageDetail.name
                mapView.addAnnotation(annotation)
            }
        }
        
    }
    
    func setPublicArtsDetailValues(publicArsDetail: PublicArtsDetail) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        titleLabel.text = publicArsDetail.name?.uppercased()
        //subTitleLabel.text =
        middleTitleLabel.isHidden = true
        midTitleDescriptionLabel.isHidden = true
        middleLabelLine.isHidden = true
        openingTimeTitleLabel.isHidden = true
        openingTimeLine.isHidden = true
        sundayTimeLabel.isHidden = true
        fridayTimeLabel.isHidden = true
        contactTitleLabel.isHidden = true
        titleLineView.isHidden = false
        contactLine.isHidden = true
        contactLabel.isHidden = true
        locationLine.isHidden = false
        locationFirstLabelHeight.constant = 0
        
        titleBottomOnlyConstraint.isActive = true//
        titleBottomOnlyConstraint.constant = 20//
        locationTotalTopConstraint.isActive = true
        locationTotalTopConstraint.constant = 40
        locationTotalBottomConstraint.isActive = true
        locationTotalBottomConstraint.constant = 40
        
        titleDescriptionLabel.text = publicArsDetail.description?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        midTitleDescriptionLabel.text = publicArsDetail.shortdescription?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        locationTitleLabel.text = NSLocalizedString("LOCATION_TITLE",
                                                    comment: "LOCATION_TITLE in the Heritage detail")
        let mapRedirectionMessage = NSLocalizedString("MAP_REDIRECTION_MESSAGE",
                                                      comment: "MAP_REDIRECTION_MESSAGE in the Dining detail")
        locationButton.setTitle(mapRedirectionMessage, for: .normal)
        
    }
    
    func setMuseumAboutCellData(aboutData: Museum) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        titleBottomOnlyConstraint.isActive = false
        locationTotalTopConstraint.isActive = false
        locationTotalBottomConstraint.isActive = false
        middleTitleLabel.isHidden = false
        midTitleDescriptionLabel.isHidden = false
        middleLabelLine.isHidden = false
        openingTimeTitleLabel.isHidden = false
        openingTimeLine.isHidden = false
        sundayTimeLabel.isHidden = false
        fridayTimeLabel.isHidden = false
        contactTitleLabel.isHidden = false
        contactLine.isHidden = false
        contactLabel.isHidden = false
        subTitleLabel.isHidden = true
        subTitleHeight.constant = 0
        titleLabel.text = aboutData.name?.uppercased()
        middleTitleLabel.text = aboutData.subtitle?.uppercased()
        fridayLabel.isHidden = true
        locationFirstLabelHeight.constant = 0
        var subDesc : String? = ""
        if let descriptionArray = aboutData.mobileDescription  {
            if ((descriptionArray.count) > 0) {
                for i in 0 ... (aboutData.mobileDescription?.count)!-1 {
                    if(i == 0) {
                        titleDescriptionLabel.text = aboutData.mobileDescription![i].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
                    } else {
                        subDesc = subDesc! + aboutData.mobileDescription![i].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
                        midTitleDescriptionLabel.text = subDesc
                    }
                }
            }
        }
        sundayTimeLabel.text = aboutData.openingTime
        contactLabel.text = aboutData.contactEmail
        titleLabel.font = UIFont.closeButtonFont
        middleTitleLabel.font = UIFont.closeButtonFont
        locationTitleLabel.text = NSLocalizedString("LOCATION_TITLE",
                                                    comment: "LOCATION_TITLE in the Heritage detail")
        openingTimeTitleLabel.text = NSLocalizedString("MUSEUM_TIMING",
                                                       comment: "MUSEUM_TIMING in the Heritage detail")
        contactTitleLabel.text = NSLocalizedString("CONTACT_TITLE",
                                                   comment: "CONTACT_TITLE in the Heritage detail")
        
        
    }
    
    @IBAction func didTapFavouriteButton(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.favoriteButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.1, animations: {
                                self.favoriteButton.transform = CGAffineTransform.identity
                                
                            })
                            self.favBtnTapAction?()
        })
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.shareButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.1, animations: {
                                self.shareButton.transform = CGAffineTransform.identity
                                
                            })
                            self.shareBtnTapAction?()
        })
    }
    
    @IBAction func didTapLocationButton(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.locationButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        locationButtonTapAction?()
    }
    
    @IBAction func locationButtonTouchDown(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.locationButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        // Configure the view for the selected state
    }
    func replaceString(originalString : String, expression: String)->String? {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let result = originalString.replacingOccurrences(of: expression, with: "", options: .regularExpression, range: nil)
        return result
    }
    
}
