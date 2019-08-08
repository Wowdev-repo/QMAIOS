//
//  CPParkTableViewCell.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 22/06/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import UIKit

import MapKit

class CPParkTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UITextView!
    @IBOutlet weak var timeTitleLabel: UILabel!
    @IBOutlet weak var locationsTitleLabel: UITextView!
    @IBOutlet weak var titleDescriptionLabel: UITextView!
    @IBOutlet weak var titleSecondDescriptionLabel: UITextView!
    @IBOutlet weak var timeDescriptionLabel: UITextView!
    @IBOutlet weak var titleLineView: UIView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var timeLineViewHeight: NSLayoutConstraint!
    @IBOutlet weak var locationLineViewHeight: NSLayoutConstraint!
    @IBOutlet weak var locationFirstLabel: UILabel!
    
    @IBOutlet weak var mapBottom: NSLayoutConstraint!
    
   
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var parkImageView: UIImageView!
    @IBOutlet weak var favouriteViewHeight: NSLayoutConstraint!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var favouriteView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var subTitleTopConstraint: NSLayoutConstraint!
    var favouriteButtonAction : (() -> ())?
    var shareButtonAction : (() -> ())?
    var locationButtonTapAction : (() -> ())?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    
    func setLocationOnMap(lat:Double,long:Double){
     
                let location = CLLocationCoordinate2D(latitude: lat,
                                                      longitude: long)
                
                // 2
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: location, span: span)
                mapView.setRegion(region, animated: true)
                // let viewRegion = MKCoordinateRegionMakeWithDistance(location, 0.05, 0.05)
                //mapView.setRegion(viewRegion, animated: false)
                //3
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                mapView.addAnnotation(annotation)
    }
    
    
    
    
    //MARK: Public Arts List Data
    func setParksCellValues(parksList: CPParksList,currentRow:Int?) {
        
        
        
        favouriteViewHeight.constant = 0
        favouriteView.isHidden = true
        shareView.isHidden = true
        favouriteButton.isHidden = true
        shareButton.isHidden = true
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        titleLabel.text = parksList.title?.uppercased()
        let parkDesc = parksList.description?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        titleDescriptionLabel.text = parkDesc?.replacingOccurrences(of: "&amp;", with: "&", options: .regularExpression, range: nil)
        
       // titleSecondDescriptionLabel.text =
        timeTitleLabel.text = NSLocalizedString("OPENING_TIME_TITLE",
                                                comment: "OPENING_TIME_TITLE in the Heritage detail")

            subTitleTopConstraint.constant = 0
            subTitleLabel.frame = CGRect(x: self.subTitleLabel.frame.origin.x, y: self.subTitleLabel.frame.origin.x, width: 0, height: 0)
            
 
        if (currentRow == 0) {
            locationsTitleLabel.isHidden = false
            locationButton.isHidden = false
            mapHeight.constant = 260
            mapView.isHidden = false
            mapBottom.constant = 60
            locationsTitleLabel.text =  NSLocalizedString("LOCATION_TITLE",
                                                          comment: "LOCATION_TITLE in the Park detail")
//            let mapRedirectionMessage = NSLocalizedString("MAP_REDIRECTION_MESSAGE",
//                                                          comment: "MAP_REDIRECTION_MESSAGE in the Dining detail")
           // locationButton.setTitle(mapRedirectionMessage, for: .normal)
            locationLineViewHeight.constant = 2
            //locationButtonBottomConstraint.constant = 29
        } else {
            locationsTitleLabel.isHidden = true
            locationButton.isHidden = true
            locationLineViewHeight.constant = 0
            mapHeight.constant = 0
            mapView.isHidden = true
            mapBottom.constant = 0
            
        }
        
        if let imageUrl = parksList.image{
            parkImageView.kf.setImage(with: URL(string: imageUrl))
        }
        
        
        
        //set font
        titleLabel.font = UIFont.closeButtonFont
        subTitleLabel.font = UIFont.collectionFirstDescriptionFont
        titleDescriptionLabel.font = UIFont.englishTitleFont
        titleSecondDescriptionLabel.font = UIFont.englishTitleFont
        timeTitleLabel.font = UIFont.closeButtonFont
        timeDescriptionLabel.font = UIFont.collectionFirstDescriptionFont
        locationFirstLabel.font = UIFont.sideMenuLabelFont
        locationButton.titleLabel?.font = UIFont.sideMenuLabelFont
        locationsTitleLabel.font = UIFont.closeButtonFont
        favouriteViewHeight.constant = 0
        favouriteView.isHidden = true
        shareView.isHidden = true
        favouriteButton.isHidden = true
        shareButton.isHidden = true
    }
    func setNmoqParkDetailValues(parkDetails: CPNMoQParkDetail?) {
        favouriteViewHeight.constant = 0
        favouriteView.isHidden = true
        shareView.isHidden = true
        favouriteButton.isHidden = true
        shareButton.isHidden = true
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        subTitleTopConstraint.constant = 0
        subTitleLabel.frame = CGRect(x: self.subTitleLabel.frame.origin.x, y: self.subTitleLabel.frame.origin.x, width: 0, height: 0)
        locationsTitleLabel.isHidden = true
        locationButton.isHidden = true
        locationLineViewHeight.constant = 0
        mapHeight.constant = 0
        mapView.isHidden = true
        mapBottom.constant = 0
        //set font
        titleLabel.font = UIFont.closeButtonFont
        subTitleLabel.font = UIFont.collectionFirstDescriptionFont
        titleDescriptionLabel.font = UIFont.englishTitleFont
        titleSecondDescriptionLabel.font = UIFont.englishTitleFont
        timeTitleLabel.font = UIFont.closeButtonFont
        timeDescriptionLabel.font = UIFont.collectionFirstDescriptionFont
        locationFirstLabel.font = UIFont.sideMenuLabelFont
        locationButton.titleLabel?.font = UIFont.sideMenuLabelFont
        locationsTitleLabel.font = UIFont.closeButtonFont
        favouriteViewHeight.constant = 0
        favouriteView.isHidden = true
        shareView.isHidden = true
        favouriteButton.isHidden = true
        shareButton.isHidden = true
        
        titleLabel.text = parkDetails?.title?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        titleDescriptionLabel.text = parkDetails?.parkDesc?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        //        titleLabel.text = parksList.title?.uppercased()
        //        let parkDesc = parksList.description?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        //        titleDescriptionLabel.text = parkDesc?.replacingOccurrences(of: "&amp;", with: "&", options: .regularExpression, range: nil)
        //
        //        timeTitleLabel.text = NSLocalizedString("OPENING_TIME_TITLE",
        //                                                comment: "OPENING_TIME_TITLE in the Heritage detail")
    }
    @IBAction func didTapFavourite(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.favouriteButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.1, animations: {
                                self.favouriteButton.transform = CGAffineTransform.identity
                                
                            })
                            self.favouriteButtonAction?()
        })
        
    }
    @IBAction func didTapShare(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.shareButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.1, animations: {
                                self.shareButton.transform = CGAffineTransform.identity
                                
                            })
                            self.shareButtonAction?()
        })
        
    }
    
    @IBAction func didTapLocation(_ sender: UIButton) {
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

}
