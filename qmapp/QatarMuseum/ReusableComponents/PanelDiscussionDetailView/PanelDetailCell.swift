//
//  PanelDetailCell.swift
//  QatarMuseums
//
//  Created by Exalture on 01/12/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import UIKit
import MapKit

class PanelDetailCell: UITableViewCell,UITextViewDelegate {
    @IBOutlet weak var topImg: UIImageView!
    
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var topDescription: UITextView!
    @IBOutlet weak var secondImg: UIImageView!
    @IBOutlet weak var secondTitle: UITextView!
    @IBOutlet weak var secondDescription: UITextView!
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var venueTitle: UILabel!
    @IBOutlet weak var contactTitle: UILabel!
    @IBOutlet weak var contactNumberLabel: UILabel!
    @IBOutlet weak var contactEmailLabel: UnderlinedLabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var secondTitleLine: UILabel!
    @IBOutlet weak var mapOverlayView: UIView!
    @IBOutlet weak var descriptionLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var contactTitleLine: UILabel!
    @IBOutlet weak var switchTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var switchBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var numbOfRservationsLabel: UILabel!
    
    var loadMapView : (()->())?
    var loadEmailComposer : (()->())?
    var callPhone : (()->())?
    var registerOrUnRegisterAction : (()->())?

    override func awakeFromNib() {
        setUI()
    }
    func setUI() {
        topTitle.font = UIFont.selfGuidedFont
        topDescription.font = UIFont.collectionFirstDescriptionFont
        secondTitle.font = UIFont.selfGuidedFont
        secondDescription.font = UIFont.collectionFirstDescriptionFont
        dateTitle.font = UIFont.tryAgainFont
        dateText.font = UIFont.collectionFirstDescriptionFont
        venueTitle.font = UIFont.tryAgainFont
        contactTitle.font = UIFont.tryAgainFont
        contactNumberLabel.font = UIFont.collectionFirstDescriptionFont
        contactEmailLabel.font = UIFont.collectionFirstDescriptionFont
        registerButton.titleLabel?.font = UIFont.popupProductionFont
        numbOfRservationsLabel.font = UIFont.settingsUpdateLabelFont
        topView.layer.cornerRadius = 7.0
        secondView.layer.cornerRadius = 7.0
        thirdView.layer.cornerRadius = 7.0
        topView.clipsToBounds = true
        secondView.clipsToBounds = true
        thirdView.clipsToBounds = true
        
        let emailTap = UITapGestureRecognizer(target: self, action: #selector(emailTapFunction))
        contactEmailLabel.isUserInteractionEnabled = true
        contactEmailLabel.addGestureRecognizer(emailTap)
        
        let phoneTap = UITapGestureRecognizer(target: self, action: #selector(phoneTapFunction))
        contactNumberLabel.isUserInteractionEnabled = true
        contactNumberLabel.addGestureRecognizer(phoneTap)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tap.delegate = self // This is not required
        mapOverlayView.addGestureRecognizer(tap)
        
        topDescription.delegate = self
        topDescription.isUserInteractionEnabled = true
        topDescription.isEditable = false
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            topDescription.textAlignment = .left
            descriptionLeftConstraint.constant = 30
        } else {
            topDescription.textAlignment = .right
            //descriptionLeftConstraint.constant = 30

        }
    }
    func setPanelDetailCellContent(panelDetailData: NMoQTour?) {
        topTitle.text = panelDetailData?.subtitle
        topDescription.text = panelDetailData?.dayDescription
        secondTitle.text = panelDetailData?.moderatorName
        secondDescription.text = panelDetailData?.descriptioForModerator
        dateTitle.text = NSLocalizedString("DATE", comment: "DATE in Paneldetail Page")
        dateText.text = changeDateFormat(dateString: panelDetailData?.eventDate)
        venueTitle.text = NSLocalizedString("VENUE", comment: "VENUE in Paneldetail Page")
        if ((panelDetailData?.contactPhone != nil) && (panelDetailData?.contactPhone != "") || (panelDetailData?.contactEmail != nil) && (panelDetailData?.contactEmail != "")) {
            contactTitle.text = NSLocalizedString("CONTACT_TITLE", comment: "CONTACT_TITLE in Paneldetail Page")
            contactTitleLine.isHidden = false
        } else {
            contactTitleLine.isHidden = true
        }
    
        contactNumberLabel.text = panelDetailData?.contactPhone
        contactEmailLabel.text = panelDetailData?.contactEmail
        if ((panelDetailData?.images?.count)! > 1) {
            if let imageUrl = panelDetailData?.images![0]{
                topImg.kf.setImage(with: URL(string: imageUrl))
            } else {
                topImg.image = UIImage(named: "default_imageX2")
            }
            if let imageUrl = panelDetailData?.images![1]{
                secondImg.kf.setImage(with: URL(string: imageUrl))
            } else {
                secondImg.image = UIImage(named: "default_imageX2")
            }
        } else if ((panelDetailData?.images?.count)! > 0) {
            if let imageUrl = panelDetailData?.images![0]{
                topImg.kf.setImage(with: URL(string: imageUrl))
            } else {
                topImg.image = UIImage(named: "default_imageX2")
            }
            secondImg.image = UIImage(named: "default_imageX2")
        }
        
        //Details For Map
        var latitudeString  = String()
        var longitudeString = String()
        var latitude : Double?
        var longitude : Double?
        
        if (panelDetailData?.mobileLatitude != nil && panelDetailData?.mobileLatitude != "" && panelDetailData?.longitude != nil && panelDetailData?.longitude != "") {
            latitudeString = (panelDetailData?.mobileLatitude)!
            longitudeString = (panelDetailData?.longitude)!
            if let lat : Double = Double(latitudeString) {
                latitude = lat
            }
            if let long : Double = Double(longitudeString) {
                longitude = long
            }
            
            let location = CLLocationCoordinate2D(latitude: latitude!,
                                                  longitude: longitude!)
            
            // 2
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
            //3
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            mapView.addAnnotation(annotation)
        }
        
    }
    
    func setTourSecondDetailCellContent(tourDetailData: NMoQTourDetail?,userEventList : [NMoQUserEventList],fromTour:Bool?) {
        numbOfRservationsLabel.numberOfLines = 2
        if(fromTour)! {
            
            numbOfRservationsLabel.isHidden = false
            registerButton.isHidden = false
            switchBottomConstraint.constant = 32
            if let arrayOffset = userEventList.index(where: {$0.eventID == tourDetailData?.nid}) {
                numbOfRservationsLabel.isHidden = false
                if(userEventList[arrayOffset].seats == "1") {
                    let reservationCount = NSLocalizedString("NUMB_OF_RESERVATIONS", comment: "NUMB_OF_RESERVATIONS in panel detail") + (userEventList[arrayOffset].seats ?? "1") +  NSLocalizedString("SPACE", comment: "SPACE in panel detail")
                    numbOfRservationsLabel.text = reservationCount
                } else {
                    let reservationCount = NSLocalizedString("NUMB_OF_RESERVATIONS", comment: "NUMB_OF_RESERVATIONS in panel detail") + (userEventList[arrayOffset].seats ?? "2") +  NSLocalizedString("SPACES", comment: "SPACES in panel detail")
                    numbOfRservationsLabel.text = reservationCount
                }
                
                registerButton.tag = 1
                registerButton.backgroundColor = UIColor.red
                let cancelBookingString = NSLocalizedString("CANCEL_BOOKING_STRING", comment: "CANCEL_BOOKING_STRING in panel detail")
                registerButton.setTitle(cancelBookingString, for: .normal)
            } else {
                let remainingSeat : Int? = Int(tourDetailData?.seatsRemaining ?? "0")
                if ((tourDetailData?.seatsRemaining == "0") || (tourDetailData?.seatsRemaining == nil) || (remainingSeat! < 0)){
                    numbOfRservationsLabel.text = NSLocalizedString("NO_SEAT_AVAILABLE", comment: "NO_SEAT_AVAILABLE in panel detail")
                    registerButton.backgroundColor = UIColor.lightGray
                    registerButton.isEnabled = false
                } else if (tourDetailData?.seatsRemaining == "1") {
                    numbOfRservationsLabel.text =  (tourDetailData?.seatsRemaining ?? "1") + NSLocalizedString("TOUR_SEAT_AVAILABILITY_STRING3", comment: "TOUR_SEAT_AVAILABILITY_STRING3 in panel detail")
                    registerButton.isEnabled = true
                    registerButton.backgroundColor = UIColor(red: 60/255, green: 135/255, blue: 66/255, alpha: 1)
                } else {
                    numbOfRservationsLabel.text =  (tourDetailData?.seatsRemaining ?? "3") + NSLocalizedString("TOUR_SEAT_AVAILABILITY_STRING2", comment: "TOUR_SEAT_AVAILABILITY_STRING2 in panel detail")
                    registerButton.isEnabled = true
                    registerButton.backgroundColor = UIColor(red: 60/255, green: 135/255, blue: 66/255, alpha: 1)
                }
                registerButton.tag = 0
                
                registerButton.setTitle(NSLocalizedString("BOOK_TOUR_STRING", comment: "BOOK_TOUR_STRING in panel detail"), for: .normal)
            }
        } else {
            numbOfRservationsLabel.isHidden = true
            registerButton.isHidden = true
            switchBottomConstraint.constant = 0
        }
        topTitle.text = tourDetailData?.title?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        topDescription.text = tourDetailData?.body?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        
        secondImg.isHidden = true
        secondTitle.isHidden = true
        secondDescription.isHidden = true
        secondView.isHidden = true
        secondTitleLine.isHidden = true
        dateTitle.text = NSLocalizedString("DATE", comment: "DATE in Paneldetail Page")
        dateText.text = tourDetailData?.date?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        venueTitle.text = NSLocalizedString("LOCATION_TITLE", comment: "LOCATION_TITLE in Paneldetail Page")
        if ((tourDetailData?.contactPhone != nil) && (tourDetailData?.contactPhone != "") || (tourDetailData?.contactEmail != nil) && (tourDetailData?.contactEmail != "")) {
            contactTitle.text = NSLocalizedString("CONTACT_TITLE", comment: "CONTACT_TITLE in Paneldetail Page")
            contactTitleLine.isHidden = false
            contactTitle.isHidden = false
        } else {
            contactTitle.isHidden = true
            contactTitleLine.isHidden = true
        }
        contactNumberLabel.text = tourDetailData?.contactPhone
        contactEmailLabel.text = tourDetailData?.contactEmail
        if ((tourDetailData?.imageBanner?.count)! > 0) {
            if let imageUrl = tourDetailData?.imageBanner![0]{
                topImg.kf.setImage(with: URL(string: imageUrl))
            }
        }
        if (topImg.image == nil) {
            topImg.image = UIImage(named: "default_imageX2")
        }
        //Details For Map
        var latitudeString  = String()
        var longitudeString = String()
        var latitude : Double?
        var longitude : Double?
        
        if (tourDetailData?.mobileLatitude != nil && tourDetailData?.mobileLatitude != "" && tourDetailData?.longitude != nil && tourDetailData?.longitude != "") {
            latitudeString = (tourDetailData?.mobileLatitude)!
            longitudeString = (tourDetailData?.longitude)!
            if let lat : Double = Double(latitudeString) {
                latitude = lat
            }
            if let long : Double = Double(longitudeString) {
                longitude = long
            }
            
            let location = CLLocationCoordinate2D(latitude: latitude!,
                                                  longitude: longitude!)
            
            // 2
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
            //3
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            mapView.addAnnotation(annotation)
        }
        
        
        let verticalSpace = NSLayoutConstraint(item: self.topView, attribute: .bottom, relatedBy: .equal, toItem: self.thirdView, attribute: .top, multiplier: 1, constant: -16)
        

        // activate the constraints
        NSLayoutConstraint.activate([verticalSpace])
        
    }
    func setFacilitiesDetailData(facilitiesDetailData: FacilitiesDetail?) {
        numbOfRservationsLabel.isHidden = true
        registerButton.isHidden = true
        switchBottomConstraint.constant = 0
        topTitle.text = facilitiesDetailData?.title?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        topDescription.text = facilitiesDetailData?.facilitiesDes?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        topDescription.textAlignment = .center
        secondImg.isHidden = true
        secondTitle.isHidden = true
        secondDescription.isHidden = true
        secondView.isHidden = true
        secondTitleLine.isHidden = true
        contactTitle.isHidden = true
        contactTitleLine.isHidden = true
        dateTitle.text = NSLocalizedString("OPENING_TIME_TITLE", comment: "OPENING_TIME_TITLE in Paneldetail Page").capitalized
        dateText.text = facilitiesDetailData?.timing?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        venueTitle.text = NSLocalizedString("LOCATION_TITLE", comment: "LOCATION_TITLE in Paneldetail Page").capitalized

        
        if ((facilitiesDetailData?.images?.count)! > 0) {
            if let imageUrl = facilitiesDetailData?.images![0]{
                topImg.kf.setImage(with: URL(string: imageUrl))
            }
        }
        if (topImg.image == nil) {
            topImg.image = UIImage(named: "default_imageX2")
        }
        //Details For Map
        var latitudeString  = String()
        var longitudeString = String()
        var latitude : Double?
        var longitude : Double?
        
        if (facilitiesDetailData?.latitude != nil && facilitiesDetailData?.latitude != "" && facilitiesDetailData?.longtitude != nil && facilitiesDetailData?.longtitude != "") {
            latitudeString = (facilitiesDetailData?.latitude)!
            longitudeString = (facilitiesDetailData?.longtitude)!
            if let lat : Double = Double(latitudeString) {
                latitude = lat
            }
            if let long : Double = Double(longitudeString) {
                longitude = long
            }
            
            let location = CLLocationCoordinate2D(latitude: latitude!,
                                                  longitude: longitude!)
            
            // 2
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
            //3
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            mapView.addAnnotation(annotation)
        }
        
        
        let verticalSpace = NSLayoutConstraint(item: self.topView, attribute: .bottom, relatedBy: .equal, toItem: self.thirdView, attribute: .top, multiplier: 1, constant: -16)
        
        
        // activate the constraints
        NSLayoutConstraint.activate([verticalSpace])
        
    }
    @IBAction func didTapRegisterButton(_ sender: UIButton) {
        
        self.registerOrUnRegisterAction?()
    }
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        self.loadMapView?()
    }
    
    @objc func emailTapFunction(sender:UITapGestureRecognizer) {
        
        print("email label tapped ...")
        self.loadEmailComposer?()
    }
    
    @objc func phoneTapFunction(sender:UITapGestureRecognizer) {
        
        print("phone label tapped ...")
        self.callPhone?()
    }
}


