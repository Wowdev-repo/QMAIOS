//
//  HeritageDetailViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 21/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import CoreData
import Firebase
import MessageUI
import UIKit

enum PageName{
    case heritageDetail
    case publicArtsDetail
    case exhibitionDetail
    case SideMenuPark
    case NMoQPark
    case DiningDetail
}
class HeritageDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, comingSoonPopUpProtocol,LoadingViewProtocol, iCarouselDelegate,iCarouselDataSource,MFMailComposeViewControllerDelegate {
    @IBOutlet weak var heritageDetailTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    
    let imageView = UIImageView()
    let closeButton = UIButton()
    var blurView = UIVisualEffectView()
    var pageNameString : PageName?
    var heritageDetailtArray: [Heritage] = []
    var publicArtsDetailtArray: [PublicArtsDetail] = []
    var exhibition: [Exhibition] = []
    var parksListArray: [ParksList]! = []
    var nmoqParkDetailArray: [NMoQParkDetail]! = []
    var diningDetailtArray: [Dining] = []
    var diningDetailId : String? = nil
    var heritageDetailId : String? = nil
    var publicArtsDetailId : String? = nil
    let networkReachability = NetworkReachabilityManager()
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    var museumId : String? = nil
    var carousel = iCarousel()
    var transparentView = UIView()
    var fromHome : Bool = false
    var exhibitionId : String!
    var parkDetailId: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUIContents()
        registerCells()
        if ((pageNameString == PageName.heritageDetail) && (heritageDetailId != nil)) {
            if  (networkReachability?.isReachable)! {
                getHeritageDetailsFromServer()
            } else {
                self.fetchHeritageDetailsFromCoredata()
            }
        } else if ((pageNameString == PageName.publicArtsDetail) && (publicArtsDetailId != nil)) {
            if  (networkReachability?.isReachable)! {
                getPublicArtsDetailsFromServer()
            } else {
                self.fetchPublicArtsDetailsFromCoredata()
            }
        } else if (pageNameString == PageName.exhibitionDetail) {
            if (fromHome == true) {
                if  (networkReachability?.isReachable)! {
                    getExhibitionDetail()
                } else {
                    self.fetchExhibitionDetailsFromCoredata()
                }
            }
        } else if (pageNameString == PageName.SideMenuPark) {
            NotificationCenter.default.addObserver(self, selector: #selector(HeritageDetailViewController.receiveParksNotificationEn(notification:)), name: NSNotification.Name(parksNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(HeritageDetailViewController.receiveParksNotificationAr(notification:)), name: NSNotification.Name(parksNotificationAr), object: nil)
            self.fetchParksFromCoredata()
        } else if (pageNameString == PageName.NMoQPark) {
            if  (networkReachability?.isReachable)! {
                getNMoQParkDetailFromServer()
            } else {
                //self.fetchNMoQParkDetailFromCoredata()
                self.showNoNetwork()
                addCloseButton()
            }
        } else if (pageNameString == PageName.DiningDetail) {
            if  (networkReachability?.isReachable)! {
                getDiningDetailsFromServer()
            } else {
                self.fetchDiningDetailsFromCoredata()
            }
        }
        recordScreenView()
    }
    
    func setupUIContents() {
        loadingView.isHidden = false
        loadingView.showLoading()
        loadingView.loadingViewDelegate = self
        setTopBarImage()
    }
    func registerCells() {
        self.heritageDetailTableView.register(UINib(nibName: "HeritageDetailView", bundle: nil), forCellReuseIdentifier: "heritageDetailCellId")
        self.heritageDetailTableView.register(UINib(nibName: "ExhibitionDetailView", bundle: nil), forCellReuseIdentifier: "exhibitionDetailCellId")
        self.heritageDetailTableView.register(UINib(nibName: "ParkTableCellXib", bundle: nil), forCellReuseIdentifier: "parkCellId")
        self.heritageDetailTableView.register(UINib(nibName: "CollectionDetailView", bundle: nil), forCellReuseIdentifier: "collectionCellId")
        self.heritageDetailTableView.register(UINib(nibName: "DiningDetailCellView", bundle: nil), forCellReuseIdentifier: "diningDetailCellId")
    }
    func setTopBarImage() {
        heritageDetailTableView.estimatedRowHeight = 50
        heritageDetailTableView.contentInset = UIEdgeInsetsMake(300, 0, 0, 0)
        
        imageView.frame = CGRect(x: 0, y:20, width: UIScreen.main.bounds.size.width, height: 300)
        imageView.image = UIImage(named: "default_imageX2")
        if (pageNameString == PageName.heritageDetail) {
        
            if heritageDetailtArray.count != 0 {
                if let imageUrl = heritageDetailtArray[0].image{
                    imageView.kf.setImage(with: URL(string: imageUrl))
                }
                else {
                    imageView.image = UIImage(named: "default_imageX2")
                }
            }
            else {
                imageView.image = nil
            }
        } else if (pageNameString == PageName.publicArtsDetail){
            
            if publicArtsDetailtArray.count != 0 {
                if let imageUrl = publicArtsDetailtArray[0].image{
                    imageView.kf.setImage(with: URL(string: imageUrl))
                }
                else {
                    imageView.image = UIImage(named: "default_imageX2")
                }
            }
            else {
                imageView.image = nil
            }
        } else if (pageNameString == PageName.exhibitionDetail){
            if (fromHome == true) {
                if exhibition.count > 0 {
                    
                    if let imageUrl = exhibition[0].detailImage {
                        if(imageUrl != "") {
                            imageView.kf.setImage(with: URL(string: imageUrl))
                        }else {
                            imageView.image = UIImage(named: "default_imageX2")
                        }
                        
                    }
                    else {
                        imageView.image = UIImage(named: "default_imageX2")
                    }
                }
                else {
                    imageView.image = nil
                }
                
            } else {
                if exhibition.count > 0 {
                    
                    if let imageUrl = exhibition[0].detailImage {
                        if(imageUrl != "") {
                            imageView.kf.setImage(with: URL(string: imageUrl))
                        }else {
                            imageView.image = UIImage(named: "default_imageX2")
                        }
                        
                    }
                    else {
                        imageView.image = UIImage(named: "default_imageX2")
                    }
                } else {
                    imageView.image = nil
                }
            }
        } else if (pageNameString == PageName.SideMenuPark){
            if parksListArray.count != 0 {
                if let imageUrl = parksListArray[0].image{
                    imageView.kf.setImage(with: URL(string: imageUrl))
                }
                else {
                    imageView.image = UIImage(named: "default_imageX2")
                }
            }
            else {
                imageView.image = nil
            }
        } else if (pageNameString == PageName.NMoQPark){
            if nmoqParkDetailArray.count != 0 {
                if ( (self.nmoqParkDetailArray[0].images?.count)! > 0) {
                    if let imageUrl = nmoqParkDetailArray[0].images?[0]{
                        imageView.kf.setImage(with: URL(string: imageUrl))
                    }
                    else {
                        imageView.image = UIImage(named: "default_imageX2")
                    }
                }
                
            }
            else {
                imageView.image = nil
            }
        } else if (pageNameString == PageName.DiningDetail){
            if diningDetailtArray.count != 0 {
                if let imageUrl = diningDetailtArray[0].image{
                    imageView.kf.setImage(with: URL(string: imageUrl))
                } else if ( (self.diningDetailtArray[0].images?.count)! > 0) {
                    if let imageUrl = diningDetailtArray[0].images?[0]{
                        imageView.kf.setImage(with: URL(string: imageUrl))
                    }
                    else {
                        imageView.image = UIImage(named: "default_imageX2")
                    }
                }
            }
            else {
                imageView.image = nil
            }
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgButtonPressed))
        imageView.addGestureRecognizer(tapGesture)
        
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = imageView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        imageView.addSubview(blurView)
        addCloseButton()
    }
    func addCloseButton() {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            closeButton.frame = CGRect(x: 10, y: 30, width: 40, height: 40)
        } else {
            closeButton.frame = CGRect(x: self.view.frame.width-50, y: 30, width: 40, height: 40)
        }
        closeButton.setImage(UIImage(named: "closeX1"), for: .normal)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom:12, right: 12)
        
        closeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTouchDownAction), for: .touchDown)
        
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        closeButton.layer.shadowRadius = 5
        closeButton.layer.shadowOpacity = 1.0
        view.addSubview(closeButton)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (pageNameString == PageName.heritageDetail) {
            return heritageDetailtArray.count
        } else if (pageNameString == PageName.publicArtsDetail){
            return publicArtsDetailtArray.count
        } else if (pageNameString == PageName.exhibitionDetail){
            if (fromHome == true) {
                return exhibition.count
            }
        } else if (pageNameString == PageName.SideMenuPark) {
            return parksListArray.count
        } else if (pageNameString == PageName.NMoQPark) {
            return nmoqParkDetailArray.count
        } else if (pageNameString == PageName.DiningDetail) {
            return diningDetailtArray.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        loadingView.stopLoading()
        loadingView.isHidden = true
        let heritageCell = tableView.dequeueReusableCell(withIdentifier: "heritageDetailCellId", for: indexPath) as! HeritageDetailCell
        if ((pageNameString == PageName.heritageDetail) || (pageNameString == PageName.publicArtsDetail)) {
            if (pageNameString == PageName.heritageDetail) {
                heritageCell.setHeritageDetailData(heritageDetail: heritageDetailtArray[indexPath.row])
                heritageCell.midTitleDescriptionLabel.textAlignment = .center
            } else if(pageNameString == PageName.publicArtsDetail){
                heritageCell.setPublicArtsDetailValues(publicArsDetail: publicArtsDetailtArray[indexPath.row])
            }
            if (isHeritageImgArrayAvailable() || isPublicArtImgArrayAvailable()) {
                heritageCell.pageControl.isHidden = false
            } else {
                heritageCell.pageControl.isHidden = true
            }
            heritageCell.favBtnTapAction = {
                () in
                self.setFavouritesAction(cellObj: heritageCell)
            }
            heritageCell.shareBtnTapAction = {
                () in
                self.setShareAction(cellObj: heritageCell)
            }
            heritageCell.locationButtonTapAction = {
                () in
                self.loadLocationInMap(currentRow: indexPath.row)
            }
            
        } else if(pageNameString == PageName.exhibitionDetail){
            let cell = tableView.dequeueReusableCell(withIdentifier: "exhibitionDetailCellId", for: indexPath) as! ExhibitionDetailTableViewCell
            cell.descriptionLabel.textAlignment = .center
            if (fromHome == true) {
                cell.setHomeExhibitionDetail(exhibition: exhibition[indexPath.row])
            } else {
                cell.setMuseumExhibitionDetail()
            }
            cell.favBtnTapAction = {
                () in
                self.setFavouritesAction(cellObj: cell)
            }
            cell.shareBtnTapAction = {
                () in
                self.setShareAction(cellObj: cell)
            }
            cell.locationButtonAction = {
                () in
                self.loadLocationInMap(currentRow: indexPath.row)
            }
            cell.loadEmailComposer = {
                self.openEmail(email:"nmoq@qm.org.qa")
            }
            return cell
        } else if(pageNameString == PageName.SideMenuPark){
            let parkCell = tableView.dequeueReusableCell(withIdentifier: "parkCellId", for: indexPath) as! ParkTableViewCell
            if (indexPath.row != 0) {
                parkCell.titleLineView.isHidden = true
                parkCell.imageViewHeight.constant = 200
                
            }
            else {
                parkCell.titleLineView.isHidden = false
                parkCell.imageViewHeight.constant = 0
            }
            parkCell.favouriteButtonAction = {
                ()in
                self.setFavouritesAction(cellObj: parkCell)
            }
            parkCell.shareButtonAction = {
                () in
            }
            parkCell.locationButtonTapAction = {
                () in
                self.loadLocationInMap(currentRow: indexPath.row)
            }
            parkCell.setParksCellValues(parksList: parksListArray[indexPath.row], currentRow: indexPath.row)
            return parkCell
        } else if(pageNameString == PageName.NMoQPark){
            let parkCell = tableView.dequeueReusableCell(withIdentifier: "parkCellId", for: indexPath) as! ParkTableViewCell
            parkCell.titleLineView.isHidden = false
            parkCell.imageViewHeight.constant = 0
            parkCell.setNmoqParkDetailValues(parkDetails: nmoqParkDetailArray[indexPath.row])
            return parkCell
        } else if(pageNameString == PageName.DiningDetail){
            let diningCell = tableView.dequeueReusableCell(withIdentifier: "diningDetailCellId", for: indexPath) as! DiningDetailTableViewCell
            diningCell.titleLineView.isHidden = true
            diningCell.setDiningDetailValues(diningDetail: diningDetailtArray[indexPath.row])
            if (isImgArrayAvailable()) {
                diningCell.pageControl.isHidden = false
            } else {
                diningCell.pageControl.isHidden = true
            }
            diningCell.locationButtonAction = {
                ()in
                self.loadLocationInMap(currentRow: indexPath.row)
            }
            diningCell.favBtnTapAction = {
                () in
                self.setFavouritesAction(cellObj: diningCell)
            }
            diningCell.shareBtnTapAction = {
                () in
                self.setShareAction(cellObj: diningCell)
            }
            return diningCell
        }
        return heritageCell
    }
    
    func setFavouritesAction(cellObj :HeritageDetailCell) {
        if (cellObj.favoriteButton.tag == 0) {
            cellObj.favoriteButton.tag = 1
            cellObj.favoriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
        } else {
            cellObj.favoriteButton.tag = 0
            cellObj.favoriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
        }
    }
    
    func setShareAction(cellObj :HeritageDetailCell) {
        
    }
    func setFavouritesAction(cellObj :ExhibitionDetailTableViewCell) {
    }
    
    func setShareAction(cellObj :ExhibitionDetailTableViewCell) {
        
    }
    func setFavouritesAction(cellObj :ParkTableViewCell) {
        if (cellObj.favouriteButton.tag == 0) {
            cellObj.favouriteButton.tag = 1
            cellObj.favouriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
            
        }
        else {
            cellObj.favouriteButton.tag = 0
            cellObj.favouriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
        }
    }
    func loadLocationInMap(currentRow: Int) {
        var latitudeString  = String()
        var longitudeString = String()
        var latitude : Double?
        var longitude : Double?
            if ((pageNameString == PageName.heritageDetail) && (heritageDetailtArray[currentRow].latitude != nil) && (heritageDetailtArray[currentRow].longitude != nil)) {
            latitudeString = heritageDetailtArray[currentRow].latitude!
            longitudeString = heritageDetailtArray[currentRow].longitude!
        }
            else if ((pageNameString == PageName.publicArtsDetail) && (publicArtsDetailtArray[currentRow].latitude != nil) && (publicArtsDetailtArray[currentRow].longitude != nil))
        {
            latitudeString = publicArtsDetailtArray[currentRow].latitude!
            longitudeString = publicArtsDetailtArray[currentRow].longitude!
        }
            else if (( pageNameString == PageName.exhibitionDetail) && ( self.fromHome == true) && (exhibition[currentRow].latitude != nil) && (exhibition[currentRow].longitude != nil)) {
                latitudeString = exhibition[currentRow].latitude!
                longitudeString = exhibition[currentRow].longitude!
            } else if ( pageNameString == PageName.SideMenuPark) {
               // showLocationErrorPopup()
            } else if (( pageNameString == PageName.DiningDetail) && (diningDetailtArray[currentRow].latitude != nil) && (diningDetailtArray[currentRow].longitude != nil)) {
                latitudeString = diningDetailtArray[currentRow].latitude!
                longitudeString = diningDetailtArray[currentRow].longitude!
        }
        if latitudeString != nil && longitudeString != nil && latitudeString != "" && longitudeString != ""{
            if ((pageNameString == PageName.publicArtsDetail) || (pageNameString == PageName.DiningDetail))  {
                if let lat : Double = Double(latitudeString) {
                    latitude = lat
                }
                if let long : Double = Double(longitudeString) {
                    longitude = long
                }
                
            } else {
                latitude = convertDMSToDDCoordinate(latLongString: latitudeString)
                longitude = convertDMSToDDCoordinate(latLongString: longitudeString)
            }
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(latitude!),\(longitude!)&zoom=14&views=traffic&q=\(latitude!),\(longitude!)")!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string:"comgooglemaps://?center=\(latitude!),\(longitude!)&zoom=14&views=traffic&q=\(latitude!),\(longitude!)")!)
                }
            } else if ((latitude != nil) && (longitude != nil)) {
                let locationUrl = URL(string: "https://maps.google.com/?q=\(latitude!),\(longitude!)")!
                UIApplication.shared.openURL(locationUrl)
            } else {
                showLocationErrorPopup()
            }
        } else {
            showLocationErrorPopup()
        }
    }
    
    func showLocationErrorPopup() {
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadLocationErrorPopup()
        self.view.addSubview(popupView)
    }
    
    //MARK: Poup Delegate
    func closeButtonPressed() {
        self.popupView.removeFromSuperview()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 300 - (scrollView.contentOffset.y + 300)
        let height = min(max(y, 60), 400)
        imageView.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: height)
        
        if (imageView.frame.height >= 300 ){
            blurView.alpha  = 0.0
        } else if (imageView.frame.height >= 250 ){
            blurView.alpha  = 0.2
        } else if (imageView.frame.height >= 200 ){
            blurView.alpha  = 0.4
        } else if (imageView.frame.height >= 150 ){
            blurView.alpha  = 0.6
        } else if (imageView.frame.height >= 100 ){
            blurView.alpha  = 0.8
        } else if (imageView.frame.height >= 50 ){
            blurView.alpha  = 0.9
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        sender.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
    
    @objc func closeTouchDownAction(sender: UIButton!) {
        sender.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    //MARK: iCarousel Delegate
    func numberOfItems(in carousel: iCarousel) -> Int {
        if (isHeritageImgArrayAvailable()) {
            return (self.heritageDetailtArray[0].images?.count)!
        } else if (isPublicArtImgArrayAvailable()) {
            return (self.publicArtsDetailtArray[0].images?.count)!
        } else if(isImgArrayAvailable()) {
            return (self.diningDetailtArray[0].images?.count)!
        }
        return 0
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var itemView: UIImageView
        itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: carousel.frame.width, height: 300))
        itemView.contentMode = .scaleAspectFit
        var carouselImg: [String]?
        if (pageNameString == PageName.heritageDetail) {
            carouselImg = self.heritageDetailtArray[0].images
        } else if (pageNameString == PageName.publicArtsDetail) {
            carouselImg = self.publicArtsDetailtArray[0].images
        } else if (pageNameString == PageName.DiningDetail) {
            carouselImg = self.diningDetailtArray[0].images
        }
        if (carouselImg != nil) {
            let imageUrl = carouselImg?[index]
            if(imageUrl != nil){
                itemView.kf.setImage(with: URL(string: imageUrl!))
            }
        }
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.4
        }
        return value
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        
    }
    
    func setiCarouselView() {
        if (carousel.tag == 0) {
            transparentView.frame = self.view.frame
            transparentView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
            transparentView.isUserInteractionEnabled = true
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(closeCarouselView))
            transparentView.addGestureRecognizer(recognizer)
            self.view.addSubview(transparentView)
            
            carousel = iCarousel(frame: CGRect(x: (self.view.frame.width - 320)/2, y: 200, width: 350, height: 300))
            carousel.delegate = self
            carousel.dataSource = self
            carousel.type = .rotary
            carousel.tag = 1
            view.addSubview(carousel)
        }
    }
    
    @objc func closeCarouselView() {
        transparentView.removeFromSuperview()
        carousel.tag = 0
        carousel.removeFromSuperview()
    }
    
    @objc func imgButtonPressed() {
        if((imageView.image != nil) && (imageView.image != UIImage(named: "default_imageX2"))) {
            if (isHeritageImgArrayAvailable() || isPublicArtImgArrayAvailable() || isImgArrayAvailable()) {
                setiCarouselView()
            }
        }
    }
    
    func isHeritageImgArrayAvailable() -> Bool {
        if (pageNameString == PageName.heritageDetail) {
            if(self.heritageDetailtArray.count != 0) {
                if(self.heritageDetailtArray[0].images != nil) {
                    if((self.heritageDetailtArray[0].images?.count)! > 0) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func isPublicArtImgArrayAvailable() -> Bool {
        if (pageNameString == PageName.publicArtsDetail) {
            if(self.publicArtsDetailtArray.count != 0) {
                if(self.publicArtsDetailtArray[0].images != nil) {
                    if((self.publicArtsDetailtArray[0].images?.count)! > 0) {
                        return true
                    }
                }
            }
        }
        return false
    }
    //MARK: WebServiceCall
    func getHeritageDetailsFromServer() {
        _ = Alamofire.request(QatarMuseumRouter.HeritageDetail(["nid": heritageDetailId!])).responseObject { (response: DataResponse<Heritages>) -> Void in
            switch response.result {
            case .success(let data):
                self.heritageDetailtArray = data.heritage!
                self.setTopBarImage()
                self.saveOrUpdateHeritageCoredata()
                self.heritageDetailTableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.heritageDetailtArray.count == 0) {
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                }
            case .failure( _):
                var errorMessage: String
                errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                comment: "Setting the content of the alert"))
                self.loadingView.stopLoading()
                self.loadingView.noDataView.isHidden = false
                self.loadingView.isHidden = false
                self.loadingView.showNoDataView()
                self.loadingView.noDataLabel.text = errorMessage
            }
        }
    }
    
    //MARK: PublicArts webservice call
    func getPublicArtsDetailsFromServer() {
        _ = Alamofire.request(QatarMuseumRouter.GetPublicArtsDetail(["nid": publicArtsDetailId!])).responseObject { (response: DataResponse<PublicArtsDetails>) -> Void in
            switch response.result {
            case .success(let data):
                self.publicArtsDetailtArray = data.publicArtsDetail!
                self.setTopBarImage()
                self.saveOrUpdatePublicArtsCoredata()
                self.heritageDetailTableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.publicArtsDetailtArray.count == 0) {
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                }
            case .failure( _):
                var errorMessage: String
                errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                comment: "Setting the content of the alert"))
                self.loadingView.stopLoading()
                self.loadingView.noDataView.isHidden = false
                self.loadingView.isHidden = false
                self.loadingView.showNoDataView()
                self.loadingView.noDataLabel.text = errorMessage
            }
        }
    }
    //MARK: Heritage Coredata Method
    func saveOrUpdateHeritageCoredata() {
        if (heritageDetailtArray.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.heritageCoreDataInBackgroundThread(managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.heritageCoreDataInBackgroundThread(managedContext : managedContext)
                }
            }
        }
    }
    
    func heritageCoreDataInBackgroundThread(managedContext: NSManagedObjectContext) {
            let fetchData = checkAddedToCoredata(entityName: "HeritageEntity", idKey: "listid" , idValue: heritageDetailtArray[0].id, managedContext: managedContext) as! [HeritageEntity]
           if (fetchData.count > 0) {
                let heritageDetailDict = heritageDetailtArray[0]
            
                //update
                let heritagedbDict = fetchData[0]
            
                heritagedbDict.listname = heritageDetailDict.name
                heritagedbDict.listimage = heritageDetailDict.image
                heritagedbDict.listsortid =  heritageDetailDict.sortid
                heritagedbDict.detaillocation = heritageDetailDict.location
                heritagedbDict.detailshortdescription = heritageDetailDict.shortdescription
                heritagedbDict.detaillongdescription =  heritageDetailDict.longdescription
                heritagedbDict.detaillatitude =  heritageDetailDict.latitude
                heritagedbDict.detaillongitude = heritageDetailDict.longitude
                if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
                    heritagedbDict.lang =  "1"
                } else {
                    heritagedbDict.lang =  "0"
                }
            
            if((heritageDetailDict.images?.count)! > 0) {
                for i in 0 ... (heritageDetailDict.images?.count)!-1 {
                    var heritageImagesEntity: HeritageImagesEntity!
                    let heritageImage: HeritageImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "HeritageImagesEntity", into: managedContext) as! HeritageImagesEntity
                    heritageImage.images = heritageDetailDict.images![i]
                    
                    heritageImagesEntity = heritageImage
                    heritagedbDict.addToImagesRelation(heritageImagesEntity)
                    do {
                        try managedContext.save()
                        
                        
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    
                }
            }
            
                do{
                    try managedContext.save()
                }
                catch{
                    print(error)
                }
           } else {
            let heritageListDict : Heritage?
            heritageListDict = heritageDetailtArray[0]
            self.saveToCoreData(heritageDetailDict: heritageListDict!, managedObjContext: managedContext)
            }
    }
    
    func saveToCoreData(heritageDetailDict: Heritage, managedObjContext: NSManagedObjectContext) {
            let heritageInfo: HeritageEntity = NSEntityDescription.insertNewObject(forEntityName: "HeritageEntity", into: managedObjContext) as! HeritageEntity
            heritageInfo.listid = heritageDetailDict.id
            heritageInfo.listname = heritageDetailDict.name
            
            heritageInfo.listimage = heritageDetailDict.image
            heritageInfo.detaillocation = heritageDetailDict.location
            heritageInfo.detailshortdescription = heritageDetailDict.shortdescription
            heritageInfo.detaillongdescription =  heritageDetailDict.longdescription
            heritageInfo.detaillatitude =  heritageDetailDict.latitude
            heritageInfo.detaillongitude = heritageDetailDict.longitude
            if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
                heritageInfo.lang =  "1"
            } else {
                heritageInfo.lang =  "0"
            }
            if(heritageDetailDict.sortid != nil) {
                heritageInfo.listsortid = heritageDetailDict.sortid
            }
            
            if((heritageDetailDict.images?.count)! > 0) {
                for i in 0 ... (heritageDetailDict.images?.count)!-1 {
                    var heritageImagesEntity: HeritageImagesEntity!
                    let heritageImage: HeritageImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "HeritageImagesEntity", into: managedObjContext) as! HeritageImagesEntity
                    heritageImage.images = heritageDetailDict.images![i]
                    
                    heritageImagesEntity = heritageImage
                    heritageInfo.addToImagesRelation(heritageImagesEntity)
                    do {
                        try managedObjContext.save()
                        
                        
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }
            }
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func fetchHeritageDetailsFromCoredata() {
        let managedContext = getContext()
        do {
                var heritageArray = [HeritageEntity]()
                let heritageFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "HeritageEntity")
                if(heritageDetailId != nil) {
                    heritageFetchRequest.predicate = NSPredicate.init(format: "listid == \(heritageDetailId!)")
                    heritageArray = (try managedContext.fetch(heritageFetchRequest) as? [HeritageEntity])!
                    
                    if (heritageArray.count > 0) {
                        let heritageDict = heritageArray[0]
                        if((heritageDict.detailshortdescription != nil) && (heritageDict.detaillongdescription != nil) ) {
                            var imagesArray : [String] = []
                            let heritageImagesArray = (heritageDict.imagesRelation?.allObjects) as! [HeritageImagesEntity]
                            if(heritageImagesArray.count > 0) {
                                for i in 0 ... heritageImagesArray.count-1 {
                                    imagesArray.append(heritageImagesArray[i].images!)
                                }
                            }
                            self.heritageDetailtArray.insert(Heritage(id: heritageDict.listid, name: heritageDict.listname, location: heritageDict.detaillocation, latitude: heritageDict.detaillatitude, longitude: heritageDict.detaillongitude, image: heritageDict.listimage, shortdescription: heritageDict.detailshortdescription, longdescription: heritageDict.detaillongdescription, images: imagesArray, sortid: heritageDict.listsortid), at: 0)
                            if(heritageDetailtArray.count == 0){
                                if(self.networkReachability?.isReachable == false) {
                                    self.showNoNetwork()
                                } else {
                                    self.loadingView.showNoDataView()
                                }
                            }
                            self.setTopBarImage()
                            heritageDetailTableView.reloadData()
                        }else{
                            if(self.networkReachability?.isReachable == false) {
                                self.showNoNetwork()
                            } else {
                                self.loadingView.showNoDataView()
                            }
                        }
                    }else{
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                }
           
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK: PublicArts Coredata Method
    func saveOrUpdatePublicArtsCoredata() {
        if (publicArtsDetailtArray.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.publicArtCoreDataInBackgroundThread(managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.publicArtCoreDataInBackgroundThread(managedContext : managedContext)
                }
            }
        }
    }
    
    func publicArtCoreDataInBackgroundThread(managedContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "PublicArtsEntity", idKey: "id" , idValue: publicArtsDetailtArray[0].id, managedContext: managedContext) as! [PublicArtsEntity]
            if (fetchData.count > 0) {
                let publicArtsDetailDict = publicArtsDetailtArray[0]
                
                //update
                let publicArtsbDict = fetchData[0]
                publicArtsbDict.name = publicArtsDetailDict.name
                publicArtsbDict.detaildescription = publicArtsDetailDict.description
                publicArtsbDict.shortdescription = publicArtsDetailDict.shortdescription
                publicArtsbDict.image = publicArtsDetailDict.image
                publicArtsbDict.latitude = publicArtsDetailDict.latitude
                publicArtsbDict.longitude = publicArtsDetailDict.longitude
                if(publicArtsDetailDict.images != nil) {
                if((publicArtsDetailDict.images?.count)! > 0) {
                    for i in 0 ... (publicArtsDetailDict.images?.count)!-1 {
                        var publicArtsImagesEntity: PublicArtsImagesEntity!
                        let publicArtsImage: PublicArtsImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsImagesEntity", into: managedContext) as! PublicArtsImagesEntity
                        publicArtsImage.images = publicArtsDetailDict.images![i]
                        publicArtsImagesEntity = publicArtsImage
                        publicArtsbDict.addToPublicImagesRelation(publicArtsImagesEntity)
                        do {
                            try managedContext.save()
                            
                            
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
                do{
                    try managedContext.save()
                }
                catch{
                    print(error)
                }
            }
            else {
                let publicArtsDetailDict : PublicArtsDetail?
                publicArtsDetailDict = publicArtsDetailtArray[0]
                self.saveToCoreData(publicArtseDetailDict: publicArtsDetailDict!, managedObjContext: managedContext)
            }
        }
        else {
            let fetchData = checkAddedToCoredata(entityName: "PublicArtsEntityArabic", idKey:"id" , idValue: publicArtsDetailtArray[0].id, managedContext: managedContext) as! [PublicArtsEntityArabic]
            if (fetchData.count > 0) {
                let publicArtsDetailDict = publicArtsDetailtArray[0]
                
                //update
                
                let publicArtsdbDict = fetchData[0]
                publicArtsdbDict.namearabic = publicArtsDetailDict.name
                publicArtsdbDict.descriptionarabic = publicArtsDetailDict.description
                publicArtsdbDict.shortdescriptionarabic = publicArtsDetailDict.shortdescription
                publicArtsdbDict.imagearabic = publicArtsDetailDict.image
                publicArtsdbDict.latitudearabic = publicArtsDetailDict.latitude
                publicArtsdbDict.longitudearabic = publicArtsDetailDict.longitude
                if((publicArtsDetailDict.images?.count)! > 0) {
                    for i in 0 ... (publicArtsDetailDict.images?.count)!-1 {
                        var publicArtsImagesEntity: PublicArtsImagesEntityAr!
                        let publicArtsImage: PublicArtsImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsImagesEntityAr", into: managedContext) as! PublicArtsImagesEntityAr
                        publicArtsImage.images = publicArtsDetailDict.images![i]
                        publicArtsImagesEntity = publicArtsImage
                        publicArtsdbDict.addToPublicImagesRelation(publicArtsImagesEntity)
                        do {
                            try managedContext.save()
                            
                            
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
                do{
                    try managedContext.save()
                }
                catch{
                    print(error)
                }
            }
            else {
                let publicArtsListDict : PublicArtsDetail?
                publicArtsListDict = publicArtsDetailtArray[0]
                self.saveToCoreData(publicArtseDetailDict: publicArtsListDict!, managedObjContext: managedContext)
            }
        }
    }
    
    func saveToCoreData(publicArtseDetailDict: PublicArtsDetail, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let publicArtsInfo: PublicArtsEntity = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsEntity", into: managedObjContext) as! PublicArtsEntity
            publicArtsInfo.id = publicArtseDetailDict.id
            publicArtsInfo.name = publicArtseDetailDict.name
            publicArtsInfo.detaildescription = publicArtseDetailDict.description
            publicArtsInfo.shortdescription = publicArtseDetailDict.shortdescription
            publicArtsInfo.image = publicArtseDetailDict.image
            publicArtsInfo.latitude = publicArtseDetailDict.latitude
            publicArtsInfo.longitude = publicArtseDetailDict.longitude
            
            if((publicArtseDetailDict.images?.count)! > 0) {
                for i in 0 ... (publicArtseDetailDict.images?.count)!-1 {
                    var publicArtsImagesEntity: PublicArtsImagesEntity!
                    let publicArtsImage: PublicArtsImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsImagesEntity", into: managedObjContext) as! PublicArtsImagesEntity
                    publicArtsImage.images = publicArtseDetailDict.images![i]
                    publicArtsImagesEntity = publicArtsImage
                    publicArtsInfo.addToPublicImagesRelation(publicArtsImagesEntity)
                    do {
                        try managedObjContext.save()
                        
                        
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }
            }
        }
        else {
            let publicArtsInfo: PublicArtsEntityArabic = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsEntityArabic", into: managedObjContext) as! PublicArtsEntityArabic
            publicArtsInfo.id = publicArtseDetailDict.id
            publicArtsInfo.namearabic = publicArtseDetailDict.name
            publicArtsInfo.descriptionarabic = publicArtseDetailDict.description
            publicArtsInfo.shortdescriptionarabic = publicArtseDetailDict.shortdescription
            publicArtsInfo.imagearabic = publicArtseDetailDict.image
            publicArtsInfo.latitudearabic = publicArtseDetailDict.latitude
            publicArtsInfo.longitudearabic = publicArtseDetailDict.longitude
            
            if((publicArtseDetailDict.images?.count)! > 0) {
                for i in 0 ... (publicArtseDetailDict.images?.count)!-1 {
                    var publicArtsImagesEntity: PublicArtsImagesEntityAr!
                    let publicArtsImage: PublicArtsImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsImagesEntityAr", into: managedObjContext) as! PublicArtsImagesEntityAr
                    publicArtsImage.images = publicArtseDetailDict.images![i]
                    publicArtsImagesEntity = publicArtsImage
                    publicArtsInfo.addToPublicImagesRelation(publicArtsImagesEntity)
                    do {
                        try managedObjContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }
            }
        }
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchPublicArtsDetailsFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var publicArtsArray = [PublicArtsEntity]()
                let publicArtsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "PublicArtsEntity")
                if(publicArtsDetailId != nil) {
                    publicArtsFetchRequest.predicate = NSPredicate.init(format: "id == \(publicArtsDetailId!)")
                    publicArtsArray = (try managedContext.fetch(publicArtsFetchRequest) as? [PublicArtsEntity])!
                    
                    if (publicArtsArray.count > 0) {
                        let publicArtsDict = publicArtsArray[0]
                        if((publicArtsDict.detaildescription != nil) && (publicArtsDict.shortdescription != nil) ) {
                            
                            var imagesArray : [String] = []
                            let publicArtsImagesArray = (publicArtsDict.publicImagesRelation?.allObjects) as! [PublicArtsImagesEntity]
                            if(publicArtsImagesArray.count > 0) {
                                for i in 0 ... publicArtsImagesArray.count-1 {
                                    imagesArray.append(publicArtsImagesArray[i].images!)
                                }
                            }
                            self.publicArtsDetailtArray.insert(PublicArtsDetail(id:publicArtsDict.id , name:publicArtsDict.name, description: publicArtsDict.detaildescription, shortdescription: publicArtsDict.shortdescription, image: publicArtsDict.image, images: imagesArray,longitude: publicArtsDict.longitude, latitude: publicArtsDict.latitude), at: 0)
                            
                            if(publicArtsDetailtArray.count == 0){
                                if(self.networkReachability?.isReachable == false) {
                                    self.showNoNetwork()
                                } else {
                                    self.loadingView.showNoDataView()
                                }
                            }
                            self.setTopBarImage()
                            heritageDetailTableView.reloadData()
                        }else {
                            if(self.networkReachability?.isReachable == false) {
                                self.showNoNetwork()
                            } else {
                                self.loadingView.showNoDataView()
                            }
                        }
                    }
                    else{
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                }

            }
            else {
                var publicArtsArray = [PublicArtsEntityArabic]()
                let publicArtsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "PublicArtsEntityArabic")
                if(publicArtsDetailId != nil) {
                    publicArtsFetchRequest.predicate = NSPredicate.init(format: "id == \(publicArtsDetailId!)")
                    publicArtsArray = (try managedContext.fetch(publicArtsFetchRequest) as? [PublicArtsEntityArabic])!
                    
                    if (publicArtsArray.count > 0)  {
                        let publicArtsDict = publicArtsArray[0]
                        if((publicArtsDict.descriptionarabic != nil) && (publicArtsDict.shortdescriptionarabic != nil)) {
                            var imagesArray : [String] = []
                            let publicArtsImagesArray = (publicArtsDict.publicImagesRelation?.allObjects) as! [PublicArtsImagesEntityAr]
                            if(publicArtsImagesArray.count > 0) {
                                for i in 0 ... publicArtsImagesArray.count-1 {
                                    imagesArray.append(publicArtsImagesArray[i].images!)
                                }
                            }
                            self.publicArtsDetailtArray.insert(PublicArtsDetail(id:publicArtsDict.id , name:publicArtsDict.namearabic, description: publicArtsDict.descriptionarabic, shortdescription: publicArtsDict.shortdescriptionarabic, image: publicArtsDict.imagearabic,images: imagesArray,longitude: publicArtsDict.longitudearabic, latitude: publicArtsDict.latitudearabic), at: 0)
                            
                            
                            if(publicArtsDetailtArray.count == 0){
                                if(self.networkReachability?.isReachable == false) {
                                    self.showNoNetwork()
                                } else {
                                    self.loadingView.showNoDataView()
                                }
                            }
                            self.setTopBarImage()
                            heritageDetailTableView.reloadData()
                        }
                        else{
                            if(self.networkReachability?.isReachable == false) {
                                self.showNoNetwork()
                            } else {
                                self.loadingView.showNoDataView()
                            }
                        }
                    }
                    else{
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK: ExhibitionDetail Webservice call
    func getExhibitionDetail() {
        _ = Alamofire.request(QatarMuseumRouter.ExhibitionDetail(["nid": exhibitionId!])).responseObject { (response: DataResponse<Exhibitions>) -> Void in
            switch response.result {
            case .success(let data):
                self.exhibition = data.exhibitions!
                self.setTopBarImage()
                self.saveOrUpdateExhibitionsCoredata()
                self.heritageDetailTableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.exhibition.count == 0) {
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                }
            case .failure( _):
                var errorMessage: String
                errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                comment: "Setting the content of the alert"))
                self.loadingView.stopLoading()
                self.loadingView.noDataView.isHidden = false
                self.loadingView.isHidden = false
                self.loadingView.showNoDataView()
                self.loadingView.noDataLabel.text = errorMessage
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdateExhibitionsCoredata() {
        if (exhibition.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.exhibitionCoreDataInBackgroundThread(managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.exhibitionCoreDataInBackgroundThread(managedContext : managedContext)
                }
            }
        }
    }
    func exhibitionCoreDataInBackgroundThread(managedContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "ExhibitionsEntity", idKey: "id" , idValue: exhibition[0].id, managedContext: managedContext) as! [ExhibitionsEntity]
            if (fetchData.count > 0) {
                let exhibitionDetailDict = exhibition[0]
                
                //update
                let exhibitiondbDict = fetchData[0]
                exhibitiondbDict.detailName = exhibitionDetailDict.name
                exhibitiondbDict.detailImage = exhibitionDetailDict.detailImage
                exhibitiondbDict.detailStartDate =  exhibitionDetailDict.startDate
                exhibitiondbDict.detailEndDate = exhibitionDetailDict.endDate
                exhibitiondbDict.detailShortDesc = exhibitionDetailDict.shortDescription
                exhibitiondbDict.detailLongDesc =  exhibitionDetailDict.longDescription
                exhibitiondbDict.detailLocation =  exhibitionDetailDict.location
                exhibitiondbDict.detailLatitude = exhibitionDetailDict.latitude
                exhibitiondbDict.detailLongitude = exhibitionDetailDict.longitude
                exhibitiondbDict.status = exhibitionDetailDict.status
                
                do{
                    try managedContext.save()
                }
                catch{
                    print(error)
                }
            }
            else {
                let exhibitionListDict : Exhibition?
                exhibitionListDict = exhibition[0]
                self.saveExhibitionToCoreData(exhibitionDetailDict: exhibitionListDict!, managedObjContext: managedContext)
            }
        }
        else {
            let fetchData = checkAddedToCoredata(entityName: "ExhibitionsEntityArabic", idKey:"id" , idValue: exhibition[0].id, managedContext: managedContext) as! [ExhibitionsEntityArabic]
            if (fetchData.count > 0) {
                let exhibitionDetailDict = exhibition[0]
                
                //update
                
                let exhibitiondbDict = fetchData[0]
                exhibitiondbDict.detailNameAr = exhibitionDetailDict.name
                exhibitiondbDict.detailImgeAr = exhibitionDetailDict.detailImage
                exhibitiondbDict.detailStartDateAr =  exhibitionDetailDict.startDate
                exhibitiondbDict.detailendDateAr = exhibitionDetailDict.endDate
                exhibitiondbDict.detailShortDescAr = exhibitionDetailDict.shortDescription
                exhibitiondbDict.detailLongDescAr =  exhibitionDetailDict.longDescription
                exhibitiondbDict.detailLocationAr =  exhibitionDetailDict.location
                exhibitiondbDict.detailLatituedeAr = exhibitionDetailDict.latitude
                exhibitiondbDict.detailLongitudeAr = exhibitionDetailDict.longitude
                exhibitiondbDict.status = exhibitionDetailDict.status
                
                do{
                    try managedContext.save()
                }
                catch{
                    print(error)
                }
            } else {
                let exhibitionListDict : Exhibition?
                exhibitionListDict = exhibition[0]
                self.saveExhibitionToCoreData(exhibitionDetailDict: exhibitionListDict!, managedObjContext: managedContext)
            }
        }
    }
    func saveExhibitionToCoreData(exhibitionDetailDict: Exhibition, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let exhibitionInfo: ExhibitionsEntity = NSEntityDescription.insertNewObject(forEntityName: "ExhibitionsEntity", into: managedObjContext) as! ExhibitionsEntity
            exhibitionInfo.id = exhibitionDetailDict.id
            exhibitionInfo.detailName = exhibitionDetailDict.name
            exhibitionInfo.detailImage = exhibitionDetailDict.detailImage
            exhibitionInfo.detailStartDate = exhibitionDetailDict.startDate
            exhibitionInfo.detailEndDate = exhibitionDetailDict.endDate
            exhibitionInfo.detailShortDesc =  exhibitionDetailDict.shortDescription
            exhibitionInfo.detailLongDesc =  exhibitionDetailDict.longDescription
            exhibitionInfo.detailLocation = exhibitionDetailDict.location
            exhibitionInfo.detailLatitude =  exhibitionDetailDict.latitude
            exhibitionInfo.detailLongitude = exhibitionDetailDict.longitude
            exhibitionInfo.status = exhibitionDetailDict.status
            
        }
        else {
            let exhibitionInfo: ExhibitionsEntityArabic = NSEntityDescription.insertNewObject(forEntityName: "ExhibitionsEntityArabic", into: managedObjContext) as! ExhibitionsEntityArabic
            exhibitionInfo.id = exhibitionDetailDict.id
            exhibitionInfo.detailNameAr = exhibitionDetailDict.name
            exhibitionInfo.detailImgeAr = exhibitionDetailDict.detailImage
            exhibitionInfo.detailStartDateAr = exhibitionDetailDict.startDate
            exhibitionInfo.detailendDateAr = exhibitionDetailDict.endDate
            exhibitionInfo.detailShortDescAr =  exhibitionDetailDict.shortDescription
            exhibitionInfo.detailLongDescAr =  exhibitionDetailDict.longDescription
            exhibitionInfo.detailLocationAr = exhibitionDetailDict.location
            exhibitionInfo.detailLatituedeAr =  exhibitionDetailDict.latitude
            exhibitionInfo.detailLongitudeAr = exhibitionDetailDict.longitude
            exhibitionInfo.status = exhibitionDetailDict.status
        }
        do {
            try managedObjContext.save()
            
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func fetchExhibitionDetailsFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var exhibitionArray = [ExhibitionsEntity]()
                let exhibitionFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "ExhibitionsEntity")
                if(self.exhibitionId != nil) {
                    exhibitionFetchRequest.predicate = NSPredicate.init(format: "id == \(self.exhibitionId!)")
                }
                exhibitionArray = (try managedContext.fetch(exhibitionFetchRequest) as? [ExhibitionsEntity])!
                let exhibitionDict = exhibitionArray[0]
                if ((exhibitionArray.count > 0) && (exhibitionDict.detailLongDesc != nil) && (exhibitionDict.detailShortDesc != nil) ){
                    
                    self.exhibition.insert(Exhibition(id: exhibitionDict.id, name: exhibitionDict.detailName, image: nil,detailImage:exhibitionDict.detailImage, startDate: exhibitionDict.detailStartDate, endDate: exhibitionDict.detailEndDate, location: exhibitionDict.detailLocation, latitude: exhibitionDict.detailLatitude, longitude: exhibitionDict.detailLongitude, shortDescription: exhibitionDict.detailShortDesc, longDescription: exhibitionDict.detailLongDesc,museumId:nil,status: exhibitionDict.status, displayDate: exhibitionDict.dispalyDate), at: 0)
                    
                    if(self.exhibition.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    self.self.setTopBarImage()
                    self.heritageDetailTableView.reloadData()
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            }
            else {
                var exhibitionArray = [ExhibitionsEntityArabic]()
                let exhibitionFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "ExhibitionsEntityArabic")
                if(self.exhibitionId != nil) {
                    exhibitionFetchRequest.predicate = NSPredicate.init(format: "id == \(self.exhibitionId!)")
                }
                exhibitionArray = (try managedContext.fetch(exhibitionFetchRequest) as? [ExhibitionsEntityArabic])!
                let exhibitionDict = exhibitionArray[0]
                if ((exhibitionArray.count > 0) && (exhibitionDict.detailLongDescAr != nil) && (exhibitionDict.detailShortDescAr != nil)) {
                    
                    self.exhibition.insert(Exhibition(id: exhibitionDict.id, name: exhibitionDict.detailNameAr, image: nil,detailImage:exhibitionDict.detailImgeAr, startDate: exhibitionDict.detailStartDateAr, endDate: exhibitionDict.detailendDateAr, location: exhibitionDict.detailLocationAr, latitude: exhibitionDict.detailLatituedeAr, longitude: exhibitionDict.detailLongitudeAr, shortDescription: exhibitionDict.detailShortDescAr, longDescription: exhibitionDict.detailLongDescAr,museumId:nil,status: exhibitionDict.status, displayDate: exhibitionDict.displayDateAr), at: 0)
                    
                    
                    if(self.exhibition.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    self.setTopBarImage()
                    self.heritageDetailTableView.reloadData()
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK: Parks WebServiceCall
    func getParksDataFromServer()
    {
        _ = Alamofire.request(QatarMuseumRouter.ParksList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<ParksLists>) -> Void in
            switch response.result {
            case .success(let data):
                if (self.parksListArray.count == 0) {
                    self.parksListArray = data.parkList
                    self.heritageDetailTableView.reloadData()
                    if(self.parksListArray.count == 0) {
                        self.addCloseButton()
                        var errorMessage: String
                        errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                        comment: "Setting the content of the alert"))
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                        self.loadingView.noDataLabel.text = errorMessage
                    }
                }
                if (self.parksListArray.count > 0)  {
                    self.saveOrUpdateParksCoredata(parksListArray: data.parkList)
                    //if let imageUrl = self.parksListArray[0].image{
                        self.setTopBarImage()
//                    } else {
//                        self.imageView.image = UIImage(named: "default_imageX2")
//                    }
                    
                }
                // }
                
            case .failure( _):
                print("error")
                if(self.parksListArray.count == 0) {
                    self.addCloseButton()
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                    self.loadingView.noDataLabel.text = errorMessage
                }
                
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdateParksCoredata(parksListArray:[ParksList]? ) {
        if (parksListArray!.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.parksCoreDataInBackgroundThread(managedContext: managedContext, parksListArray: parksListArray)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.parksCoreDataInBackgroundThread(managedContext : managedContext, parksListArray: parksListArray)
                }
            }
        }
    }
    func parksCoreDataInBackgroundThread(managedContext: NSManagedObjectContext,parksListArray:[ParksList]?) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "ParksEntity", idKey: nil, idValue: nil, managedContext: managedContext) as! [ParksEntity]
            if (fetchData.count > 0) {
                let isDeleted = self.deleteExistingEvent(managedContext: managedContext, entityName: "ParksEntity")
                if(isDeleted == true) {
                    for i in 0 ... parksListArray!.count-1 {
                        let parksDict : ParksList?
                        parksDict = parksListArray![i]
                        self.saveParksToCoreData(parksDict: parksDict!, managedObjContext: managedContext)
                        
                    }
                }
            }
            else {
                for i in 0 ... parksListArray!.count-1 {
                    let parksDict : ParksList?
                    parksDict = parksListArray![i]
                    self.saveParksToCoreData(parksDict: parksDict!, managedObjContext: managedContext)
                    
                }
            }
        }
        else {
            let fetchData = checkAddedToCoredata(entityName: "ParksEntityArabic", idKey: nil, idValue: nil, managedContext: managedContext) as! [ParksEntityArabic]
            if (fetchData.count > 0) {
                let isDeleted = self.deleteExistingEvent(managedContext: managedContext, entityName: "ParksEntityArabic")
                if(isDeleted == true) {
                    for i in 0 ... parksListArray!.count-1 {
                        let parksDict : ParksList?
                        parksDict = parksListArray![i]
                        self.saveParksToCoreData(parksDict: parksDict!, managedObjContext: managedContext)
                        
                    }
                }
            }
            else {
                for i in 0 ... parksListArray!.count-1 {
                    let parksDict : ParksList?
                    parksDict = parksListArray![i]
                    self.saveParksToCoreData(parksDict: parksDict!, managedObjContext: managedContext)
                    
                }
            }
        }
    }
    func saveParksToCoreData(parksDict: ParksList, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let parksInfo: ParksEntity = NSEntityDescription.insertNewObject(forEntityName: "ParksEntity", into: managedObjContext) as! ParksEntity
            parksInfo.title = parksDict.title
            parksInfo.parksDescription = parksDict.description
            parksInfo.image = parksDict.image
            if(parksDict.sortId != nil) {
                parksInfo.sortId = parksDict.sortId
            }
        }
        else {
            let parksInfo: ParksEntityArabic = NSEntityDescription.insertNewObject(forEntityName: "ParksEntityArabic", into: managedObjContext) as! ParksEntityArabic
            parksInfo.titleArabic = parksDict.title
            parksInfo.descriptionArabic = parksDict.description
            parksInfo.imageArabic = parksDict.image
            if(parksDict.sortId != nil) {
                parksInfo.sortIdArabic = parksDict.sortId
            }
        }
        do {
            try managedObjContext.save()
            
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func fetchParksFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var parksArray = [ParksEntity]()
                let parksFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "ParksEntity")
                parksArray = (try managedContext.fetch(parksFetchRequest) as? [ParksEntity])!
                
                if (parksArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getParksDataFromServer()
                        }
                    }
                    for i in 0 ... parksArray.count-1 {
                        self.parksListArray.insert(ParksList(title: parksArray[i].title, description: parksArray[i].parksDescription, sortId: parksArray[i].sortId, image: parksArray[i].image), at: i)
                        
                    }
                    if(parksListArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    //if let imageUrl = parksListArray[0].image {
                    self.setTopBarImage()
//                    } else {
//                        imageView.image = UIImage(named: "default_imageX2")
//                    }
                    
                    heritageDetailTableView.reloadData()
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                        self.addCloseButton()
                    } else {
                        //self.loadingView.showNoDataView()
                        self.getParksDataFromServer()//coreDataMigratio  solution
                        self.addCloseButton()
                    }
                }
            }
            else {
                var parksArray = [ParksEntityArabic]()
                let parksFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "ParksEntityArabic")
                parksArray = (try managedContext.fetch(parksFetchRequest) as? [ParksEntityArabic])!
                if (parksArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getParksDataFromServer()
                        }
                    }
                    for i in 0 ... parksArray.count-1 {
                        self.parksListArray.insert(ParksList(title: parksArray[i].titleArabic, description: parksArray[i].descriptionArabic, sortId: parksArray[i].sortIdArabic, image: parksArray[i].imageArabic), at: i)
                    }
                    if(parksArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                   // if let imageUrl = parksListArray[0].image {
                        self.setTopBarImage()
//                    }else {
//                        imageView.image = UIImage(named: "default_imageX2")
//                    }
                    heritageDetailTableView.reloadData()
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                        self.addCloseButton()
                    } else {
                        //self.loadingView.showNoDataView()
                        self.getParksDataFromServer()//coreDataMigratio  solution
                        self.addCloseButton()
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            if(self.networkReachability?.isReachable == false) {
                self.showNoNetwork()
                self.addCloseButton()
            }
        }
    }
    //MARK : NMoQPark
    func getNMoQParkDetailFromServer() {
        if (parkDetailId != nil) {
            _ = Alamofire.request(QatarMuseumRouter.GetNMoQPlaygroundDetail(LocalizationLanguage.currentAppleLanguage(), ["nid": parkDetailId!])).responseObject { (response: DataResponse<NMoQParksDetail>) -> Void in
                switch response.result {
                case .success(let data):
                    self.nmoqParkDetailArray = data.nmoqParksDetail
                    // self.saveOrUpdateNmoqParkDetailCoredata(nmoqParkList: data.nmoqParksDetail)
                    self.heritageDetailTableView.reloadData()
//                    if(self.nmoqParkDetailArray.count > 0) {
//                        if ( (self.nmoqParkDetailArray[0].images?.count)! > 0) {
//                            if let imageUrl = self.nmoqParkDetailArray[0].images?[0] {
                    self.setTopBarImage()
//                            } else {
//                                self.imageView.image = UIImage(named: "default_imageX2")
//                            }
//
//                        }
//                    }
                    
                    self.loadingView.stopLoading()
                    self.loadingView.isHidden = true
                    if (self.nmoqParkDetailArray.count == 0) {
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                    }
                    
                case .failure( _):
                    self.addCloseButton()
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                    self.loadingView.noDataLabel.text = errorMessage
                }
            }
        }
        
    }
    //MARK: NMoq Playground Parks Detail Coredata Method
    func saveOrUpdateNmoqParkDetailCoredata(nmoqParkList: [NMoQParkDetail]?) {
        if ((nmoqParkList?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.nmoqParkDetailCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.nmoqParkDetailCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext : managedContext)
                }
            }
        }
    }
    func nmoqParkDetailCoreDataInBackgroundThread(nmoqParkList: [NMoQParkDetail]?, managedContext: NSManagedObjectContext) {
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "NMoQParkDetailEntity", idKey: "nid", idValue: nil, managedContext: managedContext) as! [NMoQParkDetailEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict = nmoqParkList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQParkDetailEntity", idKey: "nid", idValue: nmoqParkListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let nmoqParkListdbDict = fetchResult[0] as! NMoQParkDetailEntity
                        nmoqParkListdbDict.title = nmoqParkListDict.title
                        nmoqParkListdbDict.nid =  nmoqParkListDict.nid
                        nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
                        nmoqParkListdbDict.parkDesc =  nmoqParkListDict.parkDesc
                        
                        if(nmoqParkListDict.images != nil){
                            if((nmoqParkListDict.images?.count)! > 0) {
                                for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                                    var parkListImage: NMoQParkDetailImgEntity!
                                    let parkListImageArray: NMoQParkDetailImgEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkDetailImgEntity", into: managedContext) as! NMoQParkDetailImgEntity
                                    parkListImageArray.images = nmoqParkListDict.images![i]
                                    
                                    parkListImage = parkListImageArray
                                    nmoqParkListdbDict.addToParkDetailImgRelation(parkListImage)
                                    do {
                                        try managedContext.save()
                                    } catch let error as NSError {
                                        print("Could not save. \(error), \(error.userInfo)")
                                    }
                                }
                            }
                        }
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveNMoQParkDetailToCoreData(nmoqParkListDict: nmoqParkListDict, managedObjContext: managedContext)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkDetailNotificationEn), object: self)
            } else {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict : NMoQParkDetail?
                    nmoqParkListDict = nmoqParkList?[i]
                    self.saveNMoQParkDetailToCoreData(nmoqParkListDict: nmoqParkListDict!, managedObjContext: managedContext)
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkDetailNotificationEn), object: self)
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "NMoQParkDetailEntityAr", idKey: "nid", idValue: nil, managedContext: managedContext) as! [NMoQParkDetailEntityAr]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict = nmoqParkList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQParkDetailEntityAr", idKey: "nid", idValue: nmoqParkListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let nmoqParkListdbDict = fetchResult[0] as! NMoQParkDetailEntityAr
                        nmoqParkListdbDict.title = nmoqParkListDict.title
                        nmoqParkListdbDict.nid =  nmoqParkListDict.nid
                        nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
                        nmoqParkListdbDict.parkDesc =  nmoqParkListDict.parkDesc
                        
                        if(nmoqParkListDict.images != nil){
                            if((nmoqParkListDict.images?.count)! > 0) {
                                for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                                    var parkListImage: NMoQParkDetailImgEntityAr!
                                    let parkListImageArray: NMoQParkDetailImgEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkDetailImgEntityAr", into: managedContext) as! NMoQParkDetailImgEntityAr
                                    parkListImageArray.images = nmoqParkListDict.images![i]
                                    
                                    parkListImage = parkListImageArray
                                    nmoqParkListdbDict.addToParkDetailImgRelationAr(parkListImage)
                                    do {
                                        try managedContext.save()
                                    } catch let error as NSError {
                                        print("Could not save. \(error), \(error.userInfo)")
                                    }
                                }
                            }
                        }
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveNMoQParkDetailToCoreData(nmoqParkListDict: nmoqParkListDict, managedObjContext: managedContext)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkDetailNotificationAr), object: self)
            } else {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict : NMoQParkDetail?
                    nmoqParkListDict = nmoqParkList![i]
                    self.saveNMoQParkDetailToCoreData(nmoqParkListDict: nmoqParkListDict!, managedObjContext: managedContext)
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkDetailNotificationAr), object: self)
            }
        }
    }
    func saveNMoQParkDetailToCoreData(nmoqParkListDict: NMoQParkDetail, managedObjContext: NSManagedObjectContext) {
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            let nmoqParkListdbDict: NMoQParkDetailEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkDetailEntity", into: managedObjContext) as! NMoQParkDetailEntity
            nmoqParkListdbDict.title = nmoqParkListDict.title
            nmoqParkListdbDict.nid =  nmoqParkListDict.nid
            nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
            nmoqParkListdbDict.parkDesc =  nmoqParkListDict.parkDesc
            
            if(nmoqParkListDict.images != nil){
                if((nmoqParkListDict.images?.count)! > 0) {
                    for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                        var parkListImage: NMoQParkDetailImgEntity!
                        let parkListImageArray: NMoQParkDetailImgEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkDetailImgEntity", into: managedObjContext) as! NMoQParkDetailImgEntity
                        parkListImageArray.images = nmoqParkListDict.images![i]
                        
                        parkListImage = parkListImageArray
                        nmoqParkListdbDict.addToParkDetailImgRelation(parkListImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
        } else {
            let nmoqParkListdbDict: NMoQParkDetailEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkDetailEntityAr", into: managedObjContext) as! NMoQParkDetailEntityAr
            nmoqParkListdbDict.title = nmoqParkListDict.title
            nmoqParkListdbDict.nid =  nmoqParkListDict.nid
            nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
            nmoqParkListdbDict.parkDesc =  nmoqParkListDict.parkDesc
            
            if(nmoqParkListDict.images != nil){
                if((nmoqParkListDict.images?.count)! > 0) {
                    for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                        var parkListImage: NMoQParkDetailImgEntityAr!
                        let parkListImageArray: NMoQParkDetailImgEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkDetailImgEntityAr", into: managedObjContext) as! NMoQParkDetailImgEntityAr
                        parkListImageArray.images = nmoqParkListDict.images![i]
                        
                        parkListImage = parkListImageArray
                        nmoqParkListdbDict.addToParkDetailImgRelationAr(parkListImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
        }
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchNMoQParkDetailFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var parkListArray = [NMoQParkDetailEntity]()
                parkListArray = checkAddedToCoredata(entityName: "NMoQParkDetailEntity", idKey: "nid", idValue: parkDetailId, managedContext: managedContext) as! [NMoQParkDetailEntity]
                if (parkListArray.count > 0) {
                    for i in 0 ... parkListArray.count-1 {
                        let parkListDict = parkListArray[i]
                        var imagesArray : [String] = []
                        let imagesInfoArray = (parkListDict.parkDetailImgRelation?.allObjects) as! [NMoQParkDetailImgEntity]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].images!)
                            }
                        }
                        self.nmoqParkDetailArray.insert(NMoQParkDetail(title: parkListDict.title, sortId: parkListDict.sortId, nid: parkListDict.nid, images: imagesArray, parkDesc: parkListDict.parkDesc), at: i)
                    }
                    if(nmoqParkDetailArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    } else {
                        if self.nmoqParkDetailArray.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                            self.nmoqParkDetailArray = self.nmoqParkDetailArray.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                        }
                       // if ( (self.nmoqParkDetailArray[0].images?.count)! > 0) {
                           // if let imageUrl = self.nmoqParkDetailArray[0].images?[0] {
                        self.setTopBarImage()
//                            } else {
//                                self.imageView.image = UIImage(named: "default_imageX2")
//                            }
                            
                        //}
                    }
                    heritageDetailTableView.reloadData()
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            } else {
                var parkListArray = [NMoQParkDetailEntityAr]()
                parkListArray = checkAddedToCoredata(entityName: "NMoQParkDetailEntityAr", idKey: "nid", idValue: parkDetailId, managedContext: managedContext) as! [NMoQParkDetailEntityAr]
                if (parkListArray.count > 0) {
                    for i in 0 ... parkListArray.count-1 {
                        let parkListDict = parkListArray[i]
                        var imagesArray : [String] = []
                        let imagesInfoArray = (parkListDict.parkDetailImgRelationAr?.allObjects) as! [NMoQParkDetailImgEntityAr]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].images!)
                            }
                        }
                        self.nmoqParkDetailArray.insert(NMoQParkDetail(title: parkListDict.title, sortId: parkListDict.sortId, nid: parkListDict.nid, images: imagesArray, parkDesc: parkListDict.parkDesc), at: i)
                    }
                    if(nmoqParkDetailArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    } else {
                        if self.nmoqParkDetailArray.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                            self.nmoqParkDetailArray = self.nmoqParkDetailArray.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                        }
                    }
                    heritageDetailTableView.reloadData()
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            if(self.networkReachability?.isReachable == false) {
                self.showNoNetwork()
                self.addCloseButton()
            }
        }
    }
    //MARK: Dining WebServiceCall
    func getDiningDetailsFromServer() {
        _ = Alamofire.request(QatarMuseumRouter.GetDiningDetail(["nid": diningDetailId!])).responseObject { (response: DataResponse<Dinings>) -> Void in
            switch response.result {
            case .success(let data):
                self.diningDetailtArray = data.dinings!
                self.setTopBarImage()
                self.saveOrUpdateDiningDetailCoredata()
                self.heritageDetailTableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.diningDetailtArray.count == 0) {
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                }
            case .failure( _):
                var errorMessage: String
                errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                comment: "Setting the content of the alert"))
                self.loadingView.stopLoading()
                self.loadingView.noDataView.isHidden = false
                self.loadingView.isHidden = false
                self.loadingView.showNoDataView()
                self.loadingView.noDataLabel.text = errorMessage
            }
        }
    }
    //MARK: Dining Coredata Method
    func saveOrUpdateDiningDetailCoredata() {
        if (diningDetailtArray.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.diningCoreDataInBackgroundThread(managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.diningCoreDataInBackgroundThread(managedContext : managedContext)
                }
            }
        }
    }
    func diningCoreDataInBackgroundThread(managedContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "DiningEntity", idKey: "id", idValue: diningDetailtArray[0].id, managedContext: managedContext) as! [DiningEntity]
            if (fetchData.count > 0) {
                let diningDetailDict = diningDetailtArray[0]
                
                //update
                let diningdbDict = fetchData[0] as! DiningEntity
                diningdbDict.name = diningDetailDict.name
                diningdbDict.image = diningDetailDict.image
                diningdbDict.diningdescription = diningDetailDict.description
                diningdbDict.closetime = diningDetailDict.closetime
                diningdbDict.openingtime =  diningDetailDict.openingtime
                diningdbDict.sortid =  diningDetailDict.sortid
                diningdbDict.location =  diningDetailDict.location
                if((diningDetailDict.images?.count)! > 0) {
                    for i in 0 ... (diningDetailDict.images?.count)!-1 {
                        var diningImagesEntity: DiningImagesEntity!
                        let diningImage: DiningImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "DiningImagesEntity", into: managedContext) as! DiningImagesEntity
                        diningImage.images = diningDetailDict.images![i]
                        
                        diningImagesEntity = diningImage
                        diningdbDict.addToImagesRelation(diningImagesEntity)
                        do {
                            try managedContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                        
                    }
                }
                do{
                    try managedContext.save()
                }
                catch{
                    print(error)
                }
            } else {
                let diningListDict : Dining?
                diningListDict = diningDetailtArray[0]
                self.saveDiningDetailToCoreData(diningDetailDict: diningListDict!, managedObjContext: managedContext)
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "DiningEntityArabic", idKey: "id", idValue: diningDetailtArray[0].id, managedContext: managedContext) as! [DiningEntityArabic]
            if (fetchData.count > 0) {
                let diningDetailDict = diningDetailtArray[0]
                
                //update
                let diningdbDict = fetchData[0]
                diningdbDict.namearabic = diningDetailDict.name
                diningdbDict.imagearabic = diningDetailDict.image
                diningdbDict.sortidarabic =  diningDetailDict.sortid
                diningdbDict.descriptionarabic = diningDetailDict.description
                diningdbDict.closetimearabic = diningDetailDict.closetime
                diningdbDict.openingtimearabic =  diningDetailDict.openingtime
                diningdbDict.locationarabic =  diningDetailDict.location
                if((diningDetailDict.images?.count)! > 0) {
                    for i in 0 ... (diningDetailDict.images?.count)!-1 {
                        var diningImagesEntity: DiningImagesEntityAr!
                        let diningImage: DiningImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "DiningImagesEntityAr", into: managedContext) as! DiningImagesEntityAr
                        diningImage.images = diningDetailDict.images![i]
                        
                        diningImagesEntity = diningImage
                        diningdbDict.addToImagesRelation(diningImagesEntity)
                        do {
                            try managedContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                        
                    }
                }
                do{
                    try managedContext.save()
                }
                catch{
                    print(error)
                }
            } else {
                let diningListDict : Dining?
                diningListDict = diningDetailtArray[0]
                self.saveDiningDetailToCoreData(diningDetailDict: diningListDict!, managedObjContext: managedContext)
            }
        }
    }
    func saveDiningDetailToCoreData(diningDetailDict: Dining, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            let diningInfo: DiningEntity = NSEntityDescription.insertNewObject(forEntityName: "DiningEntity", into: managedObjContext) as! DiningEntity
            diningInfo.id = diningDetailDict.id
            diningInfo.name = diningDetailDict.name
            diningInfo.image = diningDetailDict.image
            diningInfo.diningdescription = diningDetailDict.description
            diningInfo.closetime = diningDetailDict.closetime
            diningInfo.openingtime =  diningDetailDict.openingtime
            diningInfo.location =  diningDetailDict.location
            if((diningDetailDict.images?.count)! > 0) {
                for i in 0 ... (diningDetailDict.images?.count)!-1 {
                    var diningImagesEntity: DiningImagesEntity!
                    let diningImage: DiningImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "DiningImagesEntity", into: managedObjContext) as! DiningImagesEntity
                    diningImage.images = diningDetailDict.images![i]
                    
                    diningImagesEntity = diningImage
                    diningInfo.addToImagesRelation(diningImagesEntity)
                    do {
                        try managedObjContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    
                }
            }
            if(diningDetailDict.sortid != nil) {
                diningInfo.sortid = diningDetailDict.sortid
            }
        } else {
            let diningInfo: DiningEntityArabic = NSEntityDescription.insertNewObject(forEntityName: "DiningEntityArabic", into: managedObjContext) as! DiningEntityArabic
            diningInfo.locationarabic = diningDetailDict.id
            diningInfo.namearabic = diningDetailDict.name
            
            diningInfo.imagearabic = diningDetailDict.image
            diningInfo.descriptionarabic = diningDetailDict.description
            diningInfo.closetimearabic = diningDetailDict.closetime
            diningInfo.openingtimearabic =  diningDetailDict.openingtime
            diningInfo.locationarabic =  diningDetailDict.location
            if((diningDetailDict.images?.count)! > 0) {
                for i in 0 ... (diningDetailDict.images?.count)!-1 {
                    var diningImagesEntity: DiningImagesEntityAr!
                    let diningImage: DiningImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "DiningImagesEntityAr", into: managedObjContext) as! DiningImagesEntityAr
                    diningImage.images = diningDetailDict.images![i]
                    
                    diningImagesEntity = diningImage
                    diningInfo.addToImagesRelation(diningImagesEntity)
                    do {
                        try managedObjContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }
            }
            if(diningDetailDict.sortid != nil) {
                diningInfo.sortidarabic = diningDetailDict.sortid
            }
        }
        do {
            try managedObjContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func fetchDiningDetailsFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
                var diningArray = [DiningEntity]()
                let diningFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "DiningEntity")
                if(diningDetailId != nil) {
                    diningFetchRequest.predicate = NSPredicate.init(format: "id == \(diningDetailId!)")
                }
                diningArray = (try managedContext.fetch(diningFetchRequest) as? [DiningEntity])!
                let diningDict = diningArray[0]
                if ((diningArray.count > 0) && (diningDict.diningdescription != nil)) {
                    var imagesArray : [String] = []
                    let diningImagesArray = (diningDict.imagesRelation?.allObjects) as! [DiningImagesEntity]
                    if(diningImagesArray.count > 0) {
                        for i in 0 ... diningImagesArray.count-1 {
                            imagesArray.append(diningImagesArray[i].images!)
                        }
                    }
                    self.diningDetailtArray.insert(Dining(id: diningDict.id, name: diningDict.name, location: diningDict.location, description: diningDict.diningdescription, image: diningDict.image, openingtime: diningDict.openingtime, closetime: diningDict.closetime, sortid: diningDict.sortid, museumId: nil, images: imagesArray), at: 0)
                    if(diningDetailtArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    self.setTopBarImage()
                    heritageDetailTableView.reloadData()
                } else {
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            }
            else {
                var diningArray = [DiningEntityArabic]()
                let diningFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "DiningEntityArabic")
                if(diningDetailId != nil) {
                    diningFetchRequest.predicate = NSPredicate.init(format: "id == \(diningDetailId!)")
                }
                diningArray = (try managedContext.fetch(diningFetchRequest) as? [DiningEntityArabic])!
                let diningDict = diningArray[0]
                if ((diningArray.count > 0) && (diningDict.descriptionarabic != nil)) {var imagesArray : [String] = []
                    let diningImagesArray = (diningDict.imagesRelation?.allObjects) as! [DiningImagesEntityAr]
                    if(diningImagesArray.count > 0) {
                        for i in 0 ... diningImagesArray.count-1 {
                            imagesArray.append(diningImagesArray[i].images!)
                        }
                    }
                    self.diningDetailtArray.insert(Dining(id: diningDict.id, name: diningDict.namearabic, location: diningDict.locationarabic, description: diningDict.descriptionarabic, image: diningDict.imagearabic, openingtime: diningDict.openingtimearabic, closetime: diningDict.closetimearabic, sortid: diningDict.sortidarabic, museumId:nil, images: imagesArray), at: 0)
                    
                    if(diningDetailtArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    self.setTopBarImage()
                    heritageDetailTableView.reloadData()
                } else {
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    func setFavouritesAction(cellObj :DiningDetailTableViewCell) {
        if (cellObj.favoriteButton.tag == 0) {
            cellObj.favoriteButton.tag = 1
            cellObj.favoriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
        } else {
            cellObj.favoriteButton.tag = 0
            cellObj.favoriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
        }
    }
    
    func setShareAction(cellObj :DiningDetailTableViewCell) {
        
    }
    func isImgArrayAvailable() -> Bool {
        if(self.diningDetailtArray.count != 0) {
            if(self.diningDetailtArray[0].images != nil) {
                if((self.diningDetailtArray[0].images?.count)! > 0) {
                    return true
                }
            }
        }
        return false
    }
    func checkAddedToCoredata(entityName: String?,idKey:String?, idValue: String?, managedContext: NSManagedObjectContext) -> [NSManagedObject] {
        var fetchResults : [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName!)
        if (idValue != nil) {
            fetchRequest.predicate = NSPredicate.init(format: "\(idKey!) == \(idValue!)")
        }
        fetchResults = try! managedContext.fetch(fetchRequest)
        return fetchResults
    }
    func deleteExistingEvent(managedContext:NSManagedObjectContext,entityName : String?) ->Bool? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName!)
        let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
        do{
            try managedContext.execute(deleteRequest)
            return true
        }catch let error as NSError {
            return false
        }
        
    }
    func showNodata() {
        var errorMessage: String
        errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                        comment: "Setting the content of the alert"))
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoDataView()
        self.loadingView.noDataLabel.text = errorMessage
    }
   
    //MARK: LoadingView Delegate
    func tryAgainButtonPressed() {
        if  (networkReachability?.isReachable)! {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if ((pageNameString == PageName.heritageDetail) && (heritageDetailId != nil)) {
                self.getHeritageDetailsFromServer()
            } else if ((pageNameString == PageName.publicArtsDetail) && (publicArtsDetailId != nil)) {
                self.getPublicArtsDetailsFromServer()
            } else if (pageNameString == PageName.exhibitionDetail) {
                self.getExhibitionDetail()
            } else if (pageNameString == PageName.SideMenuPark) {
                appDelegate?.getParksDataFromServer(lang: LocalizationLanguage.currentAppleLanguage())
            } else if (pageNameString == PageName.NMoQPark) {
                getNMoQParkDetailFromServer()
            } else if (pageNameString == PageName.DiningDetail) {
                self.getDiningDetailsFromServer()
            }
        }
    }
    func showNoNetwork() {
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
    }
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        if (pageNameString == PageName.publicArtsDetail) {
            Analytics.setScreenName(PUBLICARTS_DETAIL, screenClass: screenClass)
        } else if (pageNameString == PageName.exhibitionDetail) {
            Analytics.setScreenName(EXHIBITION_DETAIL, screenClass: screenClass)
        } else if (pageNameString == PageName.SideMenuPark) {
            Analytics.setScreenName(PARKS_VC, screenClass: screenClass)
        } else if (pageNameString == PageName.NMoQPark) {
            Analytics.setScreenName(NMOQ_PARKS_DETAIL, screenClass: screenClass)
        }else if (pageNameString == PageName.DiningDetail) {
            Analytics.setScreenName(DINING_DETAIL, screenClass: screenClass)
        }else {
            Analytics.setScreenName(HERITAGE_DETAIL, screenClass: screenClass)
        }
    }
    @objc func receiveParksNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (parksListArray.count == 0)){
            self.fetchParksFromCoredata()
        } else if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (parksListArray.count == 0)){
            self.fetchParksFromCoredata()
        }
    }
    @objc func receiveParksNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (parksListArray.count == 0)){
            self.fetchParksFromCoredata()
        }
    }
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    func openEmail(email : String) {
        let mailComposeViewController = configuredMailComposeViewController(emailId:email)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    func configuredMailComposeViewController(emailId:String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([emailId])
        mailComposerVC.setSubject("NMOQ Event:")
        mailComposerVC.setMessageBody("Greetings, Thanks for contacting NMOQ event support team", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            print("You pressed OK")
        }
        sendMailErrorAlert.addAction(okAction)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
