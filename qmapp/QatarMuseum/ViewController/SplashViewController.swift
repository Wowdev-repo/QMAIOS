//
//  SplashViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 12/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Crashlytics
import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var splashImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

       // self.splashImageView.image = UIImage.gif(name: "QM_logo_animation")
       self.splashImageView.image = UIImage.gifImageWithName("QMLogo")
        let timer = Timer.scheduledTimer(timeInterval: 1.5,
                                                         target: self,
                                                         selector: #selector(SplashViewController.loadHome),
                                                         userInfo: nil,
                                                         repeats: false)
        
       
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
   @objc func loadHome() {
    splashImageView.stopAnimating()
    let homeView = self.storyboard?.instantiateViewController(withIdentifier: "homeId")
    let transition = CATransition()
    transition.duration = 0.25
    transition.type = kCATransitionFade
    
    transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
    view.window!.layer.add(transition, forKey: kCATransition)
    self.present(homeView!, animated: false, completion: nil)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
