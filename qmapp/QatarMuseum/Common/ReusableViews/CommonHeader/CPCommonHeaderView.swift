//
//  CPCommonHeaderView.swift
//  QatarMuseum
//
//  Created by Wakralab Software Labs on 07/06/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import UIKit

@objc protocol CPHeaderViewProtocol
{
    func headerCloseButtonPressed()
    @objc optional func filterButtonPressed()
}
class CPCommonHeaderView: UIView {

    @IBOutlet weak var headerBackButton: UIButton!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet var headerView: UIView!
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var logOutLine: UILabel!
    var headerViewDelegate : CPHeaderViewProtocol?
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    private func commonInit()
    {
        Bundle.main.loadNibNamed("CommonHeader", owner: self, options: nil)
        addSubview(headerView)
        headerView.frame = self.bounds
        headerView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        headerTitle.font = UIFont.headerFont
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @IBAction func didTapHeaderClose(_ sender: UIButton) {
        self.headerBackButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        headerViewDelegate?.headerCloseButtonPressed()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @IBAction func headerCloseTouchDown(_ sender: UIButton) {
       self.headerBackButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @IBAction func didTapSettings(_ sender: UIButton) {
        self.settingsButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.headerViewDelegate?.filterButtonPressed!()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @IBAction func settingsButtonTouchDown(_ sender: UIButton) {
        self.settingsButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    
    
}
