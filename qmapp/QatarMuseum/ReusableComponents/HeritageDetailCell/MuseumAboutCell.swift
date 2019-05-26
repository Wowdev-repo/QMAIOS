//
//  MuseumAboutCell.swift
//  QatarMuseums
//
//  Created by Exalture on 01/10/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import AVFoundation
import AVKit
import UIKit
import MapKit
import YouTubePlayer
import CocoaLumberjack

class MuseumAboutCell: UITableViewCell,iCarouselDelegate,iCarouselDataSource,UITextViewDelegate {
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var titleLabel: UITextView!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var middleTitleLabel: UILabel!
    @IBOutlet weak var titleDescriptionLabel: UITextView!
    @IBOutlet weak var midTitleDescriptionLabel: UITextView!
    @IBOutlet weak var sundayTimeLabel: UILabel!
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
    @IBOutlet weak var contactLabel: UnderlinedLabel!
    @IBOutlet weak var contactPhoneLabel: UILabel!
    @IBOutlet weak var locationFirstLabel: UILabel!
    @IBOutlet weak var subTitleHeight: NSLayoutConstraint!
//    @IBOutlet weak var locationTotalTopConstraint: NSLayoutConstraint!
//    @IBOutlet weak var locationTotalBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var locationLine: UIView!
    @IBOutlet weak var favoriteBtnViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapOverlayView: UIView!
    @IBOutlet weak var player: VersaPlayer!
    @IBOutlet weak var controls: VersaPlayerControls!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var videoOuterView: UIView!
    @IBOutlet weak var videoOuterViewHeight: NSLayoutConstraint!
    @IBOutlet weak var downloadView: UIView!
    @IBOutlet weak var downloadImg: UIImageView!
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var downloadViewHeight: NSLayoutConstraint!
    @IBOutlet weak var offerCodeTitleLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var claimOfferButton: UIButton!
    @IBOutlet weak var offerCodeViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mapViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var favouriteView: UIView!
    @IBOutlet weak var travelView: UIView!
    
    var imgArray = NSArray()
    var favBtnTapAction : (()->())?
    var shareBtnTapAction : (()->())?
    var locationButtonTapAction : (()->())?
    var loadMapView : (()->())?
    var loadAboutVideo : (()->())?
    var downloadBtnTapAction : (()->())?
    var claimOfferBtnTapAction : (()->())?
    var loadEmailComposer : (()->())?
    var callPhone : (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUi()
        // setPublicArtsDetailCellData()
        //setHeritageDetailCellData()
        pageControl.isHidden = true
        imgArray = ["default_imageX2","default_imageX2","default_imageX2","default_imageX2"]
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tap.delegate = self // This is not required
        mapOverlayView.addGestureRecognizer(tap)
        //loadVideo()
        
    }
    
    func loadVideo(urlString:String?) {
       // self.loadAboutVideo?()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        player.use(controls: controls)
        if let url = URL.init(string: urlString!) {
            let item = VPlayerItem(url: url)
            videoImageView.image = nil
            player.set(item: item)
            player.pause()
        }
        controls.rewindButton?.isHidden = true
        controls.forwardButton?.isHidden = true
        
       // let urlString = aboutData.multimediaVideo![0]
//        if (urlString != nil && urlString != "") {
//            let videoURL = URL(string:urlString!)
//            let player = AVPlayer(url: videoURL!)
//            let playerLayer = AVPlayerLayer(player: player)
//            playerLayer.frame = self.videoView.bounds
//            self.videoView.layer.addSublayer(playerLayer)
//            player.play()
        
            
            
//            let player = AVPlayer(url: URL(string: urlString!)!)
//            //let player = AVPlayer(url: filePathURL)
//            let playerController = AVPlayerViewController()
//            playerController.view.frame = videoView.frame
//            playerController.player = player
//            self.videoView.addSubview(playerController.view)
//            self.bringSubview(toFront: videoView)
//            //self.present(playerController, animated: true) {
//                player.play()
//            //}
       // }
        //videoView.loadVideoID("2cEYXuCTJjQ")
        
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        self.loadMapView?()
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
        contactPhoneLabel.font = UIFont.sideMenuLabelFont
        favoriteBtnViewHeight.constant = 0
        offerCodeViewHeight.constant = 0
        downloadLabel.font = UIFont.downloadLabelFont
        claimOfferButton.titleLabel?.font = UIFont.popupProductionFont
        codeLabel.font = UIFont.artifactNumberFont
        offerCodeTitleLabel.font = UIFont.closeButtonFont
        
        let emailTap = UITapGestureRecognizer(target: self, action: #selector(emailTapFunction))
        contactLabel.isUserInteractionEnabled = true
        contactLabel.addGestureRecognizer(emailTap)
        
        let phoneTap = UITapGestureRecognizer(target: self, action: #selector(phoneTapFunction))
        contactPhoneLabel.isUserInteractionEnabled = true
        contactPhoneLabel.addGestureRecognizer(phoneTap)
        
        titleDescriptionLabel.delegate = self
        titleDescriptionLabel.isUserInteractionEnabled = true
        titleDescriptionLabel.isEditable = false
        
        midTitleDescriptionLabel.delegate = self
        midTitleDescriptionLabel.isUserInteractionEnabled = true
        midTitleDescriptionLabel.isEditable = false
    }
    
    func setHeritageDetailData(heritageDetail: Heritage) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
       // titleBottomOnlyConstraint.isActive = false
        //titleBottomOnlyConstraint.constant = 45
//        locationTotalTopConstraint.isActive = false
//        locationTotalBottomConstraint.isActive = false
        middleTitleLabel.isHidden = false
        midTitleDescriptionLabel.isHidden = false
        middleLabelLine.isHidden = true
        openingTimeTitleLabel.isHidden = false
        openingTimeLine.isHidden = false
        sundayTimeLabel.isHidden = false
        fridayTimeLabel.isHidden = false
        contactTitleLabel.isHidden = false
        contactLine.isHidden = false
        contactLabel.isHidden = false
        locationFirstLabelHeight.constant = 0
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
        openingTimeTitleLabel.text = NSLocalizedString("OPENING_TIME_TITLE",
                                                       comment: "OPENING_TIME_TITLE in the Heritage detail")
        contactTitleLabel.text = NSLocalizedString("CONTACT_TITLE",
                                                   comment: "CONTACT_TITLE in the Heritage detail")
        let mapRedirectionMessage = NSLocalizedString("MAP_REDIRECTION_MESSAGE",
                                                      comment: "MAP_REDIRECTION_MESSAGE in the Dining detail")
        locationButton.setTitle(mapRedirectionMessage, for: .normal)
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
        contactLine.isHidden = true
        contactLabel.isHidden = true
        
       // titleBottomOnlyConstraint.isActive = true//
        //titleBottomOnlyConstraint.constant = 45//
//        locationTotalTopConstraint.isActive = true
//        locationTotalTopConstraint.constant = 35
//        locationTotalBottomConstraint.isActive = true
//        locationTotalBottomConstraint.constant = 50
        
        titleDescriptionLabel.text = publicArsDetail.description?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        midTitleDescriptionLabel.text = publicArsDetail.shortdescription?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        locationTitleLabel.text = NSLocalizedString("LOCATION_TITLE",
                                                    comment: "LOCATION_TITLE in the Heritage detail")
        //fridayLabel.text =
    }
    
    func setMuseumAboutCellData(aboutData: Museum) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
       // titleBottomOnlyConstraint.isActive = false
//        locationTotalTopConstraint.isActive = false
//        locationTotalBottomConstraint.isActive = false
        middleTitleLabel.isHidden = false
        midTitleDescriptionLabel.isHidden = false
        middleLabelLine.isHidden = false
        openingTimeTitleLabel.isHidden = false
        openingTimeLine.isHidden = false
        sundayTimeLabel.isHidden = false
        fridayTimeLabel.isHidden = false
        contactTitleLabel.isHidden = false
        //contactLine.isHidden = false
        contactLabel.isHidden = false
        subTitleLabel.isHidden = true
       // subTitleHeight.constant = 0
        titleLabel.text = aboutData.name?.uppercased()
        middleTitleLabel.text = aboutData.subtitle?.uppercased()
        fridayLabel.isHidden = true
        locationFirstLabelHeight.constant = 0
        downloadViewHeight.constant = 0
        downloadView.isHidden = true
        downloadImg.isHidden = true
        downloadLabel.isHidden = true
        downloadButton.isHidden = true
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
        
        titleLabel.font = UIFont.closeButtonFont
        middleTitleLabel.font = UIFont.closeButtonFont
        locationTitleLabel.text = NSLocalizedString("LOCATION_TITLE",
                                                    comment: "LOCATION_TITLE in the Heritage detail")
        openingTimeTitleLabel.text = NSLocalizedString("MUSEUM_TIMING",
                                                       comment: "MUSEUM_TIMING in the Heritage detail")
        if ((aboutData.contactEmail != nil) && (aboutData.contactEmail != "")) {
            contactTitleLabel.text = NSLocalizedString("CONTACT_TITLE",
                                                       comment: "CONTACT_TITLE in the Heritage detail")
            contactLabel.text = aboutData.contactEmail
            contactLine.isHidden = false
        }
        
        var latitudeString  = String()
        var longitudeString = String()
        var latitude : Double?
        var longitude : Double?
        
        if (aboutData.mobileLatitude != nil && aboutData.mobileLatitude != "" && aboutData.mobileLongtitude != nil && aboutData.mobileLongtitude != "") {
            latitudeString = aboutData.mobileLatitude!
            longitudeString = aboutData.mobileLongtitude!
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
           // let viewRegion = MKCoordinateRegionMakeWithDistance(location, 0.05, 0.05)
            //mapView.setRegion(viewRegion, animated: false)
            //3
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            //annotation.title = aboutData.name
            annotation.subtitle = aboutData.name
            mapView.addAnnotation(annotation)
        }
        if (aboutData.multimediaVideo != nil) {
            if((aboutData.multimediaVideo?.count)! > 0) {
                self.loadVideo(urlString: aboutData.multimediaVideo?[0])
            }
        }
    }
    
    func setNMoQAboutCellData(aboutData: Museum) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        middleTitleLabel.isHidden = false
        midTitleDescriptionLabel.isHidden = false
        middleLabelLine.isHidden = false
        openingTimeTitleLabel.isHidden = false
        openingTimeLine.isHidden = false
        sundayTimeLabel.isHidden = false
        fridayTimeLabel.isHidden = false
        contactTitleLabel.isHidden = false
        contactLabel.isHidden = false
        subTitleLabel.isHidden = true
        titleLabel.text = aboutData.name?.uppercased()
        middleTitleLabel.text = aboutData.subtitle?.uppercased()
        fridayLabel.isHidden = true
        locationFirstLabelHeight.constant = 0
        downloadViewHeight.constant = 83
        downloadView.isHidden = false
        downloadImg.isHidden = false
        downloadLabel.isHidden = false
        downloadButton.isHidden = false
        
        downloadLabel.text = NSLocalizedString("DOWNLOAD_TEXT",
                                                    comment: "DOWNLOAD_TEXT in the Abbout detail")
        sundayTimeLabel.text = aboutData.eventDate
        
        titleLabel.font = UIFont.closeButtonFont
        middleTitleLabel.font = UIFont.closeButtonFont
        locationTitleLabel.text = NSLocalizedString("LOCATION_TITLE",
                                                    comment: "LOCATION_TITLE in the Heritage detail")
        openingTimeTitleLabel.text = NSLocalizedString("EVENT_DATE",
                                                       comment: "EVENT_DATE in the Heritage detail")
        if ((aboutData.contactEmail != nil) && (aboutData.contactEmail != "") || (aboutData.contactNumber != nil) && (aboutData.contactEmail != "")) {
            contactTitleLabel.text = NSLocalizedString("CONTACT_TITLE",
                                                       comment: "CONTACT_TITLE in the Heritage detail")
            contactLabel.text = aboutData.contactEmail!
                //+ "\n\n" + aboutData.contactNumber!
            contactPhoneLabel.text = aboutData.contactNumber!
            contactLine.isHidden = false
        }
        //Description
        var subDesc : String? = ""
        if let descriptionArray = aboutData.mobileDescription  {
            if ((descriptionArray.count) > 0) {
                for i in 0 ... (aboutData.mobileDescription?.count)!-1 {
                    if(i == 0) {
                        titleDescriptionLabel.text = aboutData.mobileDescription![i].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
                    } else {
                        subDesc = subDesc! + aboutData.mobileDescription![i].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
                        
//                        if (subDesc != "") {
//                            let attributedString = setHyperLinkText(originalString: subDesc)
//                            if(attributedString != nil) {
//                                midTitleDescriptionLabel.delegate = self
//                                midTitleDescriptionLabel.attributedText = attributedString
//                                midTitleDescriptionLabel.isUserInteractionEnabled = true
//                                midTitleDescriptionLabel.isEditable = false
//                                //midTitleDescriptionLabel.tintColor = UIColor.viewMyFavDarkPink
//                                midTitleDescriptionLabel.textAlignment = .center
//                            } else {
                                midTitleDescriptionLabel.text = subDesc
                           // }
                        //}
                        
                    }
                }
            }
        }
        if(subDesc != "") {
            let attributedString = setHyperLinkText(originalString: subDesc)
            if(attributedString != nil) {
                midTitleDescriptionLabel.delegate = self
                midTitleDescriptionLabel.attributedText = attributedString
                midTitleDescriptionLabel.isUserInteractionEnabled = true
                midTitleDescriptionLabel.isEditable = false
                //midTitleDescriptionLabel.tintColor = UIColor.viewMyFavDarkPink
                midTitleDescriptionLabel.textAlignment = .center
            } else {
                midTitleDescriptionLabel.text = subDesc
            }
        }
        else if(subDesc == "") {
            let attributedString = setHyperLinkText(originalString: titleDescriptionLabel.text)
            if(attributedString != nil) {
                titleDescriptionLabel.delegate = self
                titleDescriptionLabel.attributedText = attributedString
                titleDescriptionLabel.isUserInteractionEnabled = true
                titleDescriptionLabel.isEditable = false
                titleDescriptionLabel.textAlignment = .center
            } else {
                titleDescriptionLabel.text = subDesc
            }
        }

        
        //load Map
        var latitudeString  = String()
        var longitudeString = String()
        var latitude : Double?
        var longitude : Double?
        
        if (aboutData.mobileLatitude != nil && aboutData.mobileLatitude != "" && aboutData.mobileLongtitude != nil && aboutData.mobileLongtitude != "") {
            latitudeString = aboutData.mobileLatitude!
            longitudeString = aboutData.mobileLongtitude!
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
            annotation.subtitle = aboutData.name
            mapView.addAnnotation(annotation)
        }

        
    }
    
    func setNMoQTravelCellData(travelDetailData: HomeBanner) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            titleDescriptionLabel.textAlignment = .left
        } else {
            titleDescriptionLabel.textAlignment = .right
        }
        middleTitleLabel.isHidden = true
        midTitleDescriptionLabel.isHidden = true
        middleLabelLine.isHidden = true
        fridayTimeLabel.isHidden = true
       // contactTitleLabel.isHidden = true
        //contactLine.isHidden = true
        //contactLabel.isHidden = true
        locationLine.isHidden = true
        openingTimeTitleLabel.isHidden = true
        openingTimeLine.isHidden = true
        sundayTimeLabel.isHidden = true
        
        subTitleLabel.isHidden = true
        

        locationFirstLabelHeight.constant = 0
        downloadViewHeight.constant = 0
        mapViewHeight.constant = 0
        offerCodeViewHeight.constant = 200.0
        downloadView.isHidden = true
        downloadImg.isHidden = true
        downloadLabel.isHidden = true
        downloadButton.isHidden = true
        
        titleLabel.font = UIFont.closeButtonFont
        locationTitleLabel.isHidden = true
        
        titleLabel.text = travelDetailData.title
        titleDescriptionLabel.text = travelDetailData.introductionText
        
        offerCodeTitleLabel.text = NSLocalizedString("SPECIAL_OFFER", comment: "SPECIAL_OFFER in Travel Page")
        claimOfferButton.setTitle(NSLocalizedString("CLAIM_OFFER", comment: "CLAIM_OFFER in Travel Page"), for: .normal)
        codeLabel.text = travelDetailData.promotionalCode
        if ((travelDetailData.contactNumber != nil) && (travelDetailData.email != nil)) {
//            openingTimeTitleLabel.text =  NSLocalizedString("CONTACT_TITLE",
//                                                            comment: "CONTACT_TITLE in the Heritage detail")
//            sundayTimeLabel.text = travelDetailData.contactNumber! + "\n" + travelDetailData.email!
            
            
            
            contactTitleLabel.text = NSLocalizedString("CONTACT_TITLE",
                                                       comment: "CONTACT_TITLE in the Heritage detail")
            contactLabel.text = travelDetailData.email!
            //+ "\n\n" + aboutData.contactNumber!
            contactPhoneLabel.text = travelDetailData.contactNumber!
            contactLine.isHidden = false
        }
//        let verticalSpace = NSLayoutConstraint(item: self.sundayTimeLabel, attribute: .bottom, relatedBy: .equal, toItem: self.favouriteView, attribute: .top, multiplier: 1, constant: -40)

       let verticalSpace = NSLayoutConstraint(item: self.travelView, attribute: .bottom, relatedBy: .equal, toItem: self.contactTitleLabel, attribute: .top, multiplier: 1, constant: -30)
//        // activate the constraints
       NSLayoutConstraint.activate([verticalSpace])
        
    }
    func setHyperLinkText(originalString: String?) -> NSMutableAttributedString? {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let originalStringCopy = originalString?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|\n|\r", with: "", options: .regularExpression, range: nil)
        let splitArray = originalStringCopy?.components(separatedBy: " ")
        if((splitArray?.count)! > 1) {
            var last = String()
            var lastTwo = String()
            if(splitArray![(splitArray?.count)!-1] == "") {
                last = splitArray![(splitArray?.count)!-2]
                lastTwo = splitArray![(splitArray?.count)!-3]
            } else {
                last = splitArray![(splitArray?.count)!-1]
                lastTwo = splitArray![(splitArray?.count)!-2]
            }
            
            let linkString = lastTwo + " " + last
            let stringValue = originalString! as NSString
            
            let yourAttributes = [kCTForegroundColorAttributeName: UIColor.black, kCTFontAttributeName: UIFont.englishTitleFont]
            let attributedString = NSMutableAttributedString(string: originalString!, attributes: yourAttributes as [NSAttributedStringKey : Any])
            
            
            let linkAttributes: [NSAttributedStringKey: Any] = [
                .link: NSURL(string: "http://visitqatar.qa/")!,
                NSAttributedStringKey.foregroundColor: UIColor.blue,
                NSAttributedStringKey.underlineStyle: NSNumber.init(value: Int8(NSUnderlineStyle.styleSingle.rawValue)),
                NSAttributedStringKey.font : UIFont.englishTitleFont
            ]
            attributedString.setAttributes(linkAttributes, range: stringValue.range(of: linkString))
            return attributedString
        }
        return nil
        
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
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 3
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var itemView: UIImageView
        itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: carousel.frame.width, height: 50))
        itemView.contentMode = .scaleAspectFill
        //if let image = url {
        // itemView.setImageWithIndicator(imageUrl: image)
        itemView.image = UIImage(named: imgArray[index] as! String)
        //}
        return itemView
    }
    
    @IBAction func didTapDownload(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.downloadBtnTapAction?()
    }
    
    @IBAction func didTapClaimOffer(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.claimOfferBtnTapAction?()
    }
    @objc func emailTapFunction(sender:UITapGestureRecognizer) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.loadEmailComposer?()
    }
    
    @objc func phoneTapFunction(sender:UITapGestureRecognizer) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.callPhone?()
    }
}
