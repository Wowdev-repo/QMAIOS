//
//  FloorMapViewController+MapMethods.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 25/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation
import Crashlytics
import Firebase
import GoogleMaps

extension FloorMapViewController: GMSMapViewDelegate {
    //MARK: map delegate
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        let markerIcon = marker.icon
        let searchstring = marker.title
        
        selectedScienceTourLevel = ""
        marker.appearAnimation = .pop
        marker.groundAnchor = CGPoint(x: 0.5, y: 1.0)
        
        if let arrayOffset = floorMapArray.index(where: {$0.artifactPosition == searchstring}) {
            if(markerIcon != nil) {
                marker.icon = self.imageWithImage(image: markerIcon!, scaledToSize: CGSize(width:54, height: 64))
                selectedMarkerImage = markerIcon!
            }
            
            selectedMarker = marker
            
            addBottomSheetView(index: arrayOffset)
        }
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        return true
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let zoom = mapView.camera.zoom
        
        zoomValue = zoom
        //let center = CLLocationCoordinate2DMake(25.294730,51.539021)
        let center = CLLocationCoordinate2DMake(25.296059,51.538703)
        let radius = CLLocationDistance(250)
        
        let targetLoc = CLLocation.init(latitude: position.target.latitude, longitude: position.target.longitude)
        let centerLoc = CLLocation.init(latitude: center.latitude, longitude: center.longitude)
        
        if ((targetLoc.distance(from: centerLoc)) > radius) {
            let camera = GMSCameraPosition.camera(withLatitude: center.latitude, longitude: center.longitude, zoom: mapView.camera.zoom)
            viewForMap.animate(to: camera)
        }
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
}
