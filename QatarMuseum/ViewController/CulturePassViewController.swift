//
//  CulturePassViewController.swift
//  QatarMuseums
//
//  Created by Developer on 21/08/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit

class CulturePassViewController: UIViewController, HeaderViewProtocol, UITableViewDelegate, UITableViewDataSource, comingSoonPopUpProtocol {
    @IBOutlet weak var headerView: CommonHeaderView!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var secondIntroLabel: UILabel!
    @IBOutlet weak var benefitLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var notMemberLabel: UILabel!
    @IBOutlet weak var alreadyMemberLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    let benefitList = ["15% DISCOUNT AT QM CAFE'S ACROSS ALL VENUES",
                       "10% DISCOUNT ON TEMS IN ALL QM GIFT SHOPS (without minimum purchase)",
                       "10% DISCOUNT AT IDAM RESTAURANT AT LUNCH TIME",
                       "RECEIVE OUR MONTHLY NEWSLETTER TO STAY UP TO DATE ON QM AND PARTNER OFFERINGS",
                       "GET PREMIER ACCESS TO MEMBERS ONLY TALKS &WORKSHOPS",
                       "GET EXCLUSIVE INVITATION TO QM OPEN HOUSE ACCESS TO OUR WORLD CLASS CALL CENTER 8AM TO 8PM DAILY"]
    
    override func viewDidLoad() {
        super.viewDidLoad()   
        setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        loadingView.isHidden = false
        loadingView.showLoading()
        headerView.headerViewDelegate = self
        headerView.headerTitle.text = NSLocalizedString("CULTUREPASS_TITLE", comment: "CULTUREPASS_TITLE in the Culture Pass page")
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            headerView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        } else {
            headerView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
        }
        
        introLabel.textAlignment = .left
        secondIntroLabel.textAlignment = .left
        benefitLabel.textAlignment = .center

        benefitLabel.font = UIFont.closeButtonFont
        introLabel.font = UIFont.englishTitleFont
        secondIntroLabel.font = UIFont.englishTitleFont
        notMemberLabel.font = UIFont.englishTitleFont
        alreadyMemberLabel.font = UIFont.englishTitleFont
        
        benefitLabel.text = NSLocalizedString("BENEFIT_TITLE", comment: "BENEFIT_TITLE in the Culture Pass page")
        introLabel.text = NSLocalizedString("CULTURE_PASS_INTRO", comment: "CULTURE_PASS_INTRO in the Culture Pass page")
        secondIntroLabel.text = NSLocalizedString("CULTURE_PASS_SECONDDESC", comment: "CULTURE_PASS_SECONDDESC in the Culture Pass page")
    }
    
    //MARK: TableView delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return benefitList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "benefitLabelCellId", for: indexPath) as! BenefitLabelCell
        cell.benefitLabel.text = "- " + benefitList[indexPath.row]
        loadingView.stopLoading()
        loadingView.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func loadComingSoonPopup() {
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadPopup()
        self.view.addSubview(popupView)
    }
    
    func closeButtonPressed() {
        self.popupView.removeFromSuperview()
    }
    
    @IBAction func didTapRegisterButton(_ sender: UIButton) {
        loadComingSoonPopup()
        self.registerButton.backgroundColor = UIColor.profilePink
        self.registerButton.setTitleColor(UIColor.whiteColor, for: .normal)
        self.registerButton.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    
    @IBAction func registerButtonTouchDown(_ sender: UIButton) {
        self.registerButton.backgroundColor = UIColor.profileLightPink
        self.registerButton.setTitleColor(UIColor.viewMyFavDarkPink, for: .normal)
        self.registerButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @IBAction func didTapLogInButton(_ sender: UIButton) {
        loadComingSoonPopup()
        self.logInButton.backgroundColor = UIColor.viewMycultureBlue
        self.logInButton.setTitleColor(UIColor.white, for: .normal)
        self.logInButton.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    
    @IBAction func logInButtonTouchDown(_ sender: UIButton) {
        self.logInButton.backgroundColor = UIColor.viewMycultureLightBlue
        self.logInButton.setTitleColor(UIColor.viewMyculTitleBlue, for: .normal)
        self.logInButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    //MARK: Header delegates
    func headerCloseButtonPressed() {
        let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeId") as! HomeViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = homeViewController
    }
}
