//
//  PreviewContentViewController.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 03/10/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import AVFoundation
import AVKit
import Crashlytics
import Firebase
import UIKit


class PreviewContentViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var accessNumberLabel: UILabel!
    @IBOutlet weak var objectTableView: UITableView!
    @IBOutlet weak var underLineView: UIView!
    
    @IBOutlet weak var tableViewTopConstrain: NSLayoutConstraint!
    
    var tourGuideDict : TourGuideFloorMap!
    var pageIndex = Int()
    let imageView = UIImageView()
    var blurView = UIVisualEffectView()
    var objectImagePopupView : ObjectImageView = ObjectImageView()
    var playList: String = ""
    var timer: Timer?
    var avPlayer: AVPlayer!
    var isPaused: Bool!
    var firstLoad: Bool = true
    var selectedCell : ObjectDetailTableViewCell?
    
    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()
        objectTableView.register(UITableViewCell.self, forCellReuseIdentifier: "imageCell")
        setPreviewData()
        self.recordScreenView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidAppear(animated)
        self.stopAudio()
    }
    
    func setPreviewData() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let tourGuideData = tourGuideDict
        var galleryNumber: String = " "
        var floorLevel: String = " "
        if tourGuideData?.galleyNumber != nil  {
            galleryNumber = (tourGuideData?.galleyNumber?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&#039;", with: "", options: .regularExpression, range: nil))!
        }
        if tourGuideData?.galleyNumber != nil  {
            floorLevel = (tourGuideData?.floorLevel?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&#039;", with: "", options: .regularExpression, range: nil))!
        }
        if tourGuideData?.tourGuideId == "16076" || tourGuideData?.tourGuideId == "16086" { // NMoQ tourGUideIds for english n arabic
            accessNumberLabel.isHidden = true
            underLineView.isHidden = true
            tableViewTopConstrain.constant = -30
        }
        else {
            accessNumberLabel.text = NSLocalizedString("FLOOR", comment: "FLOOR text in the preview page") + " " + floorLevel + ", " + NSLocalizedString("GALLERY", comment: "GALLERY text in the preview page") + " " + galleryNumber
            accessNumberLabel.font = UIFont.sideMenuLabelFont
            if(UIScreen.main.bounds.height <= 568) {
                accessNumberLabel.font = UIFont.exhibitionDateLabelFont
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Poup Delegate
    func dismissImagePopUpView() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.objectImagePopupView.removeFromSuperview()
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func loadObjectImagePopup(imgName: String?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        objectImagePopupView = ObjectImageView(frame: self.view.frame)
        //objectImagePopupView.objectImageViewDelegate = self as! ObjectImageViewProtocol
        objectImagePopupView.loadPopup(image : imgName!)
        self.view.addSubview(objectImagePopupView)
    }

    func setFavouritesAction(cellObj: ObjectDetailTableViewCell) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if (cellObj.favoriteButton.tag == 0) {
            cellObj.favoriteButton.tag = 1
            cellObj.favoriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
        } else {
            cellObj.favoriteButton.tag = 0
            cellObj.favoriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
        }
    }
    
    func setShareAction(cellObj: ObjectDetailTableViewCell) {
        
    }
    
    func setPlayButtonAction(cellObj: ObjectDetailTableViewCell) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        selectedCell  = cellObj
        
        if(tourGuideDict != nil) {
            if((tourGuideDict.audioFile != nil) && (tourGuideDict.audioFile != "")){
                if (firstLoad == true) {
                    cellObj.playButton.setImage(UIImage(named:"pause_blackX1"), for: .normal)
                    cellObj.playList = tourGuideDict.audioFile!
                    cellObj.isPaused = false
                    cellObj.play(url: URL(string:cellObj.playList)!)
                    cellObj.setupTimer()
                } else {
                    cellObj.togglePlayPause()
                }
                firstLoad = false
            }
        }
    }
    
    func stopAudio() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if (selectedCell != nil) {
            selectedCell?.playButton.setImage(UIImage(named:"play_blackX1"), for: .normal)
            selectedCell?.playerSlider.value = 0
            selectedCell?.avPlayer = nil
            selectedCell?.timer?.invalidate()
            selectedCell?.closeAudio()
            firstLoad = true
        }
    }
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(PREVIEW_CONTENT_VC, screenClass: screenClass)
    }
}
