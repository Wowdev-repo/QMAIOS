//
//  PanelDetailCell.swift
//  QatarMuseums
//
//  Created by Exalture on 01/12/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import UIKit
import MapKit

class PanelDetailCell: UITableViewCell {
    @IBOutlet weak var topImg: UIImageView!
    
    @IBOutlet weak var topTitle: UITextView!
    @IBOutlet weak var topDescription: UITextView!
    @IBOutlet weak var interestedLabel: UILabel!
    @IBOutlet weak var notInterestedLabel: UILabel!
    @IBOutlet weak var interestSwitch: UISwitch!
    @IBOutlet weak var secondImg: UIImageView!
    @IBOutlet weak var secondTitle: UITextView!
    @IBOutlet weak var secondDescription: UITextView!
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var venueTitle: UILabel!
    @IBOutlet weak var contactTitle: UILabel!
    @IBOutlet weak var contactNumberLabel: UILabel!
    @IBOutlet weak var contactEmailLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var secondTitleLine: UILabel!
    @IBOutlet weak var mapOverlayView: UIView!
    
    @IBOutlet weak var descriptionLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var contactTitleLine: UILabel!
    var loadMapView : (()->())?
    var registerOrUnRegisterAction : (()->())?

    override func awakeFromNib() {
        setUI()
    }
    func setUI() {
        topTitle.font = UIFont.selfGuidedFont
        topDescription.font = UIFont.collectionFirstDescriptionFont
        interestedLabel.font = UIFont.collectionFirstDescriptionFont
        notInterestedLabel.font = UIFont.collectionFirstDescriptionFont
        secondTitle.font = UIFont.selfGuidedFont
        secondDescription.font = UIFont.collectionFirstDescriptionFont
        dateTitle.font = UIFont.tryAgainFont
        dateText.font = UIFont.collectionFirstDescriptionFont
        venueTitle.font = UIFont.tryAgainFont
        contactTitle.font = UIFont.tryAgainFont
        contactNumberLabel.font = UIFont.collectionFirstDescriptionFont
        contactEmailLabel.font = UIFont.collectionFirstDescriptionFont
        topView.layer.cornerRadius = 7.0
        secondView.layer.cornerRadius = 7.0
        thirdView.layer.cornerRadius = 7.0
        topView.clipsToBounds = true
        secondView.clipsToBounds = true
        thirdView.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tap.delegate = self // This is not required
        mapOverlayView.addGestureRecognizer(tap)
    }
    func setPanelDetailCellContent(panelDetailData: NMoQTour?) {
        topTitle.text = panelDetailData?.subtitle
        topDescription.text = panelDetailData?.dayDescription
        interestedLabel.text = REGISTER
        notInterestedLabel.text = UNREGISTER
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
    func setTourSecondDetailCellContent(tourDetailData: NMoQTourDetail?,userEventList : [NMoQUserEventList]) {
        
        topTitle.text = tourDetailData?.title?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        topDescription.text = tourDetailData?.body
        interestedLabel.text = REGISTER
        notInterestedLabel.text = UNREGISTER
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
        if let arrayOffset = userEventList.index(where: {$0.eventID == tourDetailData?.nid}) {
            setRegistrationSwitchOn()
        } else {
            setRegistrationSwitchOff()
        }
    }
    func setRegistrationSwitchOn() {
        interestSwitch.tintColor = UIColor.settingsSwitchOnTint
        interestSwitch.layer.cornerRadius = 16
        interestSwitch.backgroundColor = UIColor.settingsSwitchOnTint
        interestSwitch.isOn = false
    }
    func setRegistrationSwitchOff() {
        interestSwitch.onTintColor = UIColor.red
        interestSwitch.layer.cornerRadius = 16
        interestSwitch.backgroundColor = UIColor.red
        interestSwitch.isOn = true
    }
    @IBAction func didTapRegisterButton(_ sender: UISwitch) {
        self.registerOrUnRegisterAction?()
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        self.loadMapView?()
    }
}
