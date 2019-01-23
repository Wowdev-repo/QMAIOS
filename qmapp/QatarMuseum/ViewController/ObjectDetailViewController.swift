//
//  ObjectDetailViewController.swift
//  QatarMuseums
//
//  Created by Developer on 13/08/18.
//  Copyright © 2018 Exalture. All rights reserved.
//
import AVFoundation
import AVKit
import Crashlytics
import UIKit

class ObjectDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    @IBOutlet weak var objectTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    
    let imageView = UIImageView()
    var blurView = UIVisualEffectView()
    let backButton = UIButton()
    var objectImagePopupView : ObjectImageView = ObjectImageView()
    let fullView: CGFloat = 100
    let closeButton = UIButton()
    var detailArray : [TourGuideFloorMap]! = []
    var playList: String = ""
    var timer: Timer?
    var avPlayer: AVPlayer!
    var isPaused: Bool!
    var firstLoad: Bool = true
    var selectedCell : ObjectDetailTableViewCell?
    override func viewDidLoad() {
        super.viewDidLoad()
        objectTableView.register(UITableViewCell.self, forCellReuseIdentifier: "imageCell")
        setupUIContents()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setupUIContents() {
       // loadingView.isHidden = false
       // loadingView.showLoading()
        
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            closeButton.frame = CGRect(x: 10, y: 40, width: 50, height: 50)
        } else {
            closeButton.frame = CGRect(x: self.view.frame.width-50, y: 40, width: 50, height: 50)
        }
        closeButton.setImage(UIImage(named: "closeX1"), for: .normal)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom:16, right: 16)
        
        closeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTouchDownAction), for: .touchDown)
        
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        closeButton.layer.shadowRadius = 5
        closeButton.layer.shadowOpacity = 1.0
        view.addSubview(closeButton)
        
    }
    
    func setTopBarImage() {
        objectTableView.estimatedRowHeight = 50
        objectTableView.contentInset = UIEdgeInsetsMake(300, 0, 0, 0)
        
        imageView.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 300)
       // imageView.image = UIImage.init(named: "science_tour_object")
        imageView.backgroundColor = UIColor.white
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        imageView.isUserInteractionEnabled = true
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(loadObjectImagePopup))
//        imageView.addGestureRecognizer(tapGesture)
        
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = imageView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        imageView.addSubview(blurView)
        
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            backButton.frame = CGRect(x: 10, y: 30, width: 40, height: 40)
            backButton.setImage(UIImage(named: "previousImg"), for: .normal)
        } else {
            backButton.frame = CGRect(x: self.view.frame.width-50, y: 30, width: 40, height: 40)
            backButton.setImage(UIImage(named: "nextImg"), for: .normal)
        }
        backButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonTouchDownAction), for: .touchDown)
        view.addSubview(backButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: TableView delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (detailArray.count > 0) {
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
            if let imageUrl = detailArray[0].image {
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
                cell.setObjectDetail(objectDetail: detailArray[0])
            } else if (indexPath.row == 2) {
                cell.setObjectHistoryDetail(historyDetail: detailArray[0])
                
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
            loadingView.stopLoading()
            loadingView.isHidden = true
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if((indexPath.row == 0) && (detailArray[0].image != "")) {
            if let imageUrl = detailArray[0].image {
                self.loadObjectImagePopup(imgName: imageUrl )
            }
        }
    }
    
    
    //MARK: Poup Delegate
    func dismissImagePopUpView() {
        self.objectImagePopupView.removeFromSuperview()
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func loadObjectImagePopup(imgName: String?) {
        objectImagePopupView = ObjectImageView(frame: self.view.frame)
        //objectImagePopupView.objectImageViewDelegate = self as! ObjectImageViewProtocol
        objectImagePopupView.loadPopup(image : imgName!)
        self.view.addSubview(objectImagePopupView)
    }
    
    @objc func backButtonTouchDownAction(sender: UIButton) {
        sender.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @objc func backButtonPressed() {
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false, completion: nil)
    }
    
    func setFavouritesAction(cellObj: ObjectDetailTableViewCell) {
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
        selectedCell  = cellObj
        
        if(detailArray.count > 0) {
            if((detailArray[0].audioFile != nil) && (detailArray[0].audioFile != "")){
                if (firstLoad == true) {
                    cellObj.playButton.setImage(UIImage(named:"pause_blackX1"), for: .normal)
                    cellObj.playList = detailArray[0].audioFile!
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
   
    @objc func buttonAction(sender: UIButton!) {
       // sender.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//        let transition = CATransition()
//        transition.duration = 0.25
//        transition.type = kCATransitionFade
//        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
//        self.view.window!.layer.add(transition, forKey: kCATransition)
        selectedCell?.avPlayer = nil
        selectedCell?.timer?.invalidate()
        selectedCell?.closeAudio()
        dismiss(animated: false, completion: nil)
        
    }
    
    @objc func closeButtonTouchDownAction(sender: UIButton!) {
        sender.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
}

