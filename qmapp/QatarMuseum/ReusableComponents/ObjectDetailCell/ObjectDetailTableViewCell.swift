//
//  ObjectDetailTableViewCell.swift
//  QatarMuseums
//
//  Created by Developer on 13/08/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import AVFoundation
import AVKit
import UIKit

class ObjectDetailTableViewCell: UITableViewCell,UITextViewDelegate,MapDetailProtocol {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var detailSecondLabel: UILabel!
    @IBOutlet weak var centerImageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var imageViewContainer: UIView!
    @IBOutlet weak var imageDetailLabel: UILabel!
    @IBOutlet weak var shareBtnViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomPadding: NSLayoutConstraint!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var sliderBottomPadding: NSLayoutConstraint!
    @IBOutlet weak var sliderTopPadding: NSLayoutConstraint!
    @IBOutlet weak var seekLoadingLabel: UILabel!
    @IBOutlet weak var accessNumberLabel: UILabel!
    
    var favBtnTapAction : (()->())?
    var shareBtnTapAction : (()->())?
    var playBtnTapAction : (()->())?
    var playList: String = ""
    var timer: Timer?
    var avPlayer: AVPlayer!
    var isPaused: Bool!
    var firstLoad: Bool = true
    var bottomSheetVC:MapDetailView = MapDetailView()
    var playerItem: AVPlayerItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        bottomSheetVC.mapdetailDelegate = self
        
        
        // Configure the view for the selected state
    }
    
    func setupCellUI() {
        titleLabel.textAlignment = .left
        descriptionLabel.textAlignment = .left
        detailSecondLabel.textAlignment = .left
        imageDetailLabel.textAlignment = .left

        titleLabel.font = UIFont.eventPopupTitleFont
        accessNumberLabel.font = UIFont.englishTitleFont
        descriptionLabel.font = UIFont.englishTitleFont
        detailSecondLabel.font = UIFont.englishTitleFont
        imageDetailLabel.font = UIFont.sideMenuLabelFont
        isPaused = true
        if ((LocalizationLanguage.currentAppleLanguage()) != ENG_LANGUAGE) {
            self.playerSlider.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }

    }
    
    func setObjectDetail(objectDetail:TourGuideFloorMap) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            titleLabel.textAlignment = .left
            accessNumberLabel.textAlignment = .left
            descriptionLabel.textAlignment = .left
            detailSecondLabel.textAlignment = .left
        } else {
            titleLabel.textAlignment = .right
            accessNumberLabel.textAlignment = .right
            descriptionLabel.textAlignment = .right
            detailSecondLabel.textAlignment = .right
        }
        titleLabel.text = objectDetail.title?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&#039;", with: "", options: .regularExpression, range: nil)
        accessNumberLabel.text = objectDetail.accessionNumber?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&#039;", with: "", options: .regularExpression, range: nil)
        descriptionLabel?.text = objectDetail.curatorialDescription?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&#039;", with: "", options: .regularExpression, range: nil)
        detailSecondLabel.text = objectDetail.objectENGSummary?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&#039;", with: "", options: .regularExpression, range: nil)
       // imageDetailLabel.text = "Saint Jerome in His Study \nDomenico Ghirlandaio (1449-1494) \nChurch of Ognissanti, Florence, 1480"
        imageDetailLabel.isHidden = true
       
        shareBtnViewHeight.constant = 0
        bottomPadding.constant = 0
        
        if ((objectDetail.audioFile != nil) && (objectDetail.audioFile != "")) {
            playButton.isHidden = false
            playerSlider.isHidden = false
            sliderTopPadding.constant = 30
            sliderBottomPadding.constant = 30
            playList = objectDetail.audioFile!
        } else {
            sliderTopPadding.constant = 0
            sliderBottomPadding.constant = 0
            playButton.isHidden = true
            playerSlider.isHidden = true
        }
        
          //  playButton.setImage(UIImage(named:"play_blackX1"), for: .normal)
        
    }
    
    func setObjectHistoryDetail(historyDetail:TourGuideFloorMap) {
        playButton.isHidden = true
        playerSlider.isHidden = true
        if ((historyDetail.objectHistory != nil) && (historyDetail.objectHistory != "")){
             titleLabel.text = "Object History"
            descriptionLabel?.text = historyDetail.objectHistory?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&#039;", with: "", options: .regularExpression, range: nil)
        }
       
      //  detailSecondLabel.text = "Like his father before him, Piero continued the family's tradition of artistic patronage, extending the collection beyond Italian Renaissance works to include Dutch and Flemish paintings, as well as rare books. This particular vase most probably remained in royal or aristocratic families for generations, before being discovered - along with four other similar vases - in a private Italian collection in 2005. Before this re-discovery, only one other albarello of its kind was recorded in the Musee des arts Decoratifs, Paris."
        //imageDetailLabel.text = "Portrait of Piero di Cosimo de' Medici \nBronzino (Agnolo di Cosimo) (1503-1572) \nFlorence, 1550-1570 \nNational Gallery, London"
        imageDetailLabel.isHidden = true
        //centerImageView.image = UIImage(named: "science_tour")
        shareBtnViewHeight.constant = 0
        bottomPadding.constant = 0
        sliderTopPadding.constant = 0
        sliderBottomPadding.constant = 0
    }
    
    @IBAction func didTapFavouriteButton(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.3,
                         animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
        completion: { finish in
            UIButton.animate(withDuration: 0.1, animations: {
                self.favoriteButton.transform = CGAffineTransform.identity
            })
            self.favBtnTapAction?()
        })
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.3,
                         animations: {
            self.shareButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
        completion: { finish in
            UIButton.animate(withDuration: 0.1, animations: {
                self.shareButton.transform = CGAffineTransform.identity
            })
            self.shareBtnTapAction?()
        })
    }
    //MARK: Audio SetUp
    func play(url:URL) {
        
        self.avPlayer = AVPlayer(playerItem: AVPlayerItem(url: url))
        if #available(iOS 10.0, *) {
            self.avPlayer.automaticallyWaitsToMinimizeStalling = false
        }
        avPlayer!.volume = 1.0
        avPlayer.play()
    }
    @IBAction func playButtonClicked(_ sender: UIButton) {
        self.playBtnTapAction?()
//        if (firstLoad == true) {
//            self.playList = "http://www.qm.org.qa/sites/default/files/floors.mp3"
//            self.play(url: URL(string:self.playList)!)
//            self.setupTimer()
//        }
//        firstLoad = false
//        if #available(iOS 10.0, *) {
//            self.togglePlayPause()
//        } else {
//            // showAlert "upgrade ios version to use this feature"
//
//        }
    }
    
    func togglePlayPause() {
        if #available(iOS 10.0, *) {
            if avPlayer.timeControlStatus == .playing  {
                    playButton.setImage(UIImage(named:"play_blackX1"), for: .normal)
                
                avPlayer.pause()
                isPaused = true
            } else {
                playButton.setImage(UIImage(named:"pause_blackX1"), for: .normal)
                avPlayer.play()
                isPaused = false
            }
        } else {
            if((avPlayer.rate != 0) && (avPlayer.error == nil)) {
                    playButton.setImage(UIImage(named:"play_blackX1"), for: .normal)
                avPlayer.pause()
                isPaused = true
            } else {
                playButton.setImage(UIImage(named:"pause_blackX1"), for: .normal)
                avPlayer.play()
                isPaused = false
            }
        }
    }
    @IBAction func sliderValueChange(_ sender: UISlider) {
//        if(firstLoad) {
//            self.playList = "http://www.qm.org.qa/sites/default/files/floors.mp3"
//            self.avPlayer = AVPlayer(playerItem: AVPlayerItem(url: URL(string: playList)!))
//        }
        if(firstLoad) {
            self.avPlayer = AVPlayer(playerItem: AVPlayerItem(url: URL(string: playList)!))
        }
        let seconds : Int64 = Int64(sender.value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        avPlayer!.seek(to: targetTime)
        if(isPaused == false){
            seekLoadingLabel.alpha = 1
        }
    }
    //    @IBAction func sliderTapped(_ sender: UILongPressGestureRecognizer) {
    //        if let slider = sender.view as? UISlider {
    //            if slider.isHighlighted { return }
    //            let point = sender.location(in: slider)
    //            let percentage = Float(point.x / slider.bounds.width)
    //            let delta = percentage * (slider.maximumValue - slider.minimumValue)
    //            let value = slider.minimumValue + delta
    //            slider.setValue(value, animated: false)
    //            let seconds : Int64 = Int64(value)
    //            let targetTime:CMTime = CMTimeMake(seconds, 1)
    //            avPlayer!.seek(to: targetTime)
    //            if(isPaused == false){
    //               // seekLoadingLabel.alpha = 1
    //            }
    //        }
    //    }
    func setupTimer(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        timer = Timer(timeInterval: 0.001, target: self, selector: #selector(ObjectDetailTableViewCell.tick), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    @objc func didPlayToEnd() {
        // self.nextTrack()
    }
    
    @objc func tick(){
        if((avPlayer.currentTime().seconds == 0.0) && (isPaused == false)){
            seekLoadingLabel.alpha = 1
        }else{
            seekLoadingLabel.alpha = 0
        }
        
        if(isPaused == false){
            if(avPlayer.rate == 0){
                avPlayer.play()
                //seekLoadingLabel.alpha = 1
            }else{
                //seekLoadingLabel.alpha = 0
            }
        }
        
        if((avPlayer.currentItem?.asset.duration) != nil){
            let currentTime1 : CMTime = (avPlayer.currentItem?.asset.duration)!
            let seconds1 : Float64 = CMTimeGetSeconds(currentTime1)
            let time1 : Float = Float(seconds1)
            playerSlider.minimumValue = 0
            playerSlider.maximumValue = time1
            let currentTime : CMTime = (self.avPlayer?.currentTime())!
            let seconds : Float64 = CMTimeGetSeconds(currentTime)
            let time : Float = Float(seconds)
            self.playerSlider.value = time
            // timeLabel.text =  self.formatTimeFromSeconds(totalSeconds: Int32(Float(Float64(CMTimeGetSeconds((self.avPlayer?.currentItem?.asset.duration)!)))))
            //currentTimeLabel.text = self.formatTimeFromSeconds(totalSeconds: Int32(Float(Float64(CMTimeGetSeconds((self.avPlayer?.currentItem?.currentTime())!)))))
            
        }else{
            playerSlider.value = 0
            playerSlider.minimumValue = 0
            playerSlider.maximumValue = 0
            //timeLabel.text = "Live stream \(self.formatTimeFromSeconds(totalSeconds: Int32(CMTimeGetSeconds((avPlayer.currentItem?.currentTime())!))))"
        }
    }
    func formatTimeFromSeconds(totalSeconds: Int32) -> String {
        let seconds: Int32 = totalSeconds%60
        let minutes: Int32 = (totalSeconds/60)%60
        let hours: Int32 = totalSeconds/3600
        return String(format: "%02d:%02d:%02d", hours,minutes,seconds)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        //self.dismiss(animated: true) {
        closeAudio()
       // }
    }
    
    func closeAudio() {
        self.avPlayer = nil
        self.timer?.invalidate()
    }
    func dismissOvelay() {
    }

    
}
