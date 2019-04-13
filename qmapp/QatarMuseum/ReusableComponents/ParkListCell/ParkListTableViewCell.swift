//
//  ParkListTableViewCell.swift
//  QatarMuseums
//
//  Created by Exalture on 19/03/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import MapKit
import UIKit

class ParkListTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timimgTitle: UILabel!
    @IBOutlet weak var timimgTextLabel: UILabel!
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapOverlayView: UIView!
    @IBOutlet weak var titleLineView: UIView!
    @IBOutlet weak var hoursTitleLineHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLineHeight: NSLayoutConstraint!
    @IBOutlet weak var hoursTitleLineView: UIView!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var hoursView: UIView!
    
    @IBOutlet weak var locationView: UIView!
    
    //@IBOutlet weak var hoursViewHeight: NSLayoutConstraint!
    var loadMapView : (()->())?
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
        
    }
    func setUI() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tap.delegate = self 
        mapOverlayView.addGestureRecognizer(tap)
    }
    func setParkListValues(parkListData: NMoQParksList?) {
        titleLabel.font = UIFont.homeTitleFont
        timimgTitle.font = UIFont.homeTitleFont
        locationTitle.font = UIFont.homeTitleFont
        descriptionLabel.font = UIFont.englishTitleFont
        timimgTextLabel.font = UIFont.englishTitleFont
        
        titleLabel.text = parkListData?.parkTitle?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil)
        descriptionLabel.text = parkListData?.parkDescription?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil)
        timimgTitle.text = parkListData?.hoursTitle?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil)
        timimgTextLabel.text = parkListData?.hoursDesc?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil)
        locationTitle.text = parkListData?.locationTitle?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil)
        
        if ((parkListData?.parkTitle == nil) || (parkListData?.parkTitle == "") && (parkListData?.parkDescription == nil) || (parkListData?.parkDescription == "")){
            titleLineHeight.constant = 0
            titleLineView.isHidden = true
            let verticalSpace = NSLayoutConstraint(item: self.topView, attribute: .top, relatedBy: .equal, toItem: self.hoursView, attribute: .top, multiplier: 1, constant: 0)
            NSLayoutConstraint.activate([verticalSpace])
        } else {
            titleLineHeight.constant = 3
            titleLineView.isHidden = false
        }
        if ((parkListData?.hoursTitle == nil) || (parkListData?.hoursTitle?.trimmingCharacters(in: NSCharacterSet.whitespaces) == "") && (parkListData?.hoursDesc == nil) || (parkListData?.hoursDesc?.trimmingCharacters(in: NSCharacterSet.whitespaces) == "")){
            hoursTitleLineHeight.constant = 0
            
            hoursTitleLineView.isHidden = true
            let verticalSpace = NSLayoutConstraint(item: self.topView, attribute: .bottom, relatedBy: .equal, toItem: self.locationView, attribute: .top, multiplier: 1, constant: -16)
           // activate the constraints
            NSLayoutConstraint.activate([verticalSpace])
        } else {
            hoursTitleLineHeight.constant = 3
            hoursTitleLineView.isHidden = false
        }
        
         //Details For Map
         var latitudeString  = String()
         var longitudeString = String()
         var latitude : Double?
         var longitude : Double?
         
         if (parkListData?.latitude != nil && parkListData?.latitude != "" && parkListData?.longitude != nil && parkListData?.longitude != "") {
             latitudeString = (parkListData?.latitude)!
             longitudeString = (parkListData?.longitude)!
             if let lat : Double = Double(latitudeString) {
                latitude = lat
             }
             if let long : Double = Double(longitudeString) {
                longitude = long
             }
            if(latitude != nil && longitude != nil) {
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
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        self.loadMapView?()
    }

}
