//
//  QMUtility.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 25/07/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Foundation



import Firebase

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
    DDLogInfo("File: \(#file)" + "Function: \(#function)")
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(defaultAction)
    if (viewController.view.window != nil) {
        viewController.present(alertController, animated: true, completion: nil)
    }
}

// Handles common backend errors and returns unhandled internal app errors if any
func handleError(viewController: UIViewController, errorType: BackendError) -> QatarMuseumError? {
    DDLogInfo("File: \(#file)" + "Function: \(#function)")
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
    DDLogInfo("File: \(#file)" + "Function: \(#function)")
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
    DDLogInfo("File: \(#file)" + "Function: \(#function)")
    var latLong = latLongString
    let delimiter = "°"
    var latLongArray = latLong.components(separatedBy: delimiter)
    var degreeString : String?
    var minString : String?
    var secString : String?
    if ((latLongArray.count) > 0) {
        degreeString = latLongArray[0]
    }
    if ((latLongArray.count) > 1) {
        latLong = latLongArray[1]
        latLongArray = latLong.components(separatedBy: delimiter)
        if ((latLongArray.count) > 0) {
            minString = latLongArray[0]
        }
        if ((latLongArray.count) > 1) {
            secString = latLongArray[1]
        }
    }
    let degree = (degreeString! as NSString).doubleValue
    let min = ((minString ?? "0") as NSString).doubleValue
    let sec = ((secString ?? "0") as NSString).doubleValue
    let ddCoordinate = degree + (min / 60) + (sec / 3600)
    return ddCoordinate
}

func showAlertView(title: String ,message: String, viewController : UIViewController) {
    DDLogInfo("File: \(#file)" + "Function: \(#function)")
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    viewController.present(alert, animated: true, completion: nil)
}
func changeDateFormat(dateString: String?) -> String? {
    DDLogInfo("File: \(#file)" + "Function: \(#function)")
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

//func firebaseAnalyticsEvents(eventName:String?) -> String? {
//    if (eventName != nil) {
//        
//    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
//            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museum_item,
//            AnalyticsParameterItemName: eventName,
//            AnalyticsParameterContentType: "cont"
//            ])
//        
//        return event
//    }
//    
//    return nil
//}

let appDelegate =  UIApplication.shared.delegate as? AppDelegate
func getContext() -> NSManagedObjectContext {
    DDLogInfo("File: \(#file)" + "Function: \(#function)")
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

public enum DisplayType {
    case unknown
    case iphone4
    case iphone5
    case iphone6
    case iphone6plus
    static let iphone7 = iphone6
    static let iphone7plus = iphone6plus
    case iphoneX
}

public final class Display {
    class var width:CGFloat { return UIScreen.main.bounds.size.width }
    class var height:CGFloat { return UIScreen.main.bounds.size.height }
    class var maxLength:CGFloat { return max(width, height) }
    class var minLength:CGFloat { return min(width, height) }
    class var zoomed:Bool { return UIScreen.main.nativeScale >= UIScreen.main.scale }
    class var retina:Bool { return UIScreen.main.scale >= 2.0 }
    class var phone:Bool { return UIDevice.current.userInterfaceIdiom == .phone }
    class var pad:Bool { return UIDevice.current.userInterfaceIdiom == .pad }
    class var carplay:Bool { return UIDevice.current.userInterfaceIdiom == .carPlay }
    class var tv:Bool { return UIDevice.current.userInterfaceIdiom == .tv }
    class var typeIsLike:DisplayType {
        if phone && maxLength < 568 {
            return .iphone4
        }
        else if phone && maxLength == 568 {
            return .iphone5
        }
        else if phone && maxLength == 667 {
            return .iphone6
        }
        else if phone && maxLength == 736 {
            return .iphone6plus
        }
        else if phone && maxLength == 812 {
            return .iphoneX
        }
        return .unknown
    }
}


extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhones_4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_X_XS = "iPhone X or iPhone XS"
        case iPhone_XR = "iPhone XR"
        case iPhone_XSMax = "iPhone XS Max"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhones_4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1792:
            return .iPhone_XR
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhones_X_XS
        case 2688:
            return .iPhone_XSMax
        default:
            return .unknown
        }
    }
}



class SegueFromLeft: UIStoryboardSegue {
    override func perform() {
        let src = self.source       //new enum
        let dst = self.destination  //new enum
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0) //Method call changed
        UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }) { (finished) in
            src.present(dst, animated: false, completion: nil) //Method call changed
        }
    }
}
class SegueFromRight: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width*2, y: 0) //Double the X-Axis
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }) { (finished) in
            src.present(dst, animated: false, completion: nil)
        }
    }
}
class FadeSegue: UIStoryboardSegue {
    
    var placeholderView: UIViewController?
    
    override func perform() {
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        if let placeholder = placeholderView {
            placeholder.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            
            placeholder.view.alpha = 0
            source.view.addSubview(placeholder.view)
            
            UIView.animate(withDuration: 0.4, animations: {
                placeholder.view.alpha = 1
            }, completion: { (finished) in
                self.source.present(self.destination, animated: false, completion: {
                    placeholder.view.removeFromSuperview()
                })
            })
        } else {
            self.destination.view.alpha = 1.0
            
            self.source.present(self.destination, animated: false, completion: {
                UIView.animate(withDuration: 0.8, animations: {
                    self.destination.view.alpha = 1.0
                })
            })
        }
    }
}
