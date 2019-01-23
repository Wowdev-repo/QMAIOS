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
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nameCenter: NSLayoutConstraint!
    
    var cardNumber : String? = nil
    var usernameString : String? = nil
    var displayName : String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        nameLabel.transform = CGAffineTransform(rotationAngle: (CGFloat.pi * 3) / 2)
        numberLabel.transform = CGAffineTransform(rotationAngle: (CGFloat.pi * 3) / 2)
    }
    
    func setUI() {
        tapToFlipButton.setTitle(NSLocalizedString("TAP_TO_FLIP", comment: "TAP_TO_FLIP"), for: .normal)
        tapToFlipButton.titleLabel?.font = UIFont.tryAgainFont
        tapToFlipButton.layer.cornerRadius = 25
        numberLabel.font = UIFont.discoverButtonFont
        nameLabel.font = UIFont.discoverButtonFont
        if (displayName != nil) {
            nameLabel.text = displayName
        }
        if (cardNumber != nil) {
            numberLabel.text = cardNumber
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
        transition.type = "flip"
        transition.subtype = kCATransitionFromRight
      //  transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapClose(_ sender: UIButton) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    

}
