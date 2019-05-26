//
//  EducationViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 20/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import AVKit
import AVFoundation
import Crashlytics
import Firebase
import UIKit
import YouTubePlayer
import CocoaLumberjack

class EducationViewController: UIViewController,AVPlayerViewControllerDelegate,HeaderViewProtocol {
    @IBOutlet weak var headerView: CommonHeaderView!
    @IBOutlet weak var educationTitle: UILabel!
    @IBOutlet weak var videoView: YouTubePlayerView!
    @IBOutlet weak var firstDescriptionLabel: UILabel!
    @IBOutlet weak var secondDescriptionLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var discoverButton: UIButton!
    
    var player = AVPlayer()
    var fromSideMenu : Bool = false

    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()
        setupUI()
        loadVideo()
        self.recordScreenView()
    }
    
    func setupUI() {
        loadingView.isHidden = false
        loadingView.showLoading()
        educationTitle.text = NSLocalizedString("KNOWLEDGE_ACTION_TITLE", comment: "KNOWLEDGE_ACTION_TITLE in the education page")
        firstDescriptionLabel.text = NSLocalizedString("EDUCATION_DESCRIPTION", comment: "EDUCATION_DESCRIPTION in the education page")
        secondDescriptionLabel.text = NSLocalizedString("EDUCATION_TEXT", comment: "EDUCATION_TEXT in the education page")
        //secondDescriptionLabel.text = "All of our education parameters privide interactive opportunities. We hope that they create lasting memories and lead to the development of creative, compassionate and engaged individuals.\n\n For school teachers and educators, we bring custom-made worshops, conferences and trainings to suit their needs. We also focus on working with children to encourage them to explore the world around them, engage with it, and express themselves through creative activities.\n\n All of our activities with Qatar Supreme Educational Council Professional Standards for Teachers and National Curriculum Standars."
        headerView.headerViewDelegate = self
        headerView.headerTitle.text = NSLocalizedString("EDUCATION_TITLE", comment: "EDUCATION_TITLE in the education page")
        let buttonLabel = NSLocalizedString("DISCOVER", comment: "DISCOVER in the education page")
        discoverButton.setTitle(buttonLabel, for: .normal)
        
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            
            headerView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        }
        else {
            headerView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
        }
        educationTitle.font = UIFont.heritageTitleFont
        firstDescriptionLabel.font = UIFont.englishTitleFont
        secondDescriptionLabel.font = UIFont.englishTitleFont
        discoverButton.titleLabel?.font = UIFont.discoverButtonFont
        loadingView.stopLoading()
        loadingView.isHidden = true
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func loadVideo() {
        videoView.loadVideoID("2cEYXuCTJjQ")
        
        
        
//        let videoURL = URL(string: "https://www.youtube.com/watch?v=2cEYXuCTJjQ")
//        player = AVPlayer(url: videoURL!)
//
//        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = CGRect(x: self.videoView.bounds.origin.x, y: self.videoView.bounds.origin.y, width: self.view.frame.width-30, height: 203.0)
//
//        self.videoView.layer.addSublayer(playerLayer)
     
        
        //player.play()
    }
    //MARK: header delegate
    func headerCloseButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let transition = CATransition()
        transition.duration = 0.3
        if (fromSideMenu == true) {
            transition.type = kCATransitionFade
            transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
            self.view.window!.layer.add(transition, forKey: kCATransition)
            dismiss(animated: false, completion: nil)
        } else {
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            self.view.window!.layer.add(transition, forKey: kCATransition)
            let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeId") as! HomeViewController
            let appDelegate = UIApplication.shared.delegate
            appDelegate?.window??.rootViewController = homeViewController
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_header_close,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    
    @IBAction func didTapPlayPauseButton(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
         self.playButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        if (playButton.tag == 0) {
            playButton.tag = 1
           videoView.play()
        }
        else {
            playButton.tag = 0
            videoView.pause()
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_education_play,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    
    @IBAction func didTapDiscoverButton(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
       self.discoverButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.performSegue(withIdentifier: "educationToEventSegue", sender: self)
       
        //self.discoverButton.backgroundColor = UIColor.viewMycultureBlue
        self.discoverButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        let eventView =  self.storyboard?.instantiateViewController(withIdentifier: "eventPageID") as! EventViewController
        eventView.fromHome = false
        eventView.isLoadEventPage = false
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_discover_play,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
        self.present(eventView, animated: false, completion: nil)
    }
    //For Button Animations
    @IBAction func discovereButtonTouchDown(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.discoverButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        //self.discoverButton.backgroundColor = UIColor.startTourLightBlue
    }
    @IBAction func playPauseButtonTouchDown(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.playButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    func recordScreenView() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(EDUCATION_VC, screenClass: screenClass)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "educationToEventSegue") {
            let eventView = segue.destination as! EventViewController
            eventView.fromHome = false
            eventView.isLoadEventPage = false
        }
        
    }

   

}
