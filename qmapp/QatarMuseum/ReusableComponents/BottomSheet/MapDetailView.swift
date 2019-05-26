//
//  MapDetailView.swift
//  QatarMuseums
//
//  Created by Exalture on 10/09/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//
import AVFoundation
import AVKit
import Crashlytics
import UIKit
import CocoaLumberjack

protocol MapDetailProtocol
{
    func dismissOvelay()
}
class MapDetailView: UIViewController,ObjectImageViewProtocol {
    
    

    @IBOutlet weak var tableView: UITableView!
    var viewMoveUp : Bool = false
    let fullView: CGFloat = 20
    var partialView: CGFloat {
        if (UIScreen.main.bounds.height >= 812) {
            return UIScreen.main.bounds.height - 240
        }
        return UIScreen.main.bounds.height - 220
    }
    var mapdetailDelegate : MapDetailProtocol?
    let closeButton = UIButton()
    var objectImagePopupView : ObjectImageView = ObjectImageView()
    var gesture = UIPanGestureRecognizer()
    var popUpArray: [TourGuideFloorMap]! = []
    var selectedIndex: Int? = 0
    var playList: String = ""
    var timer: Timer?
    var avPlayer: AVPlayer!
    var isPaused: Bool!
    var firstLoad: Bool = true
    var selectedCell : ObjectDetailTableViewCell?
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MapDetailCell", bundle: nil), forCellReuseIdentifier: "objectDetailID")
        tableView.register(UINib(nibName: "ObjectPopupView", bundle: nil), forCellReuseIdentifier: "objectPopupId")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "imageCell")
        
         gesture = UIPanGestureRecognizer.init(target: self, action: #selector(MapDetailView.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        objectImagePopupView.objectImageViewDelegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            let frame = self?.view.frame
            let yComponent = self?.partialView
            self?.view.frame = CGRect(x: 0, y: yComponent!, width: frame!.width, height: frame!.height-20 )
        })
    }
    func addCloseButton(cell : UITableViewCell) {
        // loadingView.isHidden = false
        // loadingView.showLoading()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            closeButton.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        } else {
            closeButton.frame = CGRect(x: self.view.frame.width-50, y: 10, width: 50, height: 50)
        }
        closeButton.setImage(UIImage(named: "closeX1"), for: .normal)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom:16, right: 16)
        
        closeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTouchDownAction), for: .touchDown)
        
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        closeButton.layer.shadowRadius = 5
        closeButton.layer.shadowOpacity = 1.0
        cell.addSubview(closeButton)
        //view.addSubview(closeButton)
        
    }
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        
        let y = self.view.frame.minY
      
     // fixed
        if (y+4 < partialView) {
            viewMoveUp = true
            tableView.reloadData()
        }
        else if (y+translation.y > partialView){
            viewMoveUp = false
            tableView.reloadData()
        }
        
        if (y + translation.y >= fullView) && (y + translation.y <= partialView) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
            
            duration = duration > 1.3 ? 1 : duration
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
                    self.viewMoveUp = false
                    self.tableView.reloadData()
                } else {
                    self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
                   
                    
                }
                
            }, completion: { [weak self] _ in
                if ( velocity.y < 0 ) {
//                    self?.firstLoad = true
//                    self?.selectedCell?.playerSlider.value = 0
                    self?.tableView.isScrollEnabled = true
                    self?.viewMoveUp = true
                }
            })
        }
    }
    
}

extension MapDetailView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            if( viewMoveUp == true) {

                return 0
            } else {
//                selectedCell?.avPlayer = nil
//                selectedCell?.timer?.invalidate()
                return 220
            }
            
        }else if (indexPath.row == 1) {
            return 300
        } else {
           return UITableViewAutomaticDimension
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "objectPopupId", for: indexPath) as! ObjectPopupTableViewCell
            if(selectedIndex != nil) {
                cell.setPopupDetails(mapDetails: popUpArray[selectedIndex!])
            }
            cell.selectionStyle = .none
           // return tableView.dequeueReusableCell(withIdentifier: "objectPopupId")!
            return cell
        }else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
            cell.selectionStyle = .none
            let objectImageView = UIImageView()
            objectImageView.frame = CGRect(x: 0, y: 20, width: tableView.frame.width, height: 300)
            objectImageView.image = UIImage(named: "default_imageX2")
            if(selectedIndex != nil) {
                if let imageUrl = popUpArray[selectedIndex!].image {
                    objectImageView.kf.setImage(with: URL(string: imageUrl))
                }
            }
            if(objectImageView.image == nil) {
                objectImageView.image = UIImage(named: "default_imageX2")
            }
            objectImageView.backgroundColor = UIColor.white
            objectImageView.contentMode = .scaleAspectFit
            objectImageView.clipsToBounds = true
            cell.addSubview(objectImageView)
            addCloseButton(cell: cell)
            objectImageView.isUserInteractionEnabled = true
            
            return cell
        } else {
             let cell = tableView.dequeueReusableCell(withIdentifier: "objectDetailID", for: indexPath) as! ObjectDetailTableViewCell
            cell.selectionStyle = .none
            if(selectedIndex != nil) {
                if (indexPath.row == 2){
                    cell.setObjectDetail(objectDetail: popUpArray[selectedIndex!])
                } else {
                    cell.setObjectHistoryDetail(historyDetail: popUpArray[selectedIndex!])
                }
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
                self.setPlayButtonAction(cellObj: cell, index: self.selectedIndex!)
            }
            return cell
            
           // loadingView.stopLoading()
          //  loadingView.isHidden = true
        }
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.row == 0) {
            UIView.animate(withDuration: 0.6, animations: { [weak self] in
                self?.view.frame = CGRect(x: 0, y: (self?.fullView)!, width: (self?.view.frame.width)!, height: (self?.view.frame.height)!)
                self?.viewMoveUp = true
                self?.tableView.reloadData()
            })

        } else if((indexPath.row == 1) && (popUpArray[selectedIndex!].image != "")) {
            if(selectedIndex != nil) {
                if let imageUrl = popUpArray[selectedIndex!].image {
                   self.loadObjectImagePopup(imgName: imageUrl )
                }
            }
        }
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
    func setPlayButtonAction(cellObj: ObjectDetailTableViewCell, index: Int) {
        selectedCell  = cellObj
        
            if(popUpArray.count > 0) {
                if((popUpArray[index].audioFile != nil) && (popUpArray[index].audioFile != "")){
                    if (firstLoad == true) {
                        cellObj.playButton.setImage(UIImage(named:"pause_blackX1"), for: .normal)
                        cellObj.playList = popUpArray[index].audioFile!
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
    
    @objc func didPlayToEnd() {
        // self.nextTrack()
    }
    

}

extension MapDetailView: UIGestureRecognizerDelegate {
    
    // Solution
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if (gestureRecognizer is UIPanGestureRecognizer) {
        let gesture = (gestureRecognizer) as! UIPanGestureRecognizer
            let direction = gesture.velocity(in: view).y
            
            let y = view.frame.minY
            if (y == fullView && tableView.contentOffset.y == 0 && direction > 0) || (y == partialView) {
                tableView.isScrollEnabled = false
                viewMoveUp = false
            } else {
                tableView.isScrollEnabled = true
                viewMoveUp = true
                
                
            }
            
        }
        return false
    }
    @objc func loadObjectImagePopup(imgName: String?) {
        let frameRect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        objectImagePopupView = ObjectImageView(frame: frameRect)
        objectImagePopupView.objectImageViewDelegate = self
        objectImagePopupView.loadPopup(image : imgName!)
        self.view.removeGestureRecognizer(gesture)
        self.view.addSubview(objectImagePopupView)
        
        
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "objectImageId") as! ObjectImageViewController
//        self.present(vc, animated: true, completion: nil)
    }
    @objc func closeButtonTouchDownAction(sender: UIButton!) {
        sender.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    func dismissImagePopUpView() {
        //self.dismiss(animated: false, completion: nil)
        gesture = UIPanGestureRecognizer.init(target: self, action: #selector(MapDetailView.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    @objc func buttonAction(sender: UIButton!) {
        mapdetailDelegate?.dismissOvelay()
        self.removeFromParentViewController()
        self.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: 0, height: 0)
        selectedCell?.avPlayer = nil
        selectedCell?.timer?.invalidate()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
