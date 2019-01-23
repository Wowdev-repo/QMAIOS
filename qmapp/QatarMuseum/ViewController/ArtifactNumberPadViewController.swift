//
//  ArtifactNumberPadViewController.swift
//  QatarMuseums
//
//  Created by Developer on 17/08/18.
//  Copyright © 2018 Exalture. All rights reserved.
//
import Alamofire
import Crashlytics
import UIKit

class ArtifactNumberPadViewController: UIViewController, HeaderViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        super.viewDidLoad()        
        setupUI()
        registerNib()
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
    //MARK: collectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ArtifactNumberPadCell = numberPadCollectionView.dequeueReusableCell(withReuseIdentifier: "artifactNumberPadCellId", for: indexPath) as! ArtifactNumberPadCell
       // cell.innerView.layer.cornerRadius = (NUMBER_CELL_WIDTH-10)/2
        let cellWidth = numberPadCollectionView.frame.width/3
        let corner = (cellWidth)/2-15
        cell.innerView.layer.cornerRadius = CGFloat(Int(floorf(Float(corner))))
        if (indexPath.row == 11) {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                cell.imageView.image = UIImage(named: "back_mirrorX1")
            } else {
                cell.imageView.image = UIImage(named: "back_buttonX1")
            }
            cell.innerView.backgroundColor = UIColor.viewMycultureBlue
        } else if (indexPath.row == 10) {
            cell.numLabel.text = "0"
        } else if (indexPath.row == 9) {
            cell.imageView.image = UIImage(named: "closeX1")
            cell.innerView.backgroundColor = UIColor.profilePink
        } else {
            cell.numLabel.text = String(indexPath.row + 1)
        }
        
        if (artifactValue == "") {
            if (indexPath.row == 11) {
                cell.innerView.alpha = 0.3
            } else if (indexPath.row == 9) {
                cell.innerView.alpha = 0.3
            }
        }
        loadingView.stopLoading()
        loadingView.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //return CGSize(width: NUMBER_CELL_WIDTH, height: NUMBER_CELL_WIDTH)
        let heightValue = UIScreen.main.bounds.height/100
        return CGSize(width: numberPadCollectionView.frame.width/3-20, height:numberPadCollectionView.frame.width/3-20)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell : ArtifactNumberPadCell = numberPadCollectionView.dequeueReusableCell(withReuseIdentifier: "artifactNumberPadCellId", for: indexPath) as! ArtifactNumberPadCell
        
        if (indexPath.row == 9) {
            artifactTextField.text = ""
            cell.innerView.alpha = 0.3
            disableButtons(collectionView: collectionView)
        } else if (indexPath.row == 11) {
            if artifactValue != "" {
               getObjectDetail()
            }
        } else {
            enableButtons(collectionView: collectionView)
            if (indexPath.row == 10) {
                artifactTextField.text = artifactValue + "0"
            } else {
                artifactTextField.text = artifactValue + String(indexPath.row + 1)
            }
        }
        artifactValue = artifactTextField.text!
    }
    
    func disableButtons(collectionView: UICollectionView) {
        let closeButtonView = collectionView.cellForItem(at: IndexPath(item: 9,
                                                                   section: 0)) as! ArtifactNumberPadCell
        
        closeButtonView.innerView.alpha = 0.3
        let nextButtonView = collectionView.cellForItem(at: IndexPath(item: 11,
                                                                   section: 0)) as! ArtifactNumberPadCell
        nextButtonView.innerView.alpha = 0.3
    }
    
    func enableButtons(collectionView: UICollectionView) {
        let closeButtonView = collectionView.cellForItem(at: IndexPath(item: 9,
                                                                       section: 0)) as! ArtifactNumberPadCell
        
        closeButtonView.innerView.alpha = 1.0
        let nextButtonView = collectionView.cellForItem(at: IndexPath(item: 11,
                                                                      section: 0)) as! ArtifactNumberPadCell
        nextButtonView.innerView.alpha = 1.0
    }
    
    func getObjectDetail() {
        
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
        if(objectDetailArray[0] != nil) {
            let objectDetailView =  self.storyboard?.instantiateViewController(withIdentifier: "objectDetailId") as! ObjectDetailViewController
            objectDetailView.detailArray.append(objectDetailArray[0])
//            let transition = CATransition()
//            transition.duration = 0.3
//            transition.type = kCATransitionFade
//            transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
//            view.window!.layer.add(transition, forKey: kCATransition)
            self.present(objectDetailView, animated: false, completion: nil)
        }
        
    }
    //MARK: Header delegate
    func headerCloseButtonPressed() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
    //MARK: WebServiceCall
    func getnumberSearchDataFromServer(searchString : String?)
    {
        if((searchString != "") && (searchString != nil)) {
        _ = Alamofire.request(QatarMuseumRouter.CollectionByTourGuide(LocalizationLanguage.currentAppleLanguage(),["artifact_number": searchString!])).responseObject { (response: DataResponse<TourGuideFloorMaps>) -> Void in
            switch response.result {
            case .success(let data):
                self.objectDetailArray = data.tourGuideFloorMap
                if(self.objectDetailArray.count != 0) {
                    self.loadObjectDetail()
                }
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                
                if (self.objectDetailArray.count == 0) {
                   self.loadingView.stopLoading()
                    self.loadingView.isHidden = true
                    self.view.hideAllToasts()
                    let locationMissingMessage =  NSLocalizedString("NO_ARTIFACTS", comment: "NO_ARTIFACTS")
                    self.view.makeToast(locationMissingMessage)

                }
            case .failure(let error):
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
            }
        }
    }
    }
}

