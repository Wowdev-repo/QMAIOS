//
//  FloorMapViewController.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 15/08/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//


import AVFoundation
import AVKit
import Crashlytics

import Firebase
import GoogleMaps
import Kingfisher
import UIKit


enum levelNumber{
    case one
    case two
    case three
}
enum fromTour{
    case exploreTour
    case scienceTour
    case HighlightTour
}

class FloorMapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var viewForMap: GMSMapView!
    @IBOutlet weak var headerView: CommonHeaderView!
    @IBOutlet weak var thirdLevelView: UIView!
    @IBOutlet weak var secondLevelView: UIView!
    @IBOutlet weak var firstLevelView: UIView!
    @IBOutlet weak var thirdLevelButton: UIButton!
    @IBOutlet weak var secondLevelButton: UIButton!
    @IBOutlet weak var firstLevelButton: UIButton!
    @IBOutlet weak var secondLevelLabel: UILabel!
    @IBOutlet weak var numberTwo: UILabel!
    @IBOutlet weak var numberOne: UILabel!
    
    @IBOutlet weak var numberThree: UILabel!
    @IBOutlet weak var firstLevelLabel: UILabel!
    @IBOutlet weak var thirdLevelLabel: UILabel!
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var numberSerchBtn: UIButton!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playerSlider: UISlider!
    
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var seekLoadingLabel: UILabel!
    var bottomSheetVC:MapDetailView = MapDetailView()
    var floorMapArray: [TourGuideFloorMap]! = []
    //var tourGuideArray: [TourGuideFloorMap]! = []
    var selectedScienceTour : String? = ""
    var selectedScienceTourLevel : String? = ""
    var selectedTourdGuidIndex : Int? = 0
    var selectednid : String? = ""
    var selectedMarker = GMSMarker()
    var selectedMarkerImage = UIImage()
    var bounceTimerTwo = Timer()
    var bounceTimerThree = Timer()
    var playList: String = ""
    var timer: Timer?
    var avPlayer: AVPlayer!
    var isPaused: Bool!
    var firstLoad: Bool = true
    var levelTwoPositionArray = NSArray()
    var levelTwoMarkerArray = NSArray()
    var levelThreePositionArray = NSArray()
    var levelThreeMarkerArray = NSArray()
    var loadedLevelTwoMarkerArray = NSMutableArray()
    var loadedLevelThreeMarkerArray = NSMutableArray()
    var tourGuideId : String? = ""
    let networkReachability = NetworkReachabilityManager()
   // var selectedImageFromPreview = UIImage()
    var overlay = GMSGroundOverlay()
    let L2_G1_SC3 = CLLocationCoordinate2D(latitude: 25.295141, longitude: 51.539185)
    let L2_G8 = CLLocationCoordinate2D(latitude: 25.295500, longitude: 51.538855)
    let L2_G8_SC1 = CLLocationCoordinate2D(latitude: 25.295468, longitude: 51.538905)
    let L2_G8_SC6_1 = CLLocationCoordinate2D(latitude: 25.295510, longitude: 51.538803)
    let L2_G8_SC6_2 = CLLocationCoordinate2D(latitude: 25.295450, longitude: 51.538830)
    let L2_G8_SC5 = CLLocationCoordinate2D(latitude: 25.295540, longitude: 51.538835)
    let L2_G8_SC4_1 = CLLocationCoordinate2D(latitude: 25.295571, longitude: 51.538840)
    let L2_G8_SC4_2 = CLLocationCoordinate2D(latitude: 25.295558, longitude: 51.538841)
    let L2_G9_SC7 = CLLocationCoordinate2D(latitude: 25.295643, longitude: 51.538895)
    let L2_G9_SC5_1 = CLLocationCoordinate2D(latitude: 25.295654, longitude: 51.538918)
    let L2_G9_SC5_2 = CLLocationCoordinate2D(latitude: 25.295652, longitude: 51.538927)
    let L2_G5_SC6 = CLLocationCoordinate2D(latitude: 25.295686, longitude: 51.539265)
   // let L2_G3_SC14 = CLLocationCoordinate2D(latitude: 25.295566, longitude: 51.539397)
    let L2_G3_SC13 = CLLocationCoordinate2D(latitude: 25.295566, longitude: 51.539429)
    
    let L3_G10_SC1_1 = CLLocationCoordinate2D(latitude: 25.295230, longitude: 51.539170)
    let L3_G10_SC1_2 = CLLocationCoordinate2D(latitude: 25.295245, longitude: 51.539210)
    let L3_G11_WR15 = CLLocationCoordinate2D(latitude: 25.295330, longitude: 51.539414)
    let L3_G13_5 = CLLocationCoordinate2D(latitude: 25.295664, longitude: 51.539330)
    let L3_G13_7 = CLLocationCoordinate2D(latitude: 25.295628, longitude: 51.539360)
    let L3_G17_3 = CLLocationCoordinate2D(latitude: 25.295505, longitude: 51.538905)
    
    
    // Highlight Tour
    let L2_G1_SC2 = CLLocationCoordinate2D(latitude: 25.295195, longitude: 51.539160);
    let L2_G1_SC7 = CLLocationCoordinate2D(latitude: 25.295215, longitude: 51.539395);
    let L2_G1_SC8 = CLLocationCoordinate2D(latitude: 25.295268, longitude: 51.539373);
    let L2_G1_SC13 = CLLocationCoordinate2D(latitude: 25.295180, longitude: 51.539248);
    let L2_G1_SC14 = CLLocationCoordinate2D(latitude: 25.295205, longitude: 51.539319);
    let L2_G2_2 = CLLocationCoordinate2D(latitude: 25.295220, longitude: 51.539450);
    let L2_G3_SC14_1 = CLLocationCoordinate2D(latitude: 25.295548, longitude: 51.539406);
    let L2_G3_SC14_2 = CLLocationCoordinate2D(latitude: 25.295580, longitude: 51.539392);
    let L2_G3_WR4 = CLLocationCoordinate2D(latitude: 25.295540, longitude: 51.539470);
    let L2_G4_SC5 = CLLocationCoordinate2D(latitude: 25.295690, longitude: 51.539312);
    let L2_G3_SC3 = CLLocationCoordinate2D(latitude: 25.295715, longitude: 51.539348);
    let L2_G5_SC5 = CLLocationCoordinate2D(latitude: 25.295715, longitude: 51.539205);
    let L2_G5_SC11 = CLLocationCoordinate2D(latitude: 25.295735, longitude: 51.539225);
    let L2_G7_SC13 = CLLocationCoordinate2D(latitude: 25.295395, longitude: 51.538915);
    let L2_G7_SC8 = CLLocationCoordinate2D(latitude: 25.295345, longitude: 51.538880);
    let L2_G7_SC4 = CLLocationCoordinate2D(latitude: 25.295450, longitude: 51.538908);
    
    let L3_G10_WR2_1 = CLLocationCoordinate2D(latitude: 25.295130, longitude: 51.539217);
    let L3_G10_WR2_2 = CLLocationCoordinate2D(latitude: 25.295138, longitude: 51.539240);
    let L3_G10_PODIUM14 = CLLocationCoordinate2D(latitude: 25.295188, longitude: 51.539240);
    let L3_G10_PODIUM9 = CLLocationCoordinate2D(latitude: 25.295222, longitude: 51.539333);
    let L3_G11_14 = CLLocationCoordinate2D(latitude: 25.295392, longitude: 51.539495);
    let L3_G12_11 = CLLocationCoordinate2D(latitude: 25.295530, longitude: 51.539390);
    let L3_G12_12 = CLLocationCoordinate2D(latitude: 25.295492, longitude: 51.539405);
    let L3_G12_17 = CLLocationCoordinate2D(latitude: 25.295480, longitude: 51.539440);
    let L3_G12_WR5 = CLLocationCoordinate2D(latitude: 25.295540, longitude: 51.539470);
    let L3_G13_2 = CLLocationCoordinate2D(latitude: 25.295690, longitude: 51.539402);
    let L3_G13_15 = CLLocationCoordinate2D(latitude: 25.295660, longitude: 51.539375);
    let L3_G14_7 = CLLocationCoordinate2D(latitude: 25.295693, longitude: 51.539270);
    let L3_G14_13 = CLLocationCoordinate2D(latitude: 25.295723, longitude: 51.539225);
    let L3_G15_13 = CLLocationCoordinate2D(latitude: 25.295150, longitude: 51.539135);
    let L3_G16_WR5 = CLLocationCoordinate2D(latitude: 25.295444, longitude: 51.538955);
    let L3_G17_8 = CLLocationCoordinate2D(latitude: 25.295504, longitude: 51.538880);
    let L3_G17_9 = CLLocationCoordinate2D(latitude: 25.295490, longitude: 51.538850);
    let L3_G18_1 = CLLocationCoordinate2D(latitude: 25.295555, longitude: 51.538892);
    let L3_G18_2 = CLLocationCoordinate2D(latitude: 25.295557, longitude: 51.538906);
    let L3_G18_11 = CLLocationCoordinate2D(latitude: 25.295613, longitude: 51.538914);
    
    let l2_g1_sc3 = GMSMarker()
    let l2_g8 = GMSMarker()
    let l2_g8_sc1 = GMSMarker()
    let l2_g8_sc6_1 = GMSMarker()
    let l2_g8_sc6_2 = GMSMarker()
    let l2_g8_sc5 = GMSMarker()
    let l2_g8_sc4_1 = GMSMarker()
    let l2_g8_sc4_2 = GMSMarker()
    let l2_g9_sc7 = GMSMarker()
    let l2_g9_sc5_1 = GMSMarker()
    let l2_g9_sc5_2 = GMSMarker()
    let l2_g5_sc6 = GMSMarker()
    let l2_g3_sc13 = GMSMarker()
    let l3_g10_sc1_1 = GMSMarker()
    let l3_g10_sc1_2 = GMSMarker()
    let l3_g11_wr15 = GMSMarker()
    let l3_g13_5 = GMSMarker()
    let l3_g13_7 = GMSMarker()
    let l3_g17_3 = GMSMarker()
    
    //Highligh Marker
    let l2_g1_sc2 = GMSMarker()
    let l2_g1_sc7 = GMSMarker()
    let l2_g1_sc8 = GMSMarker()
    let l2_g1_sc13 = GMSMarker()
    let l2_g1_sc14 = GMSMarker()
    let l2_g2_2 = GMSMarker()
    let l2_g3_sc14_1 = GMSMarker()
    let l2_g3_sc14_2 = GMSMarker()
    let l2_g3_wr4 = GMSMarker()
    let l2_g4_sc5 = GMSMarker()
    let l2_g3_sc3 = GMSMarker()
    let l2_g5_sc5 = GMSMarker()
    let l2_g5_sc11 = GMSMarker()
    let l2_g7_sc13 = GMSMarker()
    let l2_g7_sc8 = GMSMarker()
    let l2_g7_sc4 = GMSMarker()
    //Already added
    /*
    let l2_g8_sc1 = GMSMarker()
    let l2_g8_sc5 = GMSMarker()
    let l2_g9_sc7 = GMSMarker()
    let l2_g1_sc3 = GMSMarker()
    */
    
    let l3_g10_wr2_1 = GMSMarker()
    let l3_g10_wr2_2 = GMSMarker()
    let l3_g10_podium14 = GMSMarker()
    let l3_g10_podium9 = GMSMarker()
    let l3_g11_14 = GMSMarker()
    let l3_g12_11 = GMSMarker()
    let l3_g12_12 = GMSMarker()
    let l3_g12_17 = GMSMarker()
    let l3_g12_wr5 = GMSMarker()
    let l3_g13_2 = GMSMarker()
    let l3_g13_15 = GMSMarker()
    let l3_g14_7 = GMSMarker()
    let l3_g14_13 = GMSMarker()
    let l3_g15_13 = GMSMarker()
    let l3_g16_wr5 = GMSMarker()
    let l3_g17_8 = GMSMarker()
    let l3_g17_9 = GMSMarker()
    let l3_g18_1 = GMSMarker()
    let l3_g18_2 = GMSMarker()
    let l3_g18_11 = GMSMarker()
    
    
    var level : levelNumber?
    var zoomValue = Float()
    var fromTourString : fromTour?
    let playLists = ["http://www.qm.org.qa/sites/default/files/floors.mp3",
                    "http://www.qm.org.qa/sites/default/files/floor2.mp3",
                    "http://www.qm.org.qa/sites/default/files/floor3.mp3"]
    
    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()
        
        viewForMap.delegate = self
        loadMap()
        initialSetUp()
        self.recordScreenView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        bottomSheetVC.removeFromParentViewController()
        bottomSheetVC.dismiss(animated: false, completion: nil)
        isPaused = true
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        

    }
    func initialSetUp() {
        loadingView.isHidden = false
        self.loadingView.showLoading()
        self.loadingView.loadingViewDelegate = self
        overlayView.isHidden = true
        bottomSheetVC.mapdetailDelegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tap.delegate = self // This is not required
        overlayView.addGestureRecognizer(tap)
        levelView.layer.shadowColor = UIColor.black.cgColor
        levelView.layer.shadowOpacity = 0.6
        levelView.layer.shadowOffset = CGSize.zero
        levelView.layer.shadowRadius = 10
        
        firstLevelView.layer.shadowColor = UIColor.black.cgColor
        firstLevelView.layer.shadowOpacity = 0.5
        firstLevelView.layer.shadowOffset = CGSize.zero
        firstLevelView.layer.shadowRadius = 1
        
        secondLevelView.layer.shadowColor = UIColor.black.cgColor
        secondLevelView.layer.shadowOpacity = 0.5
        secondLevelView.layer.shadowOffset = CGSize.zero
        secondLevelView.layer.shadowRadius = 1
        
        thirdLevelView.layer.shadowColor = UIColor.black.cgColor
        thirdLevelView.layer.shadowOpacity = 0.5
        thirdLevelView.layer.shadowOffset = CGSize.zero
        thirdLevelView.layer.shadowRadius = 1
        if (fromTourString == fromTour.scienceTour) {
            
            if (selectedScienceTourLevel == "1"){
                self.playList = self.playLists[0]
                playButton.isHidden = false
                playerSlider.isHidden = false
            }
            if(selectedScienceTourLevel == "2") {
                firstLevelView.backgroundColor = UIColor.mapLevelColor
                secondLevelView.backgroundColor = UIColor.white
                thirdLevelView.backgroundColor = UIColor.mapLevelColor
                self.playList = self.playLists[1]
                playButton.isHidden = false
                playerSlider.isHidden = false
            } else {
                firstLevelView.backgroundColor = UIColor.mapLevelColor
                secondLevelView.backgroundColor = UIColor.mapLevelColor
                thirdLevelView.backgroundColor = UIColor.white
                self.playList = self.playLists[2]
                playButton.isHidden = false
                playerSlider.isHidden = false
            }
            playButton.setImage(UIImage(named:"play_blackX1"), for: .normal)
            headerView.headerBackButton.isHidden = false
            headerView.settingsButton.isHidden = true
            
            levelTwoPositionArray = ["l2_g1_sc3","l2_g8","l2_g8_sc1","l2_g8_sc6_1","l2_g8_sc6_2","l2_g8_sc5","l2_g8_sc4_1","l2_g8_sc4_2","l2_g9_sc7","l2_g9_sc5_1","l2_g9_sc5_2","l2_g5_sc6","l2_g3_sc13"]
            levelTwoMarkerArray = [l2_g1_sc3,l2_g8,l2_g8_sc1,l2_g8_sc6_1,l2_g8_sc6_2,l2_g8_sc5,l2_g8_sc4_1,l2_g8_sc4_2,l2_g9_sc7,l2_g9_sc5_1,l2_g9_sc5_2,l2_g5_sc6,l2_g3_sc13]
            levelThreePositionArray = ["l3_g10_sc1_1","l3_g10_sc1_2","l3_g11_wr15","l3_g13_5","l3_g13_7","l3_g17_3"]
            levelThreeMarkerArray = [l3_g10_sc1_1,l3_g10_sc1_2,l3_g11_wr15,l3_g13_5,l3_g13_7,l3_g17_3]
            showLevelTwoMarker()
            showLevelThreeMarker()
            
        } else {
         if (fromTourString == fromTour.HighlightTour) {
            
            if (selectedScienceTourLevel == "1"){
                playButton.isHidden = false
                playerSlider.isHidden = false
                self.playList = self.playLists[0]

                firstLevelView.backgroundColor = UIColor.white
                secondLevelView.backgroundColor = UIColor.mapLevelColor
                thirdLevelView.backgroundColor = UIColor.mapLevelColor
            }
            if(selectedScienceTourLevel == "2") {
                firstLevelView.backgroundColor = UIColor.mapLevelColor
                secondLevelView.backgroundColor = UIColor.white
                thirdLevelView.backgroundColor = UIColor.mapLevelColor
                self.playList = self.playLists[1]

                playButton.isHidden = false
                playerSlider.isHidden = false
            } else {
                firstLevelView.backgroundColor = UIColor.mapLevelColor
                secondLevelView.backgroundColor = UIColor.mapLevelColor
                thirdLevelView.backgroundColor = UIColor.white
                self.playList = self.playLists[2]

                playButton.isHidden = false
                playerSlider.isHidden = false
            }
            
            headerView.headerBackButton.isHidden = false
            headerView.settingsButton.isHidden = true
            
        } else {
            firstLevelView.backgroundColor = UIColor.white
            secondLevelView.backgroundColor = UIColor.mapLevelColor
            thirdLevelView.backgroundColor = UIColor.mapLevelColor
            headerView.headerBackButton.isHidden = false
            playButton.isHidden = false
            playerSlider.isHidden = false
            self.playList = self.playLists[0]
        }
            playButton.setImage(UIImage(named:"play_blackX1"), for: .normal)

            
            levelTwoPositionArray = ["l2_g1_sc2","l2_g1_sc7","l2_g1_sc8","l2_g1_sc13","l2_g1_sc14","l2_g2_2","l2_g3_sc14_1","l2_g3_sc14_2","l2_g3_wr4","l2_g4_sc5","l2_g3_sc3","l2_g5_sc5","l2_g5_sc11","l2_g7_sc13","l2_g7_sc8","l2_g7_sc4","l2_g1_sc3","l2_g8_sc1","l2_g8_sc5","l2_g9_sc7"]
            levelTwoMarkerArray = [l2_g1_sc2,l2_g1_sc7,l2_g1_sc8,l2_g1_sc13,l2_g1_sc14,l2_g2_2,l2_g3_sc14_1,l2_g3_sc14_2,l2_g3_wr4,l2_g4_sc5,l2_g3_sc3,l2_g5_sc5,l2_g5_sc11,l2_g7_sc13,l2_g7_sc8,l2_g7_sc4,l2_g1_sc3,l2_g8_sc1,l2_g8_sc5,l2_g9_sc7]
            levelThreePositionArray = ["l3_g10_wr2_1","l3_g10_wr2_2","l3_g10_podium14","l3_g10_podium9","l3_g11_14","l3_g12_11","l3_g12_12","l3_g12_17","l3_g12_wr5","l3_g13_2","l3_g13_15","l3_g14_7","l3_g14_13","l3_g15_13","l3_g16_wr5","l3_g17_8","l3_g17_9","l3_g18_1","l3_g18_2","l3_g18_11"]
            levelThreeMarkerArray = [l3_g10_wr2_1,l3_g10_wr2_2,l3_g10_podium14,l3_g10_podium9,l3_g11_14,l3_g12_11,l3_g12_12,l3_g12_17,l3_g12_wr5,l3_g13_2,l3_g13_15,l3_g14_7,l3_g14_13,l3_g15_13,l3_g16_wr5,l3_g17_8,l3_g17_9,l3_g18_1,l3_g18_2,l3_g18_11]
            showLevelTwoHighlightMarker()
            showLevelThreeHighlightMarker()
        }
       
        numberSerchBtn.isHidden = false
        numberSerchBtn.setImage(UIImage(named: "number_padX1"), for: .normal)
        thirdLevelLabel.text = NSLocalizedString("LEVEL_STRING", comment: "LEVEL_STRING in floor map")
        secondLevelLabel.text = NSLocalizedString("LEVEL_STRING", comment: "LEVEL_STRING in floor map")
        firstLevelLabel.text = NSLocalizedString("LEVEL_STRING", comment: "LEVEL_STRING in floor map")
        headerView.headerViewDelegate = self
        headerView.headerTitle.text = NSLocalizedString("FLOOR_MAP_TITLE", comment: "FLOOR_MAP_TITLE  in the Floormap page")
        
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
             headerView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
            if (fromTourString == fromTour.scienceTour) {
                tourGuideId = "12216"
            } else if (fromTourString == fromTour.exploreTour){
                tourGuideId = "12471"
//                DispatchQueue.global(qos: .background).async {
//                    self.getFloorMapDataFromServer()
//                }
            } else if (fromTourString == fromTour.HighlightTour) {
                tourGuideId = "12471"
            }
        } else {
            headerView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
            self.playerSlider.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            if (fromTourString == fromTour.scienceTour) {
                tourGuideId = "12226"
            } else if (fromTourString == fromTour.exploreTour){
                tourGuideId = "12916"
//                DispatchQueue.global(qos: .background).async {
//                    self.getFloorMapDataFromServer()
//                }
            } else if (fromTourString == fromTour.HighlightTour) {
                tourGuideId = "12916"
            }
        }
       // DispatchQueue.main.async {
           // self.fetchTourGuideFromCoredata()
        //}
        
        if  (networkReachability?.isReachable)! {
            getFloorMapDataFromServer()
        } else {
            fetchTourGuideFromCoredata()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(FloorMapViewController.receiveFloormapNotification(notification:)), name: NSNotification.Name(floormapNotification), object: nil)
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func loadMap() {
        var camera = GMSCameraPosition()
        //Device Condition check for moving map to center of device screen
        if (UIScreen.main.bounds.height > 700) {
            camera = GMSCameraPosition.camera(withLatitude: 25.295447, longitude: 51.539195, zoom:19)
        }
        else {
            camera = GMSCameraPosition.camera(withLatitude: 25.296059, longitude: 51.538703, zoom:19)
        }
        viewForMap.animate(to: camera)
        do {
            if let styleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") {
                viewForMap.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        viewForMap.mapType = .normal
        var icon = UIImage()
        if (fromTourString == fromTour.scienceTour) {
            if(selectedScienceTourLevel == "3") {
                level = levelNumber.three
                icon = UIImage(named: "qm_level_3")!
                //viewForMap.animate(toZoom: 19.5)
            } else {
                level = levelNumber.two
                icon = UIImage(named: "qm_level_2")!
               // viewForMap.animate(toZoom: 19.5)
            }
            
        } else if (fromTourString == fromTour.HighlightTour) {
            if(selectedScienceTourLevel == "3") {
                level = levelNumber.three
                icon = UIImage(named: "qm_level_3")!
                //viewForMap.animate(toZoom: 19.5)
            } else {
                level = levelNumber.two
                icon = UIImage(named: "qm_level_2")!
                //viewForMap.animate(toZoom: 19.5)
            }
            
        } else {
            level = levelNumber.one
            icon = UIImage(named: "qm_level_1")!
        }
        let southWest = CLLocationCoordinate2D(latitude: 25.294730, longitude: 51.539021)
        let northEast = CLLocationCoordinate2D(latitude: 25.295685, longitude: 51.539945)
        let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
        overlay = GMSGroundOverlay.init(bounds: overlayBounds, icon: icon)
        //let camera2 = GMSCameraPosition.camera(withLatitude: 25.295447, longitude: 51.539195, zoom:19)
        overlay.anchor = CGPoint(x: 0, y: 1)
        overlay.map = self.viewForMap
        viewForMap?.camera = camera
        
        overlay.bearing = -22
        viewForMap.setMinZoom(19, maxZoom: 28)
        
        //let circleCenter = CLLocationCoordinate2DMake(25.294730,51.539021)
        let circleCenter = CLLocationCoordinate2DMake(25.296059,51.538703)
        let circ = GMSCircle(position: circleCenter, radius: 250)
        
        circ.strokeColor = UIColor.clear
        circ.map = viewForMap
        
        if ((fromTourString == fromTour.scienceTour) || (fromTourString == fromTour.HighlightTour)){
            if (UIScreen.main.bounds.height > 700) {
                camera = GMSCameraPosition.camera(withLatitude: 25.295447, longitude: 51.539195, zoom:19)
            }
            else {
                camera = GMSCameraPosition.camera(withLatitude: 25.295980, longitude: 51.538779, zoom:19)
            }
            
            viewForMap.animate(to: camera)
           // viewForMap.animate(toZoom: 19.3)
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), TourType: \(String(describing: fromTourString))")
        
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_floormap_loadmap,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    //Function for show level 2 marker
    func showLevelTwoMarker() {
            l2_g1_sc3.position = L2_G1_SC3
            l2_g1_sc3.title = "l2_g1_sc3"
            l2_g1_sc3.snippet = ""
            l2_g1_sc3.appearAnimation = .pop
            
            l2_g8.position = L2_G8
            l2_g8.title = "l2_g8"
            l2_g8.snippet = ""
            l2_g8.appearAnimation = .pop
            
            l2_g8_sc1.position = L2_G8_SC1
            l2_g8_sc1.title = "l2_g8_sc1"
            l2_g8_sc1.snippet = ""
            l2_g8_sc1.appearAnimation = .pop
            
            l2_g8_sc6_1.position = L2_G8_SC6_1
            l2_g8_sc6_1.title = "l2_g8_sc6_1"
            l2_g8_sc6_1.snippet = ""
            l2_g8_sc6_1.appearAnimation = .pop
            
            l2_g8_sc6_2.position = L2_G8_SC6_2
            l2_g8_sc6_2.title = "l2_g8_sc6_2"
            l2_g8_sc6_2.snippet = ""
            l2_g8_sc6_2.appearAnimation = .pop
            
            l2_g8_sc5.position = L2_G8_SC5
            l2_g8_sc5.title = "l2_g8_sc5"
            l2_g8_sc5.snippet = ""
            l2_g8_sc5.appearAnimation = .pop
            
            l2_g8_sc4_1.position = L2_G8_SC4_1
            l2_g8_sc4_1.title = "l2_g8_sc4_1"
            l2_g8_sc4_1.snippet = ""
            l2_g8_sc4_1.appearAnimation = .pop
            
            l2_g8_sc4_2.position = L2_G8_SC4_2
            l2_g8_sc4_2.title = "l2_g8_sc4_2"
            l2_g8_sc4_2.snippet = ""
            l2_g8_sc4_2.appearAnimation = .pop
            
            l2_g9_sc7.position = L2_G9_SC7
            l2_g9_sc7.title = "l2_g9_sc7"
            l2_g9_sc7.snippet = ""
            l2_g9_sc7.appearAnimation = .pop
            
            l2_g9_sc5_1.position = L2_G9_SC5_1
            l2_g9_sc5_1.title = "l2_g9_sc5_1"
            l2_g9_sc5_1.snippet = ""
            l2_g9_sc5_1.appearAnimation = .pop
            
            l2_g9_sc5_2.position = L2_G9_SC5_2
            l2_g9_sc5_2.title = "l2_g9_sc5_2"
            l2_g9_sc5_2.snippet = ""
            l2_g9_sc5_2.appearAnimation = .pop
            
            l2_g5_sc6.position = L2_G5_SC6
            l2_g5_sc6.title = "l2_g5_sc6"
            l2_g5_sc6.snippet = ""
            l2_g5_sc6.appearAnimation = .pop
            
            l2_g3_sc13.position = L2_G3_SC13
            l2_g3_sc13.title = "l2_g3_sc13"
            l2_g3_sc13.snippet = ""
            l2_g3_sc13.appearAnimation = .pop
        
        
         DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    //Function for show level 3 marker
    func showLevelThreeMarker() {
            l3_g10_sc1_1.position = L3_G10_SC1_1
            l3_g10_sc1_1.title = "l3_g10_sc1_1"
            l3_g10_sc1_1.snippet = "PO.297"
            l3_g10_sc1_1.appearAnimation = .pop
            
            l3_g10_sc1_2.position = L3_G10_SC1_2
            l3_g10_sc1_2.title = "l3_g10_sc1_2"
            l3_g10_sc1_2.snippet = ""
            l3_g10_sc1_2.appearAnimation = .pop
            
            l3_g11_wr15.position = L3_G11_WR15
            l3_g11_wr15.title = "l3_g11_wr15"
            l3_g11_wr15.snippet = ""
            l3_g11_wr15.appearAnimation = .pop
            
            l3_g13_5.position = L3_G13_5
            l3_g13_5.title = "l3_g13_5"
            l3_g13_5.snippet = ""
            l3_g13_5.appearAnimation = .pop
            
            l3_g13_7.position = L3_G13_7
            l3_g13_7.title = "l3_g13_7"
            l3_g13_7.snippet = ""
            l3_g13_7.appearAnimation = .pop
            
            l3_g17_3.position = L3_G17_3
            l3_g17_3.title = "l3_g17_3"
            l3_g17_3.snippet = ""
            l3_g17_3.appearAnimation = .pop
        
         DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    //MARK: Highlight Marker
    func showLevelTwoHighlightMarker() {
        
        l2_g1_sc2.position = L2_G1_SC2
        l2_g1_sc2.title = "l2_g1_sc2"
        l2_g1_sc2.appearAnimation = .pop
        
        l2_g1_sc7.position = L2_G1_SC7
        l2_g1_sc7.title = "l2_g1_sc7"
        l2_g1_sc7.appearAnimation = .pop
        
        l2_g1_sc8.position = L2_G1_SC8
        l2_g1_sc8.title = "l2_g1_sc8"
        l2_g1_sc8.appearAnimation = .pop
        
        l2_g1_sc13.position = L2_G1_SC13
        l2_g1_sc13.title = "l2_g1_sc13"
        l2_g1_sc13.appearAnimation = .pop
        
        l2_g1_sc14.position = L2_G1_SC14
        l2_g1_sc14.title = "l2_g1_sc14"
        l2_g1_sc14.appearAnimation = .pop
        
        l2_g2_2.position = L2_G2_2
        l2_g2_2.title = "l2_g2_2"
        l2_g2_2.appearAnimation = .pop
        
        l2_g3_sc14_1.position = L2_G3_SC14_1
        l2_g3_sc14_1.title = "l2_g3_sc14_1"
        l2_g3_sc14_1.appearAnimation = .pop
        
        l2_g3_sc14_2.position = L2_G3_SC14_2
        l2_g3_sc14_2.title = "l2_g3_sc14_2"
        l2_g3_sc14_2.appearAnimation = .pop
        
        l2_g3_wr4.position = L2_G3_WR4
        l2_g3_wr4.title = "l2_g3_wr4"
        l2_g3_wr4.appearAnimation = .pop
        
        l2_g4_sc5.position = L2_G4_SC5
        l2_g4_sc5.title = "l2_g4_sc5"
        l2_g4_sc5.appearAnimation = .pop
        
        l2_g3_sc3.position = L2_G3_SC3
        l2_g3_sc3.title = "l2_g3_sc3"
        l2_g3_sc3.appearAnimation = .pop
        
        l2_g5_sc5.position = L2_G5_SC5
        l2_g5_sc5.title = "l2_g5_sc5"
        l2_g5_sc5.appearAnimation = .pop
        
        l2_g5_sc11.position = L2_G5_SC11
        l2_g5_sc11.title = "l2_g5_sc11"
        l2_g5_sc11.appearAnimation = .pop
        
        l2_g7_sc13.position = L2_G7_SC13
        l2_g7_sc13.title = "l2_g7_sc13"
        l2_g7_sc13.appearAnimation = .pop
        
        l2_g7_sc8.position = L2_G7_SC8
        l2_g7_sc8.title = "l2_g7_sc8"
        l2_g7_sc8.appearAnimation = .pop
        
        l2_g7_sc4.position = L2_G7_SC4
        l2_g7_sc4.title = "l2_g7_sc4"
        l2_g7_sc4.appearAnimation = .pop
        
        l2_g8_sc1.position = L2_G8_SC1
        l2_g8_sc1.title = "l2_g8_sc1"
        l2_g8_sc1.appearAnimation = .pop
        
        l2_g8_sc5.position = L2_G8_SC5
        l2_g8_sc5.title = "l2_g8_sc5"
        l2_g8_sc5.appearAnimation = .pop
        
        l2_g9_sc7.position = L2_G9_SC7
        l2_g9_sc7.title = "l2_g9_sc7"
        l2_g9_sc7.appearAnimation = .pop
        
        l2_g1_sc3.position = L2_G1_SC3
        l2_g1_sc3.title = "l2_g1_sc3"
        l2_g1_sc3.appearAnimation = .pop
       
         DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    func showLevelThreeHighlightMarker() {
        
        l3_g10_wr2_1.position = L3_G10_WR2_1
        l3_g10_wr2_1.title = "l3_g10_wr2_1"
        l3_g10_wr2_1.appearAnimation = .pop
        
        
        l3_g10_wr2_2.position = L3_G10_WR2_2
        l3_g10_wr2_2.title = "l3_g10_wr2_2"
        l3_g10_wr2_2.appearAnimation = .pop
        
        l3_g10_podium14.position = L3_G10_PODIUM14
        l3_g10_podium14.title = "l3_g10_podium14"
        l3_g10_podium14.appearAnimation = .pop
        
        l3_g10_podium9.position = L3_G10_PODIUM9
        l3_g10_podium9.title = "l3_g10_podium9"
        l3_g10_podium9.appearAnimation = .pop
        
        l3_g11_14.position = L3_G11_14
        l3_g11_14.title = "l3_g11_14"
        l3_g11_14.appearAnimation = .pop
        
        l3_g12_11.position = L3_G12_11
        l3_g12_11.title = "l3_g12_11"
        l3_g12_11.appearAnimation = .pop
        
        l3_g12_12.position = L3_G12_12
        l3_g12_12.title = "l3_g12_12"
        l3_g12_12.appearAnimation = .pop
        
        l3_g12_17.position = L3_G12_17
        l3_g12_17.title = "l3_g12_17"
        l3_g12_17.appearAnimation = .pop
        
        l3_g12_wr5.position = L3_G12_WR5
        l3_g12_wr5.title = "l3_g12_wr5"
        l3_g12_wr5.appearAnimation = .pop
        
        l3_g13_2.position = L3_G13_2
        l3_g13_2.title = "l3_g13_2"
        l3_g13_2.appearAnimation = .pop
        
        l3_g13_15.position = L3_G13_15
        l3_g13_15.title = "l3_g13_15"
        l3_g13_15.appearAnimation = .pop
        
        l3_g14_7.position = L3_G14_7
        l3_g14_7.title = "l3_g14_7"
        l3_g14_7.appearAnimation = .pop
        
        l3_g14_13.position = L3_G14_13
        l3_g14_13.title = "l3_g14_13"
        l3_g14_13.appearAnimation = .pop
        
        l3_g15_13.position = L3_G15_13
        l3_g15_13.title = "l3_g15_13"
        l3_g15_13.appearAnimation = .pop
        
        l3_g16_wr5.position = L3_G16_WR5
        l3_g16_wr5.title = "l3_g16_wr5"
        l3_g16_wr5.appearAnimation = .pop
        
        l3_g17_8.position = L3_G17_8
        l3_g17_8.title = "l3_g17_8"
        l3_g17_8.appearAnimation = .pop
        
        l3_g17_9.position = L3_G17_9
        l3_g17_9.title = "l3_g17_9"
        l3_g17_9.appearAnimation = .pop
        
        l3_g18_1.position = L3_G18_1
        l3_g18_1.title = "l3_g18_1"
        l3_g18_1.appearAnimation = .pop
        
        l3_g18_2.position = L3_G18_2
        l3_g18_2.title = "l3_g18_2"
        l3_g18_2.appearAnimation = .pop
        
        l3_g18_11.position = L3_G18_11
        l3_g18_11.title = "l3_g18_11"
        l3_g18_11.appearAnimation = .pop
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        return newImage
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: Floor Levels
    @IBAction func didTapThirdLevel(_ sender: UIButton) {
        if(level != levelNumber.three) {
            self.closeAudio()
            //self.loadingView.isHidden = false
            //self.loadingView.showLoading()
            //self.stopLoadingView(delayInSeconds: 0.3)
            self.playList = self.playLists[2]
            playButton.isHidden = false
            playerSlider.isHidden = false
            level = levelNumber.three
            firstLevelView.backgroundColor = UIColor.mapLevelColor
            secondLevelView.backgroundColor = UIColor.mapLevelColor
            thirdLevelView.backgroundColor = UIColor.white
            overlay.icon = UIImage(named: "qm_level_3")
            removeMarkers()
            
            //if (zoomValue > 18) {
                
                if((fromTourString == fromTour.HighlightTour) || (fromTourString == fromTour.exploreTour)) {
                    
                    if(loadedLevelThreeMarkerArray.count == 0) {
                        showOrHideLevelThreeHighlightTour()
                    } else {
                        for i in 0 ... loadedLevelThreeMarkerArray.count-1 {
                            (loadedLevelThreeMarkerArray[i] as! GMSMarker).map = self.viewForMap
                        }
                    }
                } else {
                    if(loadedLevelThreeMarkerArray.count == 0) {
                        showOrHideLevelThreeScienceTour()
                    } else {
                        for  i in 0 ... loadedLevelThreeMarkerArray.count-1 {
                            (loadedLevelThreeMarkerArray[i] as! GMSMarker).map = self.viewForMap
                        }
                    }
                    
                }
           // }
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), TourType: \(String(describing: fromTourString))")
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_floormap_loadthird,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    
    @IBAction func didtapSecondbutton(_ sender: UIButton) {
       if(level != levelNumber.two) {
        self.closeAudio()
        //self.loadingView.isHidden = false
       // self.loadingView.showLoading()
        //self.stopLoadingView(delayInSeconds: 0.3)
        self.playList = self.playLists[1]
        playButton.isHidden = false
        playerSlider.isHidden = false
        level = levelNumber.two
        firstLevelView.backgroundColor = UIColor.mapLevelColor
        secondLevelView.backgroundColor = UIColor.white
        thirdLevelView.backgroundColor = UIColor.mapLevelColor
        overlay.icon = UIImage(named: "qm_level_2")
    
        removeMarkers()
            //if (zoomValue > 18)  {
                
                if((fromTourString == fromTour.HighlightTour) || (fromTourString == fromTour.exploreTour)) {
                    if(loadedLevelTwoMarkerArray.count == 0) {
                        showOrHideLevelTwoHighlightTour()
                    } else {
                        for i in 0 ... loadedLevelTwoMarkerArray.count-1 {
                            (loadedLevelTwoMarkerArray[i] as! GMSMarker).map = self.viewForMap
                        }
                    }
                    
                } else {
                    if(loadedLevelTwoMarkerArray.count == 0) {
                        self.showOrHideLevelTwoScienceTour()
                    } else {
                        for i in 0 ... loadedLevelTwoMarkerArray.count-1 {
                            (loadedLevelTwoMarkerArray[i] as! GMSMarker).map = self.viewForMap
                        }
                    }
                    
                }
            //}
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), TourType: \(String(describing: fromTourString))")
        }
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_floormap_loadsecond,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    
    @IBAction func didTapFirstButton(_ sender: UIButton) {
        if(level != levelNumber.one) {
            self.closeAudio()
            playButton.isHidden = false
            playerSlider.isHidden = false
            self.playList = self.playLists[0]
            level = levelNumber.one
            firstLevelView.backgroundColor = UIColor.white
            secondLevelView.backgroundColor = UIColor.mapLevelColor
            thirdLevelView.backgroundColor = UIColor.mapLevelColor
            overlay.icon = UIImage(named: "qm_level_1")
            removeMarkers()
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_floormap_loadfirst,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func stopLoadingView(delayInSeconds : Double?) {
        //let delayInSeconds = 0.3
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds!) {
            self.loadingView.stopLoading()
            self.loadingView.isHidden = true
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        }
    }
    
    func removeMarkers() {
        l2_g1_sc3.map = nil
        l2_g8.map = nil
        l2_g8_sc1.map = nil
        l2_g8_sc6_1.map = nil
        l2_g8_sc6_2.map = nil
        l2_g8_sc5.map = nil
        l2_g8_sc4_1.map = nil
        l2_g8_sc4_2.map = nil
        l2_g9_sc7.map = nil
        l2_g9_sc5_1.map = nil
        l2_g9_sc5_2.map = nil
        l2_g5_sc6.map = nil
        l2_g3_sc13.map = nil
        l3_g10_sc1_1.map = nil
        l3_g10_sc1_2.map = nil
        l3_g11_wr15.map = nil
        l3_g13_5.map = nil
        l3_g13_7.map = nil
        l3_g17_3.map = nil
        
        l2_g1_sc2.map = nil
        l2_g1_sc7.map = nil
        l2_g1_sc8.map = nil
        l2_g1_sc13.map = nil
        l2_g1_sc14.map = nil
        l2_g2_2.map = nil
        l2_g3_sc14_1.map = nil
        l2_g3_sc14_2.map = nil
        l2_g3_wr4.map = nil
        l2_g4_sc5.map = nil
        l2_g3_sc3.map = nil
        l2_g5_sc5.map = nil
        l2_g5_sc11.map = nil
        l2_g7_sc13.map = nil
        l2_g7_sc8.map = nil
        l2_g7_sc4.map = nil
        
        
        l3_g10_wr2_1.map = nil
        l3_g10_wr2_2.map = nil
        l3_g10_podium14.map = nil
        l3_g10_podium9.map = nil
        l3_g11_14.map = nil
        l3_g12_11.map = nil
        l3_g12_12.map = nil
        l3_g12_17.map = nil
        l3_g12_wr5.map = nil
        l3_g13_2.map = nil
        l3_g13_15.map = nil
        l3_g14_7.map = nil
        l3_g14_13.map = nil
        l3_g15_13.map = nil
        l3_g16_wr5.map = nil
        l3_g17_8.map = nil
        l3_g17_9.map = nil
        l3_g18_1.map = nil
        
        l3_g18_2.map = nil
        l3_g18_11.map = nil
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    //MARK: Poup Delegate
    func objectPopupCloseButtonPressed() {
       // self.objectPopupView.removeFromSuperview()
        if ((fromTourString == fromTour.HighlightTour) || (fromTourString == fromTour.exploreTour))
        {
            if(level == levelNumber.two) {
                //showOrHideLevelTwoHighlightTour()
                if(loadedLevelTwoMarkerArray.count == 0) {
                    showOrHideLevelTwoHighlightTour()
                } else {
                    for i in 0 ... loadedLevelTwoMarkerArray.count-1 {
                        (loadedLevelTwoMarkerArray[i] as! GMSMarker).map = self.viewForMap
                    }
                }
            } else if(level == levelNumber.three) {
                if(loadedLevelThreeMarkerArray.count == 0) {
                    showOrHideLevelThreeHighlightTour()
                } else {
                    for i in 0 ... loadedLevelThreeMarkerArray.count-1 {
                        (loadedLevelThreeMarkerArray[i] as! GMSMarker).map = self.viewForMap
                    }
                }
            }
        } else {
            if (level == levelNumber.two) {
               // self.showOrHideLevelTwoScienceTour()
                if(loadedLevelTwoMarkerArray.count == 0) {
                    self.showOrHideLevelTwoScienceTour()
                } else {
                    for i in 0 ... loadedLevelTwoMarkerArray.count-1 {
                        (loadedLevelTwoMarkerArray[i] as! GMSMarker).map = self.viewForMap
                    }
                }
            } else {
               // self.showOrHideLevelThreeScienceTour()
                if(loadedLevelThreeMarkerArray.count == 0) {
                    showOrHideLevelThreeScienceTour()
                } else {
                    for  i in 0 ... loadedLevelThreeMarkerArray.count-1 {
                        (loadedLevelThreeMarkerArray[i] as! GMSMarker).map = self.viewForMap
                    }
                }
            }
        }
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), TourType: \(String(describing: fromTourString))")
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_floormap_objectclose,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    //Present detail popup using Bottomsheet
    func viewDetailButtonTapAction() {

    }
    @IBAction func didTapQrCode(_ sender: UIButton) {
    }
    
    @IBAction func didTapNumberSearch(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.performSegue(withIdentifier: "floormapToNumSearchSegue", sender: self)
//        if(fromScienceTour) {
//            let transition = CATransition()
//            transition.duration = 0.3
//            transition.type = kCATransitionPush
//            transition.subtype = kCATransitionFromLeft
//            self.view.window!.layer.add(transition, forKey: kCATransition)
//            self.dismiss(animated: false, completion: nil)
//        } else {
            let numberPadView = self.storyboard?.instantiateViewController(withIdentifier: "artifactNumberPadViewId") as! ArtifactNumberPadViewController
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionFade
            transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
            view.window!.layer.add(transition, forKey: kCATransition)
            self.present(numberPadView, animated: false, completion: nil)
//        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_floormap_numbersearch,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    
    //Added BottomSheet for showing popup when we clicked in marker
    func addBottomSheetView(scrollable: Bool? = true,index: Int?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        overlayView.isHidden = false
        self.avPlayer = nil
        self.timer?.invalidate()
        bottomSheetVC = MapDetailView()
        bottomSheetVC.mapdetailDelegate = self
        bottomSheetVC.popUpArray = floorMapArray
        bottomSheetVC.selectedIndex = index
        self.addChildViewController(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParentViewController: self)
        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
    }

    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        bottomSheetVC.selectedCell?.avPlayer = nil
        bottomSheetVC.selectedCell?.timer?.invalidate()
        bottomSheetVC.removeFromParentViewController()
        bottomSheetVC.dismiss(animated: false, completion: nil)
       // selectedMarker.icon = self.imageWithImage(image: selectedMarkerImage, scaledToSize: CGSize(width:38, height: 44))
        if(selectedMarkerImage != nil) {
            selectedMarker.icon = selectedMarkerImage
        }
        
        selectedScienceTour = ""
        
        bounceTimerTwo.invalidate()
        bounceTimerThree.invalidate()
        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: 0, height: 0)
        overlayView.isHidden = true
        if ((fromTourString == fromTour.HighlightTour) || (fromTourString == fromTour.exploreTour))
        {
            if(level == levelNumber.two) {
                //showOrHideLevelTwoHighlightTour()
                if(loadedLevelTwoMarkerArray.count == 0) {
                    showOrHideLevelTwoHighlightTour()
                } else {
                    for i in 0 ... loadedLevelTwoMarkerArray.count-1 {
                        (loadedLevelTwoMarkerArray[i] as! GMSMarker).map = self.viewForMap
                    }
                }
            } else if(level == levelNumber.three) {
                if(loadedLevelThreeMarkerArray.count == 0) {
                    showOrHideLevelThreeHighlightTour()
                } else {
                    for i in 0 ... loadedLevelThreeMarkerArray.count-1 {
                        (loadedLevelThreeMarkerArray[i] as! GMSMarker).map = self.viewForMap
                    }
                }
            }
        } else {
            if (level == levelNumber.two) {
                //self.showOrHideLevelTwoScienceTour()
                if(loadedLevelTwoMarkerArray.count == 0) {
                    self.showOrHideLevelTwoScienceTour()
                } else {
                    for i in 0 ... loadedLevelTwoMarkerArray.count-1 {
                        (loadedLevelTwoMarkerArray[i] as! GMSMarker).map = self.viewForMap
                    }
                }
            } else if(level == levelNumber.three) {
                if(loadedLevelThreeMarkerArray.count == 0) {
                    showOrHideLevelThreeScienceTour()
                } else {
                    for  i in 0 ... loadedLevelThreeMarkerArray.count-1 {
                        (loadedLevelThreeMarkerArray[i] as! GMSMarker).map = self.viewForMap
                    }
                }
                //self.showOrHideLevelThreeScienceTour()
            }
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    func dismissOvelay() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        overlayView.isHidden = true
        //selectedMarker.icon = self.imageWithImage(image: selectedMarkerImage, scaledToSize: CGSize(width:38, height: 44))
        if(selectedMarkerImage != nil) {
            selectedMarker.icon = selectedMarkerImage
        }
        selectedScienceTour = ""
        bounceTimerTwo.invalidate()
        bounceTimerThree.invalidate()
        if ((fromTourString == fromTour.HighlightTour) || (fromTourString == fromTour.exploreTour))
        {
            if(level == levelNumber.two) {
               // showOrHideLevelTwoHighlightTour()
                if(loadedLevelTwoMarkerArray.count == 0) {
                    showOrHideLevelTwoHighlightTour()
                } else {
                    for i in 0 ... loadedLevelTwoMarkerArray.count-1 {
                        (loadedLevelTwoMarkerArray[i] as! GMSMarker).map = self.viewForMap
                    }
                }
            } else if(level == levelNumber.three) {
                if(loadedLevelThreeMarkerArray.count == 0) {
                    showOrHideLevelThreeHighlightTour()
                } else {
                    for i in 0 ... loadedLevelThreeMarkerArray.count-1 {
                        (loadedLevelThreeMarkerArray[i] as! GMSMarker).map = self.viewForMap
                    }
                }
            }
        } else {
            if (level == levelNumber.two) {
                //self.showOrHideLevelTwoScienceTour()
                if(loadedLevelTwoMarkerArray.count == 0) {
                    self.showOrHideLevelTwoScienceTour()
                } else {
                    for i in 0 ... loadedLevelTwoMarkerArray.count-1 {
                        (loadedLevelTwoMarkerArray[i] as! GMSMarker).map = self.viewForMap
                    }
                }
            } else if(level == levelNumber.three) {
                //self.showOrHideLevelThreeScienceTour()
                if(loadedLevelThreeMarkerArray.count == 0) {
                    showOrHideLevelThreeScienceTour()
                } else {
                    for  i in 0 ... loadedLevelThreeMarkerArray.count-1 {
                        (loadedLevelThreeMarkerArray[i] as! GMSMarker).map = self.viewForMap
                    }
                }
            }
        }
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), TourType: \(String(describing: fromTourString)), Level: \(String(describing: level))")
        
    }
    //MARK: Audio SetUp
    func play(url:URL) {
        self.avPlayer = AVPlayer(playerItem: AVPlayerItem(url: url))
        if #available(iOS 10.0, *) {
            self.avPlayer.automaticallyWaitsToMinimizeStalling = false
        }
        avPlayer!.volume = 1.0
        avPlayer.play()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if (firstLoad == true) {
            playButton.setImage(UIImage(named:"pause_blackX1"), for: .normal)
            self.play(url: URL(string:self.playList)!)
            self.setupTimer()
            self.isPaused = false
        } else {
            self.togglePlayPause()
        }
        firstLoad = false
    }
    
    func togglePlayPause() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_floormap_playpause,
            AnalyticsParameterItemName: isPaused,
            AnalyticsParameterContentType: "cont"
            ])
    }
    
    @IBAction func sliderValueChange(_ sender: UISlider) {
        if(firstLoad) {
            self.avPlayer = AVPlayer(playerItem: AVPlayerItem(url: URL(string: playList)!))
        }
        let seconds : Int64 = Int64(sender.value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        avPlayer!.seek(to: targetTime)
        if(isPaused == false){
            seekLoadingLabel.alpha = 1
        }
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), IsFirstLoad: \(firstLoad)")
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_floormap_sliderchange,
            AnalyticsParameterItemName: isPaused,
            AnalyticsParameterContentType: "cont"
            ])
    }

    func setupTimer(){
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        timer = Timer(timeInterval: 0.001, target: self, selector: #selector(FloorMapViewController.tick), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    }
    @objc func didPlayToEnd() {
       // self.nextTrack()
    }
    
    @objc func tick(){
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
            
        }else{
            playerSlider.value = 0
            playerSlider.minimumValue = 0
            playerSlider.maximumValue = 0
        }
    }
    func formatTimeFromSeconds(totalSeconds: Int32) -> String {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let seconds: Int32 = totalSeconds%60
        let minutes: Int32 = (totalSeconds/60)%60
        let hours: Int32 = totalSeconds/3600
        return String(format: "%02d:%02d:%02d", hours,minutes,seconds)
    }
    
    func closeAudio() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        playButton.setImage(UIImage(named:"play_blackX1"), for: .normal)
        playerSlider.value = 0
        self.avPlayer = nil
        self.timer?.invalidate()
        self.firstLoad = true
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.dismiss(animated: true) {
            self.avPlayer = nil
            self.timer?.invalidate()
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_header_back,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    
   
    func showOrHideLevelTwoHighlightTour() {
        self.loadingView.isHidden = false
        self.loadingView.showLoading()
        for i in 0 ... self.levelTwoPositionArray.count-1 {
            if let searchResult = self.floorMapArray.first(where: {$0.artifactPosition! == self.levelTwoPositionArray[i] as! String}) {
                if(searchResult.artifactImg != nil) {
                    let artImg = UIImage(data: searchResult.artifactImg!)
                    if((fromTourString == fromTour.HighlightTour) && (selectedScienceTour! == (self.levelTwoPositionArray[i] as! String))) {
                        (self.levelTwoMarkerArray[i] as! GMSMarker).icon = self.imageWithImage(image: artImg!, scaledToSize: CGSize(width:54, height: 64))
                        selectedMarker = self.levelTwoMarkerArray[i] as! GMSMarker
                        selectedMarkerImage = artImg!
                    } else {
                        (self.levelTwoMarkerArray[i] as! GMSMarker).icon = artImg
                    }

                } else {
                if let imageUrl = searchResult.thumbImage{
                    if(imageUrl != "") {
                        KingfisherManager.shared.retrieveImage(with: URL(string: imageUrl)!, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                            if((self.fromTourString == fromTour.HighlightTour) && (self.selectedScienceTour! == (self.levelTwoPositionArray[i] as! String))) {
                                (self.levelTwoMarkerArray[i] as! GMSMarker).icon = self.imageWithImage(image: image!, scaledToSize: CGSize(width:54, height: 64))
                                self.selectedMarker = self.levelTwoMarkerArray[i] as! GMSMarker
                                self.selectedMarkerImage = image!
                            } else {
                                (self.levelTwoMarkerArray[i] as! GMSMarker).icon = image
                            }
                            if(self.selectedScienceTourLevel == "2") {
                                (self.levelTwoMarkerArray[i] as! GMSMarker).map = self.viewForMap
                                
                            }
                           self.loadedLevelTwoMarkerArray.add(self.levelTwoMarkerArray[i])
                        })
                   
                    }
                }
            }
                if((self.levelTwoMarkerArray[i] as! GMSMarker).icon == nil) {
                    (self.levelTwoMarkerArray[i] as! GMSMarker).map = nil
                }

            } else {
                (self.levelTwoMarkerArray[i] as! GMSMarker).map = nil
            }
        }
        self.loadingView.stopLoading()
        self.loadingView.isHidden = true
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    func showOrHideLevelThreeHighlightTour() {
        self.loadingView.isHidden = false
        self.loadingView.showLoading()
        for i in 0 ... self.levelThreePositionArray.count-1 {
            if let searchResult = self.floorMapArray.first(where: {$0.artifactPosition! == self.levelThreePositionArray[i] as! String}) {

                if(searchResult.artifactImg != nil) {
                    let artImg = UIImage(data: searchResult.artifactImg!)
                    if((fromTourString == fromTour.HighlightTour) && (selectedScienceTour! == (self.levelThreePositionArray[i] as! String))) {
                        (self.levelThreeMarkerArray[i] as! GMSMarker).icon = self.imageWithImage(image: artImg!, scaledToSize: CGSize(width:54, height: 64))
                        selectedMarker = self.levelThreeMarkerArray[i] as! GMSMarker
                        selectedMarkerImage = artImg!
                    } else {
                        (self.levelThreeMarkerArray[i] as! GMSMarker).icon = artImg
                    }
                }
                else {
                if let imageUrl = searchResult.thumbImage{
                    if(imageUrl != "") {
                        KingfisherManager.shared.retrieveImage(with: URL(string: imageUrl)!, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                            
                            if((self.fromTourString == fromTour.HighlightTour) && (self.selectedScienceTour! == (self.levelThreePositionArray[i] as! String))) {
                                (self.levelThreeMarkerArray[i] as! GMSMarker).icon = self.imageWithImage(image: image!, scaledToSize: CGSize(width:54, height: 64))
                                self.selectedMarker = self.levelThreeMarkerArray[i] as! GMSMarker
                                self.selectedMarkerImage = image!
                            } else {
                                (self.levelThreeMarkerArray[i] as! GMSMarker).icon = image
                            }
                            if(self.selectedScienceTourLevel == "3") {
                                (self.levelThreeMarkerArray[i] as! GMSMarker).map = self.viewForMap
                            }
                            self.loadedLevelThreeMarkerArray.add(self.levelThreeMarkerArray[i])
                        })
                       
                    }
                }
                }
                if((self.levelThreeMarkerArray[i] as! GMSMarker).icon == nil) {
                    (self.levelThreeMarkerArray[i] as! GMSMarker).map = nil
                }
                
            } else {
                (self.levelThreeMarkerArray[i] as! GMSMarker).map = nil
            }
        }

        self.loadingView.stopLoading()
        self.loadingView.isHidden = true
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }

    func showOrHideLevelTwoScienceTour() {
        self.loadingView.isHidden = false
        self.loadingView.showLoading()
        for i in 0 ... self.levelTwoPositionArray.count-1 {
            if let searchResult = self.floorMapArray.first(where: {$0.artifactPosition! == self.levelTwoPositionArray[i] as! String}) {
                if(searchResult.floorLevel != "") {

                if(searchResult.artifactImg != nil) {
                    let artImg = UIImage(data: searchResult.artifactImg!)
                    if((fromTourString == fromTour.scienceTour) && (selectedScienceTour! == (self.levelTwoPositionArray[i] as! String))) {
                        (self.levelTwoMarkerArray[i] as! GMSMarker).icon = self.imageWithImage(image: artImg!, scaledToSize: CGSize(width:54, height: 64))
                        selectedMarker = self.levelTwoMarkerArray[i] as! GMSMarker
                        selectedMarkerImage = artImg!
                    } else {
                        (self.levelTwoMarkerArray[i] as! GMSMarker).icon = artImg
                    }
                }
                else {
                if let imageUrl = searchResult.thumbImage{
                    if(imageUrl != "") {
                        KingfisherManager.shared.retrieveImage(with: URL(string: imageUrl)!, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                            
                            if((self.fromTourString == fromTour.scienceTour) && (self.selectedScienceTour! == (self.levelTwoPositionArray[i] as! String))) {
                                (self.levelTwoMarkerArray[i] as! GMSMarker).icon = self.imageWithImage(image: image!, scaledToSize: CGSize(width:54, height: 64))
                                self.selectedMarker = self.levelTwoMarkerArray[i] as! GMSMarker
                                self.selectedMarkerImage = image!
                            } else {
                                (self.levelTwoMarkerArray[i] as! GMSMarker).icon = image
                            }
                            if(self.selectedScienceTourLevel == "2") {
                                (self.levelTwoMarkerArray[i] as! GMSMarker).map = self.viewForMap
                            }
                            
                            self.loadedLevelTwoMarkerArray.add(self.levelTwoMarkerArray[i])
                        })
                    }
                }
                }
                    if((self.levelTwoMarkerArray[i] as! GMSMarker).icon == nil) {
                        (self.levelTwoMarkerArray[i] as! GMSMarker).map = nil
                    }

            }
                else {
                    (self.levelTwoMarkerArray[i] as! GMSMarker).map = nil
                }
            } else {
                (self.levelTwoMarkerArray[i] as! GMSMarker).map = nil
            }
        }
        self.loadingView.stopLoading()
        self.loadingView.isHidden = true
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func showOrHideLevelThreeScienceTour() {
        self.loadingView.isHidden = false
        self.loadingView.showLoading()
        for i in 0 ... self.levelThreePositionArray.count-1 {
            if let searchResult = self.floorMapArray.first(where: {$0.artifactPosition! == self.levelThreePositionArray[i] as! String}) {

                if(searchResult.artifactImg != nil) {
                    let artImg = UIImage(data: searchResult.artifactImg!)
                    if((fromTourString == fromTour.scienceTour) && (selectedScienceTour! == (self.levelThreePositionArray[i] as! String))) {
                        (self.levelThreeMarkerArray[i] as! GMSMarker).icon = self.imageWithImage(image: artImg!, scaledToSize: CGSize(width:54, height: 64))
                        selectedMarker = self.levelThreeMarkerArray[i] as! GMSMarker
                        selectedMarkerImage = artImg!
                    } else {
                        (self.levelThreeMarkerArray[i] as! GMSMarker).icon = artImg
                    }
                }
                else {
                if let imageUrl = searchResult.thumbImage{
                     if(imageUrl != "") {
                        KingfisherManager.shared.retrieveImage(with: URL(string: imageUrl)!, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                            
                            if((self.fromTourString == fromTour.scienceTour) && (self.selectedScienceTour! == (self.levelThreePositionArray[i] as! String))) {
                                (self.levelThreeMarkerArray[i] as! GMSMarker).icon = self.imageWithImage(image: image!, scaledToSize: CGSize(width:54, height: 64))
                                self.selectedMarker = self.levelThreeMarkerArray[i] as! GMSMarker
                                self.selectedMarkerImage = image!
                            } else {
                                (self.levelThreeMarkerArray[i] as! GMSMarker).icon = image
                            }
                            if(self.selectedScienceTourLevel == "3") {
                                (self.levelThreeMarkerArray[i] as! GMSMarker).map = self.viewForMap
                            }
                            self.loadedLevelThreeMarkerArray.add(self.levelThreeMarkerArray[i])
                        })
                    }
                    
                }
                }
                if((self.levelThreeMarkerArray[i] as! GMSMarker).icon == nil) {
                     (self.levelThreeMarkerArray[i] as! GMSMarker).map = nil
                }

            } else {
                (self.levelThreeMarkerArray[i] as! GMSMarker).map = nil
            }
        }
        //self.stopLoadingView()
        self.loadingView.stopLoading()
        self.loadingView.isHidden = true
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }

    func showNodata() {

    }
    
    //MARK: LoadingView Delegate
    func tryAgainButtonPressed() {
        if  (networkReachability?.isReachable)! {
            self.getFloorMapDataFromServer()
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), NetworkReachability: \(String(describing: networkReachability?.isReachable))")
    }
    func showNoNetwork() {
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @objc func receiveFloormapNotification(notification: NSNotification) {
        let data = notification.userInfo as? [String:String]
        if (data?.count)!>0 {
            if(tourGuideId == data!["id"]) {
                self.fetchTourGuideFromCoredata()
            }
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(FLOORMAP_VC, screenClass: screenClass)
    }
}
extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

extension FloorMapViewController: HeaderViewProtocol,MapDetailProtocol,LoadingViewProtocol {
    //MARK:Header Protocol
    func headerCloseButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.loadedLevelThreeMarkerArray = NSMutableArray()
        self.loadedLevelTwoMarkerArray = NSMutableArray()
        self.avPlayer = nil
        self.timer?.invalidate()
        if (fromTourString == fromTour.exploreTour) {
            let transition = CATransition()
            transition.duration = 0.2
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.dismiss(animated: false, completion: nil)
        }else {
            let transition = CATransition()
            transition.duration = 0.9
            transition.type = "flip"
            transition.subtype = kCATransitionFromRight
            view.window!.layer.add(transition, forKey: kCATransition)
            self.dismiss(animated: true, completion: nil)
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_header_close,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    func filterButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.avPlayer = nil
        self.timer?.invalidate()
        self.dismiss(animated: true, completion: nil)
    }
}