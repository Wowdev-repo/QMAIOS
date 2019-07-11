//
//  CulturePassCardBackViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 04/11/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import UIKit

class CulturePassCardBackViewController: UIViewController {
    @IBOutlet weak var tapToFlipButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var membershipNameLbl: UILabel!
    @IBOutlet weak var membershipExpiryLbl: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nameCenter: NSLayoutConstraint!
    
    @IBOutlet weak var i_1: UILabel!
    
    var cardNumber : String? = nil
    var usernameString : String? = nil
    var displayName : String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        nameLabel.transform = CGAffineTransform(rotationAngle: (CGFloat.pi * 3) / 2)
        membershipNameLbl.transform = CGAffineTransform(rotationAngle: (CGFloat.pi * 3) / 2)
        membershipExpiryLbl.transform = CGAffineTransform(rotationAngle: (CGFloat.pi * 3) / 2)

    }
    
    func setUI() {
        tapToFlipButton.setTitle(NSLocalizedString("FLIP", comment: ""), for: .normal)
        
        i_1.text = getLocalizedStr(str: i_1.text!)
        
        nameLabel.text = QMTLSingleton.sharedInstance.userInfo.name
        
        membershipNameLbl.text = getLocalizedStr(str: QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.name)
        
        
        if dateToString(date: QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.endDateTime)  == dateToString(date: Date()) {
            membershipExpiryLbl.text = getLocalizedStr(str: "Valid through Life time")
        }else{
            membershipExpiryLbl.text = "\(getLocalizedStr(str: "Valid up to")) \(dateToString(date: QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.endDateTime))"
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapTapToFlip(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.9
        transition.type = CATransitionType(rawValue: "flip")
        transition.subtype = CATransitionSubtype.fromRight
      //  transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapClose(_ sender: UIButton) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    func dateToString(date : Date) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    

}
