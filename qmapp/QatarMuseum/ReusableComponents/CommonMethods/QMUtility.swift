//
//  QMUtility.swift
//  QatarMuseums
//
//  Created by Developer on 25/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
var heritageListNotificationEn = "heritageListNotificationEn"
var heritageListNotificationAr = "heritageListNotificationAr"
var floormapNotification = "FloormapNotification"
var homepageNotificationEn = "HomepageNotificationEn"
var homepageNotificationAr = "HomepageNotificationAr"
var miaTourNotification = "MiaTourNotification"
var nmoqAboutNotification = "NmoqAboutNotification"
var nmoqTourlistNotification = "NmoqTourlistNotification"
var nmoqTravelListNotification = "NmoqTravelListNotification"
var publicArtsListNotificationEn = "PublicArtsListNotificationEn"
var publicArtsListNotificationAr = "PublicArtsListNotificationAr"
// Utility method for presenting alert without any completion handler
func presentAlert(_ viewController: UIViewController, title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(defaultAction)
    if (viewController.view.window != nil) {
        viewController.present(alertController, animated: true, completion: nil)
    }
}

// Handles common backend errors and returns unhandled internal app errors if any
func handleError(viewController: UIViewController, errorType: BackendError) -> QatarMuseumError? {
    var errorMessage: String? = nil
    var errorTitle: String? = nil
    var unhandledError: QatarMuseumError? = nil
    switch errorType {
    case .Network(let error):
        errorTitle = "Network error"
        errorMessage = error.localizedDescription
        if error._code == -999 {
            return unhandledError
        }
    case .AlamofireError(let error):
        switch error.responseCode! {
        case 400:
            errorTitle = "Bad request"
            errorMessage = "Bad request"
        case 401:
            errorTitle = "Unauthorized"
            errorMessage = "Unauthorized Error"
        case 403:
            errorTitle = "Forbidden"
            errorMessage = "Forbidden request"
        case 404:
            errorTitle = "Not Found"
            errorMessage = "Not Found Error"
        case 500:
            errorTitle = "Failure"
            errorMessage = "Internal Server Error"
        default:
            errorTitle = "Unknown error"
            errorMessage = "Unknown error, please contact system administrator"
        }
    case .JSONSerialization( _):
        errorTitle = "Serialization error"
        errorMessage = "Serialization error, please contact system administrator"
    case .ObjectSerialization( _):
        errorTitle = "Serialization error"
        errorMessage = "Serialization error, please contact system administrator"
    case .Internal(let error):
        unhandledError = error
    }
    if errorMessage != nil && errorTitle != nil {
        presentAlert(viewController, title: errorTitle!, message: errorMessage!)
    }
    return unhandledError
}

func handleAFError(viewController: UIViewController, error: AFError) {
    switch error.responseCode! {
    case 400:
        print("Bad request")
    case 401:
        print("Unauthorized")
    case 403:
        print("Forbidden request")
    case 404:
        print("Not Found")
    case 500:
        print("Internal Server Error")
    default:
        print("Unknown error")
    }
}

func convertDMSToDDCoordinate(latLongString : String) -> Double {
    var latLong = latLongString
    var delimiter = "°"
    var latLongArray = latLong.components(separatedBy: delimiter)
    var degreeString : String?
    var minString : String?
    var secString : String?
    if ((latLongArray.count) > 0) {
        degreeString = latLongArray[0]
    }
    delimiter = "'"
    latLong = latLongArray[1]
    latLongArray = latLong.components(separatedBy: delimiter)
    if ((latLongArray.count) > 1) {
        minString = latLongArray[0]
        secString = latLongArray[1]
    }
    let degree = (degreeString! as NSString).doubleValue
    let min = (minString! as NSString).doubleValue
    let sec = (secString! as NSString).doubleValue
    let ddCoordinate = degree + (min / 60) + (sec / 3600)
    return ddCoordinate
}

func showAlertView(title: String ,message: String, viewController : UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    viewController.present(alert, animated: true, completion: nil)
}
func changeDateFormat(dateString: String?) -> String? {
    if (dateString != nil) {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy"
        let showDate = inputFormatter.date(from: dateString!)
        inputFormatter.dateFormat = "dd MMMM yyyy"
        let resultString = inputFormatter.string(from: showDate!)
        return resultString
    }
    return nil
}
let appDelegate =  UIApplication.shared.delegate as? AppDelegate
func getContext() -> NSManagedObjectContext {
        if #available(iOS 10.0, *) {
            return (appDelegate?.persistentContainer.viewContext)!
           
        } else {
            return appDelegate!.managedObjectContext
        }
}
    

