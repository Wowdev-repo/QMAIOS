//
//  ExhibitionDetailTableViewCell.swift
//  QatarMuseums
//
//  Created by Exalture on 12/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit

import MapKit

class ExhibitionDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var titleLabel: UITextView!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var detailSecondLabel: UITextView!
    @IBOutlet weak var exbtnDateLabel: UILabel!
    @IBOutlet weak var exbtnTimeLabel: UITextView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var exhibitionTimingTitle: UILabel!
    @IBOutlet weak var locationsTitle: UILabel!
    @IBOutlet weak var contactTitle: UILabel!
    @IBOutlet weak var contactDescriptionLabel: UnderlinedLabel!
    @IBOutlet weak var centerImageView: UIImageView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var centerImgHeight: NSLayoutConstraint!
    @IBOutlet weak var favoriteBtnViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var phoneNumberLbl: UnderlinedLabel!
    
    var favBtnTapAction : (()->())?
    var shareBtnTapAction : (()->())?
    var locationButtonAction: (() -> ())?
    var loadEmailComposer : (()->())?
    var loadPhoneNumber : (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellUI()
    }
    
    func setupCellUI() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        
        //        titleLabel.textAlignment = .center
        //        descriptionLabel.textAlignment = .center
        //        detailSecondLabel.textAlignment = .center
        //        exhibitionTimingTitle.textAlignment = .center
        //        exbtnDateLabel.textAlignment = .center
        //        exbtnTimeLabel.textAlignment = .center
        //        locationsTitle.textAlignment = .center
        //        locationLabel.textAlignment = .center
        //        contactTitle.textAlignment = .center
        //        contactDescriptionLabel.textAlignment = .center
        
        
        titleLabel.font = UIFont.settingsUpdateLabelFont
        descriptionLabel.font = UIFont.englishTitleFont
        detailSecondLabel.font = UIFont.englishTitleFont
        exhibitionTimingTitle.font = UIFont.closeButtonFont
        exbtnDateLabel.font = UIFont.sideMenuLabelFont
        exbtnTimeLabel.font = UIFont.sideMenuLabelFont
        locationLabel.font = UIFont.sideMenuLabelFont
        locationsTitle.font = UIFont.closeButtonFont
        locationButton.titleLabel?.font = UIFont.sideMenuLabelFont
        contactTitle.font = UIFont.closeButtonFont
        contactDescriptionLabel.font = UIFont.sideMenuLabelFont
        favoriteBtnViewHeight.constant = 0
        
        let emailTap = UITapGestureRecognizer(target: self, action: #selector(emailTapFunction))
        contactDescriptionLabel.isUserInteractionEnabled = true
        contactDescriptionLabel.addGestureRecognizer(emailTap)
        
        let phoneTap = UITapGestureRecognizer(target: self, action: #selector(phoneTapFunction))
        phoneNumberLbl.isUserInteractionEnabled = true
        phoneNumberLbl.addGestureRecognizer(phoneTap)
    }
    
    func setHomeExhibitionDetail(exhibition: Exhibition) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        
        titleLabel.text = exhibition.name?.uppercased()
        descriptionLabel?.text = exhibition.shortDescription?.replacingOccurrences(of: "&nbsp;", with: " ", options: .regularExpression, range: nil)
        detailSecondLabel.text = exhibition.longDescription?.replacingOccurrences(of: "&nbsp;", with: " ", options: .regularExpression, range: nil)
        exbtnDateLabel.text = ""
        exbtnTimeLabel.text = exhibition.startDate!.replacingOccurrences(of: "<[^>]+>|&|#039;", with: "", options: .regularExpression, range: nil) + "\n" + exhibition.endDate!.replacingOccurrences(of: "<[^>]+>|&|#039;", with: "", options: .regularExpression, range: nil)
        //        locationLabel.text = exhibition.location?.uppercased()
        centerImgHeight.constant = 0
        centerImageView.isHidden = true
        exhibitionTimingTitle.text = NSLocalizedString("EXHIBITION_TIME_TITLE",
                                                       comment: "EXHIBITION_TIME_TITLE in the Exhibition detail")
        locationsTitle.text = NSLocalizedString("LOCATION_TITLE",
                                                comment: "LOCATION_TITLE in the Exhibition detail")
        contactTitle.text = NSLocalizedString("CONTACT_TITLE",
                                              comment: "CONTACT_TITLE in the Exhibition detail")
        //let mapRedirectionMessage = NSLocalizedString("MAP_REDIRECTION_MESSAGE",
        //                                                      comment: "MAP_REDIRECTION_MESSAGE in the Dining detail")
        //locationButton.setTitle(mapRedirectionMessage, for: .normal)
        contactDescriptionLabel.text = exhibition.mail ?? "info@mia.org.qa"
        phoneNumberLbl.text = exhibition.phone ?? "+974 4402 8202"
        
        var latitudeString  = String()
        var longitudeString = String()
        var latitude : Double?
        var longitude : Double?
        
        if (exhibition.latitude != nil && exhibition.latitude != "" && exhibition.longitude != nil && exhibition.longitude != "") {
            latitudeString = exhibition.latitude!
            longitudeString = exhibition.longitude!
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
                let location = CLLocationCoordinate2D(latitude: latitude!,
                                                      longitude: longitude!)
                
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
                annotation.subtitle = exhibition.name
                mapView.addAnnotation(annotation)
            }
        }
        
        
        
        
    }
    
    func setMuseumExhibitionDetail() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        
        titleLabel.text = "Powder And Damask"
        descriptionLabel?.text = "This exhibition showcases Islamic arms and armour from the private collection of Fadel Al Mansoori. Including both edged weapons and firearms, the objects on display range from the 17th to the 19th century, and were produced primarily in greater Turkey, Iran and India. \n Powder and Damask explores the art of craftsmanship which reached unrewcedented levels in these regions under the ottoman, Safavid and Mughal empires, and consideres these objects not only as weapons but as works of art."
        detailSecondLabel.text = "without degrading their functionality, arms and armour in Islamic lands became an art that found its place in the hands of sultans, high-ranking commanders and elite members of society."
        exbtnDateLabel.text = "27th August 2017 Until 12th May 2018"
        exbtnTimeLabel.text = "Saturday to Sunday:9:00AM - 7:00PM\n Fridays: 1:30PM to 7:00PM"
        locationLabel.text = "MUSEUM OF ISLAMIC ART"
        centerImgHeight.constant = 150
        centerImageView.isHidden = false
        centerImageView.image = UIImage(named: "default_imageX2")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    @IBAction func didTapFavouriteButton(_ sender: UIButton) {
        self.favoriteButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        favBtnTapAction?()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        self.shareButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        shareBtnTapAction?()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    @IBAction func favouriteTouchDown(_ sender: UIButton) {
        self.favoriteButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    @IBAction func shareTouchDown(_ sender: UIButton) {
        self.shareButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    @IBAction func locationTouchDown(_ sender: UIButton) {
        self.locationButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    @IBAction func didTapLocation(_ sender: UIButton) {
        self.locationButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        locationButtonAction?()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @objc func emailTapFunction(sender:UITapGestureRecognizer) {
        
        print("email label tapped ...")
        self.loadEmailComposer?()
    }
    
    @objc func phoneTapFunction(sender:UITapGestureRecognizer) {
        
        print("phone label tapped ...")
        self.loadPhoneNumber?()
    }
    
}
