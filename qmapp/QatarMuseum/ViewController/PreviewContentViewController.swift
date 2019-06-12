//
//  PreviewContentViewController.swift
//  QatarMuseums
//
//  Created by Wakralab on 03/10/18.
//  Copyright © 2018 Qatar museums. All rights reserved.
//

import AVFoundation
import AVKit
import Crashlytics
import Firebase
import UIKit
import CocoaLumberjack

class PreviewContentViewController: UIViewController {
    @IBOutlet weak var accessNumberLabel: UILabel!
    @IBOutlet weak var objectTableView: UITableView!
    
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
        accessNumberLabel.text = NSLocalizedString("FLOOR", comment: "FLOOR text in the preview page") + " " + floorLevel + ", " + NSLocalizedString("GALLERY", comment: "GALLERY text in the preview page") + " " + galleryNumber
        accessNumberLabel.font = UIFont.sideMenuLabelFont
        if(UIScreen.main.bounds.height <= 568) {
            accessNumberLabel.font = UIFont.exhibitionDateLabelFont
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

//MARK:- TableView delegates
extension PreviewContentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tourGuideDict != nil) {
            return 3
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 300
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
            let objectImageView = UIImageView()
            objectImageView.frame = CGRect(x: 0, y: 20, width: tableView.frame.width, height: 300)
            objectImageView.image = UIImage(named: "default_imageX2")
            if let imageUrl = tourGuideDict.image {
                objectImageView.kf.setImage(with: URL(string: imageUrl))
            }
            if(objectImageView.image == nil) {
                objectImageView.image = UIImage(named: "default_imageX2")
            }
            
            objectImageView.backgroundColor = UIColor.white
            objectImageView.contentMode = .scaleAspectFit
            objectImageView.clipsToBounds = true
            cell.addSubview(objectImageView)
            cell.selectionStyle = .none
            objectImageView.isUserInteractionEnabled = true
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "objectDetailCellId", for: indexPath) as! ObjectDetailTableViewCell
            if (indexPath.row == 1) {
                cell.setObjectDetail(objectDetail: tourGuideDict)
            } else if (indexPath.row == 2) {
                cell.setObjectHistoryDetail(historyDetail: tourGuideDict)
            }
            
            cell.favBtnTapAction = {
                () in
                self.setFavouritesAction(cellObj: cell)
            }
            cell.shareBtnTapAction = {
                () in
                self.setShareAction(cellObj: cell)
            }
            cell.playBtnTapAction = {
                () in
                self.setPlayButtonAction(cellObj: cell)
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if((indexPath.row == 0) && (tourGuideDict.image != "")) {
            if let imageUrl = tourGuideDict.image {
                self.loadObjectImagePopup(imgName: imageUrl )
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_floormap_loadmap,
                    AnalyticsParameterItemName: imageUrl,
                    AnalyticsParameterContentType: "cont"
                    ])
            }
            
        }
    }
}

extension PreviewContentViewController: UIGestureRecognizerDelegate {
    
}
