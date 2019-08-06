//
//  CPArtifactNumberPadViewController.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 17/08/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Crashlytics
import Firebase
import UIKit


class CPArtifactNumberPadViewController: UIViewController, HeaderViewProtocol {
    @IBOutlet weak var artifactHeader: CommonHeaderView!
    @IBOutlet weak var numberPadCollectionView: UICollectionView!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var objectTitleLabel: UILabel!
    @IBOutlet weak var objectInfoLabel: UILabel!
    @IBOutlet weak var artifactTextField: UITextField!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var qrScannerLabel: UILabel!
    
    @IBOutlet weak var toViewLabel: UILabel!
    let NUMBER_CELL_WIDTH: CGFloat = 100.0
    var artifactValue: String = ""
    var tourGuideId : String? = nil
    var objectDetailArray: [TourGuideFloorMap]! = []
    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        
        super.viewDidLoad()        
        setupUI()
        registerNib()
        self.recordScreenView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerNib() {
        let nib = UINib(nibName: "ArtifactNumberPadCell", bundle: nil)
        numberPadCollectionView?.register(nib, forCellWithReuseIdentifier: "artifactNumberPadCellId")
    }
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        artifactTextField.text = ""
        artifactValue = ""
    }
    func setupUI() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        artifactHeader.headerViewDelegate = self
        artifactHeader.headerTitle.text = NSLocalizedString("ARTIFACT_NUMBERPAD_TITLE", comment: "ARTIFACT_NUMBERPAD_TITLE  in the Artifact Number Pad page")
        artifactHeader.headerTitle.font = UIFont.headerFont
        artifactHeader.headerBackButton.setImage(UIImage(named: "closeX1"), for: .normal)
        artifactHeader.headerBackButton.contentEdgeInsets = UIEdgeInsets(top:14, left:19, bottom: 14, right:19)
        //artifactHeader.headerBackButton.contentMode = .scaleAspectFill
        
        objectTitleLabel.text = NSLocalizedString("OBJECT_TITLE", comment: "OBJECT_TITLE  in the Artifact Number Pad page")
        objectInfoLabel.text = NSLocalizedString("OBJECT_INFO", comment: "OBJECT_INFO  in the Artifact Number Pad page")
        toViewLabel.text = NSLocalizedString("TO_VIEW_MESSAGE", comment: "TO_VIEW_MESSAGE  in the Artifact Number Pad page")
        orLabel.text = NSLocalizedString("OR_LABEL", comment: "OR_LABEL  in the Artifact Number Pad page")
        qrScannerLabel.text = NSLocalizedString("USE_QR_SCANNER", comment: "USE_QR_SCANNER  in the Artifact Number Pad page")
        objectTitleLabel.font = UIFont.englishTitleFont
        objectInfoLabel.font = UIFont.englishTitleFont
        toViewLabel.font = UIFont.englishTitleFont
        orLabel.font = UIFont.englishTitleFont
        qrScannerLabel.font = UIFont.englishTitleFont
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func getObjectDetail() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if ((artifactTextField.text != nil) && (artifactTextField.text != "") ) {
            loadingView.isHidden = false
            loadingView.showLoading()
            getnumberSearchDataFromServer(searchString: self.artifactTextField.text)
        } else {
            self.view.hideAllToasts()
            let locationMissingMessage =  NSLocalizedString("ENTER_ARTIFACT_NUMBER", comment: "ENTER_ARTIFACT_NUMBER")
            self.view.makeToast(locationMissingMessage)
        }
    }
    func loadObjectDetail() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if(objectDetailArray[0] != nil) {
            self.performSegue(withIdentifier: "numSearchToObjDetailSegue", sender: self)
        }
        
    }
    //MARK: Header delegate
    func headerCloseButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_header_close,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
        dismiss(animated: false, completion: nil)
    }
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(ARTIFACT_NUMBER_VC, screenClass: screenClass)
    }
}

//MARK:- WebServiceCall
extension CPArtifactNumberPadViewController {
    func getnumberSearchDataFromServer(searchString : String?)
    {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)" + "SearchString: \(searchString)")
        if((searchString != "") && (searchString != nil)) {
            _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.CollectionByTourGuide(LocalizationLanguage.currentAppleLanguage(),["artifact_number": searchString!])).responseObject { [weak self] (response: DataResponse<TourGuideFloorMaps>) -> Void in
                switch response.result {
                case .success(let data):
                    self?.objectDetailArray = data.tourGuideFloorMap
                    if(self?.objectDetailArray.count != 0) {
                        self?.loadObjectDetail()
                    }
                    self?.loadingView.stopLoading()
                    self?.loadingView.isHidden = true
                    
                    if (self?.objectDetailArray.count == 0) {
                        self?.loadingView.stopLoading()
                        self?.loadingView.isHidden = true
                        self?.view.hideAllToasts()
                        let locationMissingMessage =  NSLocalizedString("NO_ARTIFACTS", comment: "NO_ARTIFACTS")
                        self?.view.makeToast(locationMissingMessage)
                        
                    }
                case .failure(let error):
                    self?.loadingView.stopLoading()
                    self?.loadingView.isHidden = true
                }
            }
        }
    }
}

//MARK:- Segue controller
extension CPArtifactNumberPadViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "numSearchToObjDetailSegue") {
            let objectDetailView = segue.destination as! CPObjectDetailViewController
            objectDetailView.detailArray.append(objectDetailArray[0])
        }
    }
}

