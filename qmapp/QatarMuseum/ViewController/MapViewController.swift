//
//  MapViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 17/10/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import MapKit
import UIKit
import CoreLocation

class MapViewController: UIViewController, HeaderViewProtocol, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var headerView: CommonHeaderView!
    
    var aboutData : Museum?
    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var destination: MKMapItem?
    var latitudeString : String? = nil
    var longiudeString : String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.headerViewDelegate = self
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

//        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
//        }
        loadMapData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // CLLocationManager delegate
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        self.getDirections()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func getDirections() {
        let request = MKDirectionsRequest()
        request.source = MKMapItem.forCurrentLocation()
        
        if let destination = destination {
            request.destination = destination
        }
        request.transportType = MKDirectionsTransportType.automobile
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: {(response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let response = response {
                    self.showRoute(response)
                }
            }
        })
    }
    
    func showRoute(_ response: MKDirectionsResponse) {
        for route in response.routes {
            
            mapView.add(route.polyline,
                         level: MKOverlayLevel.aboveRoads)
            
            for step in route.steps {
                print(step.instructions)
            }
        }
        
        if let coordinate = userLocation?.coordinate {
            let region =
                MKCoordinateRegionMakeWithDistance(coordinate,
                                                   2000, 2000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //MapView delegate
    func mapView(_ mapView: MKMapView, rendererFor
        overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        return renderer
    }
    
    func loadMapData() {
        var latString  = String()
        var longString = String()
        var latitude : Double?
        var longitude : Double?
        
        if (latitudeString != nil && latitudeString != "" && longiudeString != nil && longiudeString != "") {
            latString = latitudeString!
            longString = longiudeString!
            if let lat : Double = Double(latString) {
                latitude = lat
            }
            if let long : Double = Double(longString) {
                longitude = long
            }
            
            let location = CLLocationCoordinate2D(latitude: latitude!,
                                                  longitude: longitude!)
            
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
            // let viewRegion = MKCoordinateRegionMakeWithDistance(location, 0.05, 0.05)
            //mapView.setRegion(viewRegion, animated: false)
            //3
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            //annotation.title = aboutData.name
            annotation.subtitle = aboutData?.name
            mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func setMapType(_ sender: UISwitch) {
        if sender.isOn == true {
            mapView.mapType = .satellite
        } else {
            mapView.mapType = .standard
        }
    }
    
    func headerCloseButtonPressed() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
