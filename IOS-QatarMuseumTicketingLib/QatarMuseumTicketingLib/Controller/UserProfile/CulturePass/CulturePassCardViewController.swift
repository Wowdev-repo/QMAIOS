//
//  CulturePassCardViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 22/10/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import UIKit

class CulturePassCardViewController: UIViewController {
    
    @IBOutlet weak var membershipLabel: UILabel!
    
    @IBOutlet weak var barcodeImage: UIImageView!
    @IBOutlet weak var membershipImageView: UIImageView!

    @IBOutlet weak var i_1: UILabel!

    @IBOutlet weak var numberTrailing: NSLayoutConstraint!
    @IBOutlet weak var barcodeView: UIView!
    
    @IBOutlet weak var tapToFlipButton: UIButton!
    var membershipNumber : String? = nil
     var nameString : String? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI ()
        barcodeView.isHidden = true
        membershipLabel.isHidden = true
    }
    func setUI() {
        tapToFlipButton.setTitle(NSLocalizedString("FLIP", comment: "FLIP"), for: .normal)
        
        i_1.text = getLocalizedStr(str: i_1.text!)

        
        if QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.imgUrl != "" {
            let imgURLStr = "\(QMTLConstants.GantnerAPI.baseImgURLTest + QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.imgUrl)"
            membershipImageView.kf.indicatorType = .activity
            membershipImageView.kf.setImage(with: URL(string: imgURLStr))
        }
        
        //membershipLabel.text = NSLocalizedString("MEMBERSHIP_NUMBER", comment: "MEMBERSHIP_NUMBER in the CulturePassCard page") + " " + membershipNumber!
        //membershipLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        //membershipLabel.font = UIFont.settingsUpdateLabelFont
//        let image = generateBarcode(from: membershipNumber!)
//
//        barcodeImage.image = image
//        barcodeView.layer.cornerRadius = 9
//        barcodeView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
//        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
//            numberTrailing.constant = -90
//        } else {
//            numberTrailing.constant = 50
//        }
//        tapToFlipButton.layer.cornerRadius = 25
    }
    func generateBarcode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBAction func didTapClose(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func didTapTapToFlip(_ sender: UIButton) {
        let cardBackView =  self.storyboard?.instantiateViewController(withIdentifier: "cardBackId") as!CulturePassCardBackViewController

        
        let transition = CATransition()
        transition.duration = 0.9
        transition.type = CATransitionType(rawValue: "flip")
        transition.subtype = CATransitionSubtype.fromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        
        self.present(cardBackView, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }

}
