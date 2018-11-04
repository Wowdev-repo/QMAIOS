//
//  CulturePassCardViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 22/10/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import UIKit

class CulturePassCardViewController: UIViewController {
    var membershipNumber : String? = nil
    @IBOutlet weak var membershipLabel: UILabel!
    
    @IBOutlet weak var barcodeImage: UIImageView!
    
    @IBOutlet weak var numberTrailing: NSLayoutConstraint!
    @IBOutlet weak var barcodeView: UIView!
    
    @IBOutlet weak var tapToFlipButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI ()
        
    }
    func setUI() {
        
        membershipLabel.text = NSLocalizedString("MEMBERSHIP_NUMBER", comment: "MEMBERSHIP_NUMBER in the CulturePassCard page") + " " + membershipNumber!
        membershipLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        membershipLabel.font = UIFont.settingsUpdateLabelFont
        let image = generateBarcode(from: membershipNumber!)
        
        barcodeImage.image = image
        barcodeView.layer.cornerRadius = 9
        barcodeView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            numberTrailing.constant = -90
        } else {
            numberTrailing.constant = 50
        }
        tapToFlipButton.layer.cornerRadius = 25
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
//        let cardBackView =  self.storyboard?.instantiateViewController(withIdentifier: "cardBackId") as!CulturePassCardBackViewController
//        let transition = CATransition()
//        transition.duration = 0.9
//        transition.type = "flip"
//        transition.subtype = kCATransitionFromLeft
//        view.window!.layer.add(transition, forKey: kCATransition)
//        
//        self.present(cardBackView, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
