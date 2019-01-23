//
//  TopBarView.swift
//  QatarMuseum
//
//  Created by Exalture on 06/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit
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
    }

    func updateNotificationBadgeCount() {
        if let badgeCount = UserDefaults.standard.value(forKey: "notificationBadgeCount") as?
            Int {
            badgeLabel.isHidden = false
            badgeLabel.text = "  " + String(badgeCount)
        } else {
            badgeLabel.isHidden = true
        }
    }
    
    @IBAction func didTapEvent(_ sender: UIButton) {
        self.eventButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        topbarDelegate?.eventButtonPressed()
    }
    
    @IBAction func didTapNotification(_ sender: UIButton) {
        self.notificationButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        topbarDelegate?.notificationbuttonPressed()
    }
    @IBAction func didTapProfile(_ sender: UIButton) {
        self.profileButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        topbarDelegate?.profileButtonPressed()
    }
    @IBAction func didTapMenu(_ sender: UIButton) {
        self.menuButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        topbarDelegate?.menuButtonPressed()
    }
    @IBAction func didTapBack(_ sender: UIButton) {
        self.backButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        topbarDelegate?.backButtonPressed()
    }
    //MARK: Touch Down Actions
    @IBAction func backButtonTouchDown(_ sender: UIButton) {
        self.backButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    @IBAction func eventButtonTouchDown(_ sender: UIButton) {
        self.eventButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    @IBAction func notificationButtonTouchDown(_ sender: UIButton) {
        self.notificationButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    @IBAction func profileButtonTouchDown(_ sender: UIButton) {
        self.profileButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    @IBAction func menuButtonTouchDown(_ sender: UIButton) {
        self.menuButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
}
