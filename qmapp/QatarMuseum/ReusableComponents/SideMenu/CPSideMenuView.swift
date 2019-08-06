//
//  SideMenuView.swift
//  QatarMuseum
//
//  Created by Wakralab Software Labs on 06/06/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import UIKit

protocol CPSideMenuProtocol
{
    func exhibitionButtonPressed()
    func eventbuttonPressed()
    func educationButtonPressed()
    func tourGuideButtonPressed()
    func heritageButtonPressed()
    func publicArtsButtonPressed()
    func parksButtonPressed()
    func diningButtonPressed()
    func giftShopButtonPressed()
    func settingsButtonPressed()
    
    func menuEventPressed()
    func menuNotificationPressed()
    func menuProfilePressed()
    func menuClosePressed()
    
}
class CPSideMenuView: UIView,TopBarProtocol {
    
   
    @IBOutlet weak var sideMenuContentView: UIView!
    @IBOutlet weak var topBarView: TopBarView!
    
    @IBOutlet weak var exhibitionButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var educationButton: UIButton!
    @IBOutlet weak var tourGuideButton: UIButton!
    @IBOutlet weak var heritageButton: UIButton!
    @IBOutlet weak var publicArtsButton: UIButton!
    @IBOutlet weak var parksButton: UIButton!
    @IBOutlet weak var diningButton: UIButton!
    @IBOutlet weak var giftShopButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet var sideMenuView: UIView!
    @IBOutlet weak var exhibitionsLabel: UILabel!
    @IBOutlet weak var eventsLabel: UILabel!
    @IBOutlet weak var educationLabel: UILabel!
    @IBOutlet weak var tourGuideLabel: UILabel!
    @IBOutlet weak var heritageSitesLabel: UILabel!
    @IBOutlet weak var publicArtsLabel: UILabel!
    @IBOutlet weak var diningLabel: UILabel!
    @IBOutlet weak var giftShopLabel: UILabel!
    @IBOutlet weak var parksLabel: UILabel!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var exhibitionView: UIView!
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var educationView: UIView!
    @IBOutlet weak var tourGuideView: UIView!
    @IBOutlet weak var heritageView: UIView!
    @IBOutlet weak var publicArtsView: UIView!
    @IBOutlet weak var parksView: UIView!
    @IBOutlet weak var diningView: UIView!
    @IBOutlet weak var giftShopView: UIView!
    @IBOutlet weak var settingsView: UIView!
    
    var sideMenuDelegate : CPSideMenuProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    private func commonInit() {
        Bundle.main.loadNibNamed("SideMenu", owner: self, options: nil)
        addSubview(sideMenuView)
        sideMenuView.frame = self.bounds
        sideMenuView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        topBarView.topbarDelegate = self
        topBarView.menuButton.setImage(UIImage(named: "closeX1"), for: .normal)
        topBarView.backgroundColor = UIColor.clear
        topBarView.backButton.isHidden = true
        topBarView.eventButton.isHidden = true
        topBarView.notificationButton.isHidden = true
        topBarView.profileButton.isHidden = true
        topBarView.badgeLabel.isHidden = true

        exhibitionsLabel.text = NSLocalizedString("EXHIBITIONS_LABEL", comment: "EXHIBITIONS_LABEL Label in the SideMenu page")
        eventsLabel.text = NSLocalizedString("EVENTS_LABEL", comment: "EVENTS_LABEL Label in the SideMenu page")
        educationLabel.text = NSLocalizedString("EDUCATION_LABEL", comment: "EDUCATION_LABEL Label in the SideMenu page")
        tourGuideLabel.text = NSLocalizedString("TOURGUIDE_LABEL", comment: "TOURGUIDE_LABEL Label in the SideMenu page")
        heritageSitesLabel.text = NSLocalizedString("HERITAGESITES_LABEL", comment: "HERITAGESITES_LABEL Label in the SideMenu page")
        publicArtsLabel.text = NSLocalizedString("PUBLIC_ARTS_LABEL", comment: "PUBLIC_ARTS_LABEL Label in the SideMenu page")
        diningLabel.text = NSLocalizedString("DINING_LABEL", comment: "DINING_LABEL Label in the SideMenu page")
        giftShopLabel.text = NSLocalizedString("GIFTSHOP_LABEL", comment: "GIFTSHOP_LABEL Label in the SideMenu page")
        parksLabel.text = NSLocalizedString("PARKS_LABEL", comment: "PARKS_LABEL Label in the SideMenu page")
        settingsLabel.text = NSLocalizedString("SIDEMENU_SETTINGS_LABEL", comment: "SIDEMENU_SETTINGS_LABEL Label in the SideMenu page")
        
        exhibitionsLabel.font = UIFont.sideMenuLabelFont
        eventsLabel.font = UIFont.sideMenuLabelFont
        educationLabel.font = UIFont.sideMenuLabelFont
        tourGuideLabel.font = UIFont.sideMenuLabelFont
        heritageSitesLabel.font = UIFont.sideMenuLabelFont
        publicArtsLabel.font = UIFont.sideMenuLabelFont
        diningLabel.font = UIFont.sideMenuLabelFont
        giftShopLabel.font = UIFont.sideMenuLabelFont
        parksLabel.font = UIFont.sideMenuLabelFont
        settingsLabel.font = UIFont.sideMenuLabelFont
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func didTapExhibition(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.exhibitionView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                self.exhibitionView.transform = CGAffineTransform.identity
                                self.sideMenuDelegate?.exhibitionButtonPressed()
                            })
        })
        
    }
    @IBAction func didTapEvent(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.eventView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                self.eventView.transform = CGAffineTransform.identity
                                self.sideMenuDelegate?.eventbuttonPressed()
                            })
        })
        
    }
    @IBAction func didTapEducation(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.educationView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                self.educationView.transform = CGAffineTransform.identity
                                self.sideMenuDelegate?.educationButtonPressed()
                            })
        })
        
    }
    @IBAction func didTapTourGuide(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.tourGuideView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                self.tourGuideView.transform = CGAffineTransform.identity
                                self.sideMenuDelegate?.tourGuideButtonPressed()
                            })
        })
        
    }
    @IBAction func didTapHeritageSites(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.heritageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                self.heritageView.transform = CGAffineTransform.identity
                                self.sideMenuDelegate?.heritageButtonPressed()
                            })
        })
        
    }
    @IBAction func didTapPublicArts(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.publicArtsView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                self.publicArtsView.transform = CGAffineTransform.identity
                                self.sideMenuDelegate?.publicArtsButtonPressed()
                            })
        })
    }
    @IBAction func didTapParks(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.parksView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                self.parksView.transform = CGAffineTransform.identity
                                self.sideMenuDelegate?.parksButtonPressed()
                            })
        })
        
    }
    @IBAction func didTapDining(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.diningView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                self.diningView.transform = CGAffineTransform.identity
                                self.sideMenuDelegate?.diningButtonPressed()
                            })
        })
        
    }
    @IBAction func didTapGiftShop(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.giftShopView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                self.giftShopView.transform = CGAffineTransform.identity
                                self.sideMenuDelegate?.giftShopButtonPressed()
                            })
        })
    }
    @IBAction func didTapSettings(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        UIButton.animate(withDuration: 0.3,
                         animations: {
                            self.settingsView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                self.settingsView.transform = CGAffineTransform.identity
                                self.sideMenuDelegate?.settingsButtonPressed()
                            })
        })
        
    }
    func eventButtonPressed() {
        sideMenuDelegate?.menuEventPressed()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func notificationbuttonPressed() {
        sideMenuDelegate?.menuNotificationPressed()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func profileButtonPressed() {
        sideMenuDelegate?.menuProfilePressed()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func menuButtonPressed() {
        sideMenuDelegate?.menuClosePressed()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func backButtonPressed() {
        
    }
    
    
}
