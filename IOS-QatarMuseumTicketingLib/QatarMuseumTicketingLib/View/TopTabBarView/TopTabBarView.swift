//
//  TopTabBarView.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 11/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit


protocol TopTabBarViewDelegate: class {
    func backBtnSelected()
    func ticketBtnSelected()
    func notificationBtnSelected()
    func myProfileBtnSelected()
    func menuBtnSelected()
}

class TopTabBarView: UIView {

    //MARK:- Decleration
    var topTabBarViewDelegate : TopTabBarViewDelegate?
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var ticketBtn: UIButton!
    @IBOutlet weak var notificationBtn: UIButton!
    @IBOutlet weak var myProfileBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    
    class func instanceFromNib() -> UIView {
        

        
        return UINib(nibName: "TopTabBarView", bundle: QMTLSingleton.sharedInstance.bundle).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    //common func to init our view
    private func setupView() {

    }
    
    //MARK:- IBAction
    
    @IBAction func backBtnAction(_ sender: Any) {
        topTabBarViewDelegate?.backBtnSelected()
    }
    @IBAction func ticketBtnAction(_ sender: Any) {
        topTabBarViewDelegate?.ticketBtnSelected()
    }
    @IBAction func notifBtnAction(_ sender: Any) {
        topTabBarViewDelegate?.notificationBtnSelected()
    }
    @IBAction func myAccBtnAction(_ sender: Any) {
        topTabBarViewDelegate?.myProfileBtnSelected()
    }
    @IBAction func menuBtnAction(_ sender: Any) {
        topTabBarViewDelegate?.menuBtnSelected()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
