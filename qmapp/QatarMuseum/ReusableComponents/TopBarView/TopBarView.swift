//
//  TopBarView.swift
//  QatarMuseum
//
//  Created by Exalture on 06/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit
import CocoaLumberjack
protocol TopBarProtocol
{
    func eventButtonPressed()
    func notificationbuttonPressed()
    func profileButtonPressed()
    func menuButtonPressed()
    func backButtonPressed()
    
}
protocol APNProtocol {
    func updateNotificationBadgeCount()
}

class TopBarView: UIView {
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet var topView: UIView!
    
    var topbarDelegate : TopBarProtocol?
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("TopBarView", owner: self, options: nil)
        addSubview(topView)
        topView.frame = self.bounds
        topView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        badgeLabel.textAlignment = .center
        updateNotificationBadgeCount()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }

    func updateNotificationBadgeCount() {
        if let badgeCount = UserDefaults.standard.value(forKey: "notificationBadgeCount") as?
            Int {
            badgeLabel.isHidden = false
            badgeLabel.text = "  " + String(badgeCount)
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)" + "Badge Count:" + String(badgeCount))
        } else {
            badgeLabel.isHidden = true
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)" + "Badge Count: 0" )

    }
    
    @IBAction func didTapEvent(_ sender: UIButton) {
        self.eventButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        topbarDelegate?.eventButtonPressed()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    @IBAction func didTapNotification(_ sender: UIButton) {
        self.notificationButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        topbarDelegate?.notificationbuttonPressed()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @IBAction func didTapProfile(_ sender: UIButton) {
        self.profileButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        topbarDelegate?.profileButtonPressed()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @IBAction func didTapMenu(_ sender: UIButton) {
        self.menuButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        topbarDelegate?.menuButtonPressed()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @IBAction func didTapBack(_ sender: UIButton) {
        self.backButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        topbarDelegate?.backButtonPressed()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    //MARK: Touch Down Actions
    @IBAction func backButtonTouchDown(_ sender: UIButton) {
        self.backButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @IBAction func eventButtonTouchDown(_ sender: UIButton) {
        self.eventButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @IBAction func notificationButtonTouchDown(_ sender: UIButton) {
        self.notificationButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @IBAction func profileButtonTouchDown(_ sender: UIButton) {
        self.profileButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @IBAction func menuButtonTouchDown(_ sender: UIButton) {
        self.menuButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
}
