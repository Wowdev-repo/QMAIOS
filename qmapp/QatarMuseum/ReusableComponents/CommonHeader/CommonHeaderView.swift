//
//  CommonHeaderView.swift
//  QatarMuseum
//
//  Created by Exalture on 07/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit
@objc protocol HeaderViewProtocol
{
    func headerCloseButtonPressed()
    @objc optional func filterButtonPressed()
}
class CommonHeaderView: UIView {

    @IBOutlet weak var headerBackButton: UIButton!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet var headerView: UIView!
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var logOutLine: UILabel!
    var headerViewDelegate : HeaderViewProtocol?
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
        
    }
    @IBAction func didTapHeaderClose(_ sender: UIButton) {
        self.headerBackButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        headerViewDelegate?.headerCloseButtonPressed()
    }
    @IBAction func headerCloseTouchDown(_ sender: UIButton) {
       self.headerBackButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    @IBAction func didTapSettings(_ sender: UIButton) {
        self.settingsButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.headerViewDelegate?.filterButtonPressed!()
    }
    @IBAction func settingsButtonTouchDown(_ sender: UIButton) {
        self.settingsButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    
    
}
