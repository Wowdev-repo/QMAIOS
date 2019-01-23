//
//  MiaTourGuideDetailViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 17/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Crashlytics
import UIKit

class MiaTourGuideExploreViewController: UIViewController,HeaderViewProtocol, comingSoonPopUpProtocol {
    @IBOutlet weak var tourGuideDescription: UITextView!
    @IBOutlet weak var startTourButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var headerView: CommonHeaderView!
    
    @IBOutlet weak var miaTitle: UILabel!
    var popupView : ComingSoonPopUp = ComingSoonPopUp()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        miaTitle.font = UIFont.miatourGuideFont
        tourGuideDescription.font = UIFont.englishTitleFont
        startTourButton.titleLabel?.font = UIFont.startTourFont
        miaTitle.text = NSLocalizedString("MIA_TOUR_GUIDE_TITLE", comment: "MIA_TOUR_GUIDE_TITLE in tour guide")
        tourGuideDescription.text = NSLocalizedString("MIA_TOUR_GUIDE_DESC1", comment: "MIA_TOUR_GUIDE_DESC1 in tour guide")
            //+ "\n" + NSLocalizedString("MIA_TOUR_GUIDE_DESC2", comment: "MIA_TOUR_GUIDE_DESC2 in tour guide")
       
        headerView.headerViewDelegate = self
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            headerView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        }
        else {
            headerView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
        }
        startTourButton.setTitle(NSLocalizedString("START_TOUR", comment: "START_TOUR"), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    @IBAction func didTapPlayButton(_ sender: UIButton) {
        self.playButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        loadComingSoonPopup()
    }
    
    @IBAction func playButtonTouchDown(_ sender: UIButton) {
        self.playButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @IBAction func didTapStartTour(_ sender: UIButton) {
       
        self.startTourButton.setTitleColor(UIColor.white, for: .normal)
        self.startTourButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        let floorMapView =  self.storyboard?.instantiateViewController(withIdentifier: "floorMapId") as! FloorMapViewController
        //floorMapView.fromScienceTour = false
        floorMapView.fromTourString = fromTour.exploreTour
        self.present(floorMapView, animated: false, completion: nil)
    }
    
    @IBAction func startTourButtonTouchDown(_ sender: UIButton) {
        self.startTourButton.setTitleColor(UIColor.viewMyculTitleBlue, for: .normal)
        self.startTourButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    func loadComingSoonPopup() {
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadPopup()
        self.view.addSubview(popupView)
    }
    
    //MARK: Poup Delegate
    func closeButtonPressed() {
        self.popupView.removeFromSuperview()
    }
    
    //MARK: Header delegate
    func headerCloseButtonPressed() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false, completion: nil)
    }
}
