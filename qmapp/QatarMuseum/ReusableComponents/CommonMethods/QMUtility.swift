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
var nmoqTourlistNotificationEn = "NmoqTourlistNotificationEn"
var nmoqTourlistNotificationAr = "NmoqTourlistNotificationAr"
var nmoqTravelListNotificationEn = "NmoqTravelListNotificationEn"
var nmoqTravelListNotificationAr = "NmoqTravelListNotificationAr"
var publicArtsListNotificationEn = "PublicArtsListNotificationEn"
var publicArtsListNotificationAr = "PublicArtsListNotificationAr"
var collectionsListNotificationEn = "CollectionsListNotificationEn"
var collectionsListNotificationAr = "CollectionsListNotificationAr"
var exhibitionsListNotificationEn = "ExhibitionsListNotificationEn"
var exhibitionsListNotificationAr = "ExhibitionsListNotificationAr"
var parksNotificationEn = "ParksNotificationEn"
var parksNotificationAr = "ParksNotificationAr"
var facilitiesListNotificationEn = "FacilitiesListNotificationEn"
var facilitiesListNotificationAr = "FacilitiesListNotificationAr"
var nmoqParkListNotificationEn = "NmoqParkListNotificationEn"
var nmoqParkListNotificationAr = "NmoqParkListNotificationAr"
var nmoqActivityListNotificationEn = "NmoqParkListNotificationEn"
var nmoqActivityListNotificationAr = "NmoqParkListNotificationAr"
var nmoqParkNotificationEn = "NmoqParkNotificationEn"
var nmoqParkNotificationAr = "NmoqParkNotificationAr"
var nmoqParkDetailNotificationEn = "NmoqParkDetailNotificationEn"
var nmoqParkDetailNotificationAr = "NmoqParkDetailNotificationAr"

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
        inputFormatter.locale = NSLocale(localeIdentifier: "en") as Locale?
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
class UnderlinedLabel: UILabel {
    
    override var text: String? {
        didSet {
            guard let text = text else { return }
            let textRange = NSMakeRange(0, text.characters.count)
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttribute(NSAttributedStringKey.underlineStyle , value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
            // Add other attributes if needed
            self.attributedText = attributedText
        }
    }
}

class ResizableImageView: UIImageView {
    
    override var image: UIImage? {
        didSet {
            guard let image = image else { return }
            
            let resizeConstraints = [
                self.heightAnchor.constraint(equalToConstant: image.size.height),
                self.widthAnchor.constraint(equalToConstant: image.size.width)
            ]
            
            if superview != nil {
                addConstraints(resizeConstraints)
            }
        }
    }
}
extension String {
    var htmlAttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }
    var htmlString: String {
        return htmlAttributedString?.string ?? ""
    }
}
