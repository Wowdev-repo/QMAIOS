//
//  HomeViewController.swift
//  QatarMuseum
//
//  Created by Exalture on 06/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import CoreData
import UIKit

class HomeViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TopBarProtocol,comingSoonPopUpProtocol,SideMenuProtocol,UIViewControllerTransitioningDelegate {

    @IBOutlet weak var restaurantButton: UIButton!
    @IBOutlet weak var giftShopButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var culturePassButton: UIButton!
    @IBOutlet weak var homeCollectionView: UICollectionView!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var topbarView: TopBarView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!

    var homeDataFullArray : NSArray!
    var effect:UIVisualEffect!
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    var sideView : SideMenuView = SideMenuView()
    var isSideMenuLoaded : Bool = false
    var homeList: [Home]! = []
    var homeEntity: HomeEntity?
    let networkReachability = NetworkReachabilityManager()
    var homeDBArray:[HomeEntity]?
    override func viewDidLoad() {
        super.viewDidLoad()

        registerNib()
        setUpUI()
       
        //if  (networkReachability?.isReachable)! {
            getHomeList()
//        }
//        else {
//            self.fetchHomeInfoFromCoredata()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpUI() {
        topbarView.topbarDelegate = self
        topbarView.backButton.isHidden = true
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.isHidden = true
        loadingView.isHidden = false
        loadingView.showLoading()
    }
    
    func registerNib() {
        let nib = UINib(nibName: "HomeCollectionCell", bundle: nil)
        homeCollectionView?.register(nib, forCellWithReuseIdentifier: "homeCellId")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return homeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell : HomeCollectionViewCell = homeCollectionView.dequeueReusableCell(withReuseIdentifier: "homeCellId", for: indexPath) as! HomeCollectionViewCell
       
            cell.setHomeCellData(home: homeList[indexPath.row])
        loadingView.stopLoading()
        loadingView.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (homeList[indexPath.row].id == "1") {
            loadExhibitionPage()
        } else if(homeList[indexPath.row].id == "63") {
            loadMuseumsPage()
        } else {
            loadComingSoonPopup()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heightValue = UIScreen.main.bounds.height/100
        return CGSize(width: homeCollectionView.frame.width, height: heightValue*27)
    }
    
    func loadMuseumsPage() {
        let museumsView =  self.storyboard?.instantiateViewController(withIdentifier: "museumViewId") as! MuseumsViewController
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(museumsView, animated: false, completion: nil)
    }
    
    func loadExhibitionPage() {
        let exhibitionView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! ExhibitionsViewController
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        //transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        exhibitionView.exhibitionsPageNameString = ExhbitionPageName.homeExhibition
        self.present(exhibitionView, animated: false, completion: nil)
    }
    
    func loadComingSoonPopup() {
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadPopup()
        self.view.addSubview(popupView)
    }
    
    //MARK: Service call
    func getHomeList() {
        _ = Alamofire.request(QatarMuseumRouter.HomeList()).responseObject { (response: DataResponse<HomeList>) -> Void in
            switch response.result {
            case .success(let data):
                self.homeList = data.homeList
                let exhibitionName = NSLocalizedString("EXHIBITIONS_LABEL",
                                                       comment: "EXHIBITIONS_LABEL in exhibition cell")
                self.homeList.insert(Home(id: "1",name: exhibitionName , arabicname: exhibitionName,  image: "exhibition",
                                          tourguide_available: "false", sort_id: nil),
                                     at: self.homeList.endIndex - 1)
               // self.saveOrUpdateHomeCoredata()
                self.homeCollectionView.reloadData()
            case .failure(let error):
                if let unhandledError = handleError(viewController: self, errorType: error as! BackendError) {
                    var errorMessage: String
                    var errorTitle: String
                    switch unhandledError.code {
                    default: print(unhandledError.code)
                    errorTitle = String(format: NSLocalizedString("UNKNOWN_ERROR_ALERT_TITLE",
                                                                  comment: "Setting the title of the alert"))
                    errorMessage = String(format: NSLocalizedString("ERROR_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    }
                    presentAlert(self, title: errorTitle, message: errorMessage)
                }
            }
        }
    }
    
    //MARK: Topbar Delegate
    func backButtonPressed() {
        
    }
    
    func eventButtonPressed() {
        topBarEventButtonPressed()
    }
    
    func notificationbuttonPressed() {
        let notificationsView =  self.storyboard?.instantiateViewController(withIdentifier: "notificationId") as! NotificationsViewController
        notificationsView.fromHome = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(notificationsView, animated: false, completion: nil)
    }
    
    func profileButtonPressed() {
       topBarProfileButtonPressed()
    }
    
    func menuButtonPressed() {
        topbarMenuPressed()
    }
    
    //MARK: Poup Delegate
    func closeButtonPressed() {
        self.popupView.removeFromSuperview()
    }
    
    //MARK: SideMenu Delegates
    func exhibitionButtonPressed() {
        let exhibitionView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! ExhibitionsViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
         exhibitionView.exhibitionsPageNameString = ExhbitionPageName.homeExhibition
        self.present(exhibitionView, animated: false, completion: nil)
    }
    
    func eventbuttonPressed() {
        let eventView =  self.storyboard?.instantiateViewController(withIdentifier: "eventPageID") as! EventViewController
        eventView.fromHome = true
        eventView.isLoadEventPage = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(eventView, animated: false, completion: nil)
    }
    
    func educationButtonPressed() {
        let educationView =  self.storyboard?.instantiateViewController(withIdentifier: "educationPageID") as! EducationViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(educationView, animated: false, completion: nil)
    }
    
    func tourGuideButtonPressed() {
        let tourGuideView =  self.storyboard?.instantiateViewController(withIdentifier: "tourGuidId") as! TourGuideViewController
        //tourGuideView.fromHome = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(tourGuideView, animated: false, completion: nil)
    }
    
    func heritageButtonPressed() {
        let heritageView =  self.storyboard?.instantiateViewController(withIdentifier: "heritageViewId") as! HeritageListViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(heritageView, animated: false, completion: nil)
    }
    
    func publicArtsButtonPressed() {
        let publicArtsView =  self.storyboard?.instantiateViewController(withIdentifier: "publicArtsViewId") as! PublicArtsViewController
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(publicArtsView, animated: false, completion: nil)
    }
    
    func parksButtonPressed() {
        let parksView =  self.storyboard?.instantiateViewController(withIdentifier: "parkViewId") as! ParksViewController
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(parksView, animated: false, completion: nil)
    }
    
    func diningButtonPressed() {
        let diningView =  self.storyboard?.instantiateViewController(withIdentifier: "diningViewId") as! DiningViewController
         diningView.fromHome = true
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(diningView, animated: false, completion: nil)
    }
    
    func giftShopButtonPressed() {
        let aboutUrlString = "https://inq-online.com/?SID=k36n3od6ovtc5jn5hlf8o54g64"
        if let aboutUrl = URL(string: aboutUrlString) {
            // show alert to choose app
            if UIApplication.shared.canOpenURL(aboutUrl as URL) {
                let webViewVc:WebViewController = self.storyboard?.instantiateViewController(withIdentifier: "webViewId") as! WebViewController
                webViewVc.webViewUrl = aboutUrl
                webViewVc.titleString = NSLocalizedString("WEBVIEW_TITLE", comment: "WEBVIEW_TITLE  in the Webview")
                self.present(webViewVc, animated: false, completion: nil)
            }
        }
    }
    
    func settingsButtonPressed() {
        let settingsView =  self.storyboard?.instantiateViewController(withIdentifier: "settingsId") as! SettingsViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(settingsView, animated: false, completion: nil)
    }
    
    func menuEventPressed() {
        topBarEventButtonPressed()
    }
    
    func menuNotificationPressed() {
        let notificationsView =  self.storyboard?.instantiateViewController(withIdentifier: "notificationId") as! NotificationsViewController
        notificationsView.fromHome = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(notificationsView, animated: false, completion: nil)
    }
    
    func menuProfilePressed() {
        topBarProfileButtonPressed()
    }
    
    func menuClosePressed() {
        UIView.animate(withDuration: 0.4, animations: {
            self.sideView.transform = CGAffineTransform.init(scaleX:1 , y: 1)
            self.sideView.alpha = 0
        }) { (success:Bool) in
            self.visualEffectView.effect = nil
            self.visualEffectView.isHidden = true
            self.sideView.removeFromSuperview()
        }
        self.topbarView.menuButton.setImage(UIImage(named: "side_menu_iconX1"), for: .normal)
        self.topbarView.menuButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 18, bottom: 14, right: 18)
        sideView.sideMenuDelegate = self
    }
    
    //MARK: Bottombar Delegate
    @IBAction func didTapMoreButton(_ sender: UIButton) {
        self.moreButton.transform = CGAffineTransform(scaleX: 1, y: 1)
         topbarMenuPressed()
    }
    
    @IBAction func moreButtonTouchDown(_ sender: UIButton) {
        self.moreButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @IBAction func didTaprestaurantButton(_ sender: UIButton) {
        self.culturePassButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        let diningView =  self.storyboard?.instantiateViewController(withIdentifier: "diningViewId") as! DiningViewController
         diningView.fromHome = true
         let transition = CATransition()
         transition.duration = 0.25
         transition.type = kCATransitionPush
         transition.subtype = kCATransitionFromRight
         view.window!.layer.add(transition, forKey: kCATransition)
         self.present(diningView, animated: false, completion: nil)
    }
    
    @IBAction func restaurantButtonTouchDown(_ sender: UIButton) {
        self.restaurantButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @IBAction func didTapCulturePass(_ sender: UIButton) {
        loadComingSoonPopup()
        self.culturePassButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    @IBAction func culturePassTouchDown(_ sender: UIButton) {
        self.culturePassButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @IBAction func didTapGiftShopButton(_ sender: UIButton) {
        giftShopButtonPressed()
        self.giftShopButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    @IBAction func giftShopButtonTouchDown(_ sender: UIButton) {
        self.giftShopButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    func topbarMenuPressed() {
        self.topbarView.menuButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 18)
        var sideViewFrame = CGRect()
        if (UIScreen.main.bounds.height >= 812) {
            sideViewFrame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: self.view.bounds.height)
        } else {
            sideViewFrame = CGRect(x: 0, y: 20, width: self.view.frame.width, height: self.view.bounds.height)
        }
        sideView  = SideMenuView(frame: sideViewFrame)
        self.view.addSubview(sideView)
        
        sideView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        sideView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.visualEffectView.isHidden = false
            self.visualEffectView.effect = self.effect
            self.sideView.alpha = 1
            self.sideView.transform = CGAffineTransform.identity
            self.sideView.topBarView.menuButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 18, bottom: 14, right: 20)
        }
        sideView.sideMenuDelegate = self
    }
    
    func topBarEventButtonPressed() {
        let eventView =  self.storyboard?.instantiateViewController(withIdentifier: "eventPageID") as! EventViewController
        eventView.fromHome = true
        eventView.isLoadEventPage = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(eventView, animated: false, completion: nil)
    }
    
    func topBarProfileButtonPressed() {
        let profileView =  self.storyboard?.instantiateViewController(withIdentifier: "profileViewId") as! ProfileViewController
        profileView.fromHome = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(profileView, animated: false, completion: nil)
        
    }
    //MARK: Coredata Method
    func saveOrUpdateHomeCoredata() {
        let fetchData = checkAddedToCoredata(homeId: nil) as! [HomeEntity]
        if (fetchData.count > 0) {
            for i in 0 ... homeList.count-1 {
                let managedContext = getContext()
                let homeListDict = homeList[i]
                let fetchResult = checkAddedToCoredata(homeId: homeList[i].id)
                //update
                if(fetchResult.count != 0) {
                    let homedbDict = fetchResult[0] as! HomeEntity
                    if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
                        homedbDict.name = homeListDict.name
                    }
                    else {
                        homedbDict.arabicname = homeListDict.name
                    }
                    homedbDict.image = homeListDict.image
                    homedbDict.sortid =  homeListDict.sortId
                    homedbDict.tourguideavailable = homeListDict.isTourguideAvailable
                    do{
                        try managedContext.save()
                    }
                    catch{
                        print(error)
                    }
                }
                else {
                    //save
                    self.saveToCoreData(homeListDict: homeListDict, managedObjContext: managedContext)
                
                }
            }
        }
        else {
        for i in 0 ... homeList.count-1 {
            let managedContext = getContext()
            let homeListDict : Home?
             homeListDict = homeList[i]
            self.saveToCoreData(homeListDict: homeListDict!, managedObjContext: managedContext)

        }
        }
        
    }
    func saveToCoreData(homeListDict: Home, managedObjContext: NSManagedObjectContext) {
        let nameString = homeListDict.name
        
        let idString = homeListDict.id
        let imageString = homeListDict.image
        let sortidString = homeListDict.sortId
        let tourguideVar = homeListDict.isTourguideAvailable
        //var someBoolVariable = numberValue as Bool
        let homeInfo: HomeEntity = NSEntityDescription.insertNewObject(forEntityName: "HomeEntity", into: managedObjContext) as! HomeEntity
        homeInfo.id = idString
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            homeInfo.name = nameString
            
        }
        else{
            
            homeInfo.arabicname = nameString
        }
        homeInfo.image = imageString
        if(sortidString != nil) {
            homeInfo.sortid = sortidString!
        }
        if tourguideVar != nil {
            homeInfo.tourguideavailable = tourguideVar!
            
        }
        do {
            try managedObjContext.save()
            
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func fetchHomeInfoFromCoredata() {
        var homeArray = [HomeEntity]()
        let managedContext = getContext()
        let homeFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "HomeEntity")
        do {
            homeArray = (try managedContext.fetch(homeFetchRequest) as? [HomeEntity])!
            if (homeArray.count > 0) {
                for i in 0 ... homeArray.count-1 {
                    //need to show arabic list only when arabic values stored in db
//                    if ((LocalizationLanguage.currentAppleLanguage()) == "ar") {
//                        if(homeArray[i].arabicname != nil) {
//                            print(homeArray[i].name)
//                            print(homeArray[i].arabicname)
//                            print(homeArray[i].image)
//                            print(homeArray[i].tourguideavailable)
//                            print(homeArray[i].sortid)
//                            self.homeList.insert(Home(id:homeArray[i].id , name: homeArray[i].name, arabicname: homeArray[i].arabicname,image: homeArray[i].image,
//                                                      tourguide_available: homeArray[i].tourguideavailable, sort_id: homeArray[i].sortid),
//                                                 at: i)
//                        }
//                    }
//                        //need to show english list only when arabic values stored in db
//                    else {
                    
                    self.homeList.insert(Home(id:homeArray[i].id, name: homeArray[i].name, arabicname: homeArray[i].arabicname,image: homeArray[i].image,
                                                  tourguide_available: homeArray[i].tourguideavailable, sort_id: homeArray[i].sortid),
                                             at: i)
                    //}
                    
                    
                }
                if(homeList.count == 0){
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                    self.loadingView.noDataLabel.text = errorMessage
                }
                homeCollectionView.reloadData()
            }
            else{
                var errorMessage: String
                errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                comment: "Setting the content of the alert"))
                self.loadingView.stopLoading()
                self.loadingView.noDataView.isHidden = false
                self.loadingView.isHidden = false
                self.loadingView.showNoDataView()
                self.loadingView.noDataLabel.text = errorMessage
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    func getContext() -> NSManagedObjectContext{
        
        let appDelegate =  UIApplication.shared.delegate as? AppDelegate
        if #available(iOS 10.0, *) {
            return
                appDelegate!.persistentContainer.viewContext
        } else {
            return appDelegate!.managedObjectContext
        }
    }
    func checkAddedToCoredata(homeId: String?) -> [NSManagedObject]
    {
        let managedContext = getContext()
        var fetchResults : [NSManagedObject] = []
        let homeFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "HomeEntity")
        if (homeId != nil) {
            homeFetchRequest.predicate = NSPredicate.init(format: "id == \(homeId!)")
        }
        fetchResults = try! managedContext.fetch(homeFetchRequest)
        return fetchResults
    }
}
