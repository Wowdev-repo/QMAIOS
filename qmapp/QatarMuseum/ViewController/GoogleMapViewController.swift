//
//  GoogleMapViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 13/12/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import Alamofire
import AVFoundation
import AVKit
import GoogleMaps
import GooglePlaces
import CocoaLumberjack
import Firebase

import UIKit

class GoogleMapViewController: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate {

    @IBOutlet weak var headerView: CommonHeaderView!
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    var directionArray : GoogleDirections?
    let apiKey = "AIzaSyAbuv0Gx0vwyZdr90LFKeUFmMesorNZHKQ"
    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()

        loadMap()
    }
    func loadMap() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 9.997090, longitude: 76.302818, zoom: 10.0)
        mapView.camera = camera
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.settings.zoomGestures = true
        locationManager.requestWhenInUseAuthorization()
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        createMarker(titleMarker: "Kaloor", iconMarker: nil, latitude: 9.997090, longitude: 76.302818)
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
    }
    //MARK: - Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get location : \(error)")
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        
        
        let locationTujuan = CLLocation(latitude: 17.369590, longitude: 76.852570)
        
        createMarker(titleMarker: "Lokasi Tujuan", iconMarker: nil , latitude: locationTujuan.coordinate.latitude, longitude: locationTujuan.coordinate.longitude)
        
        createMarker(titleMarker: "Lokasi Aku", iconMarker: nil , latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        
        drawPath(startLocation: location!, endLocation: locationTujuan)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.locationManager.stopUpdatingLocation()
    }
    // MARK: - GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.mapView.isMyLocationEnabled = true
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.mapView.isMyLocationEnabled = true
        
        if (gesture) {
            mapView.selectedMarker = nil
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.mapView.isMyLocationEnabled = true
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        return false
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)")
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), COORDINATE: \(coordinate)")
    }
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.mapView.isMyLocationEnabled = true
        self.mapView.selectedMarker = nil
        return false
    }
    //MARK: - this is function for create direction path, from start location to desination location
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(apiKey)"
        
        CPSessionManager.sharedInstance.apiManager()?.request(url).responseObject { (response: DataResponse<GoogleDirections>) -> Void in
            switch response.result {
            case .success(let data):
                print(data)
                self.directionArray = data
            case .failure( _):
                print("error")
            }
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            //let json = JSONEncoding(options: response.data)
        
//            let json = JSON(data: response.data!)
//            let routes = json["routes"].arrayValue
//            
//            // print route using Polyline
//            for route in routes
//            {
//                let routeOverviewPolyline = route["overview_polyline"].dictionary
//                let points = routeOverviewPolyline?["points"]?.stringValue
//                let path = GMSPath.init(fromEncodedPath: points!)
//                let polyline = GMSPolyline.init(path: path)
//                polyline.strokeWidth = 4
//                polyline.strokeColor = UIColor.red
//                polyline.map = self.googleMaps
//            }
            
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    // MARK: function for create a marker pin on map
    func createMarker(titleMarker: String, iconMarker: UIImage?, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.appearAnimation = .pop
        marker.title = titleMarker
        //marker.icon = iconMarker
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        marker.map = mapView
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
            mapView.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 10.0)
            mapView.settings.myLocationButton = true
            didFindMyLocation = true
        }
    }
    

 // MARK: CLLocationManagerDelegate method implementation
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.isMyLocationEnabled = true
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @IBAction func setMapType(_ sender: UISwitch) {
        if sender.isOn == true {
            mapView.mapType = .satellite
        } else {
            mapView.mapType = .normal
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), MapType: \(mapView.mapType)")
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_mapview_maptype,
            AnalyticsParameterItemName: mapView.mapType,
            AnalyticsParameterContentType: "cont"
            ])
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    
    

}
