//
//  LoadingView.swift
//  QatarMuseum
//
//  Created by Exalture on 07/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit
@objc protocol LoadingViewProtocol {
    func tryAgainButtonPressed()
}
class LoadingView: UIView {

    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var oopsLabel: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var noNetworkText: UITextView!
    
    var isNoDataDisplayed : Bool = false
    var noDataFontSize =  CGFloat()
    var loadingViewDelegate : LoadingViewProtocol?
    override func awakeFromNib()
    {
        loadView()
        backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadView()
    }
    private func commonInit()
    {
        Bundle.main.loadNibNamed("LoadingXib", owner: self, options: nil)
        addSubview(loadingView)
        loadingView.frame = self.bounds
       self.backgroundColor = UIColor.loadingViewGray
       // loadingView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        noDataLabel.font = UIFont.closeButtonFont
        
    }
    
    fileprivate func loadView() {
        if loadingView == nil {
            loadingView = Bundle.main.loadNibNamed("LoadingXib", owner: self, options: nil)![0] as! UIView
            loadingView.frame = self.bounds
            loadingView.translatesAutoresizingMaskIntoConstraints = false
            self.backgroundColor = UIColor.loadingViewGray
            self.addSubview(loadingView)
            let constrants = wk_getLayouts()
            self.addConstraints(constrants.0)
            self.addConstraints(constrants.1)
        }
        //self.userInteractionEnabled = false
    }
    
    fileprivate func wk_getLayouts()->(Array<NSLayoutConstraint>,Array<NSLayoutConstraint>) {
        let hConstaints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["view" : loadingView])
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["view" : loadingView])
        return (hConstaints,vConstraints)
    }
    
    func showLoading() {
        // self.isHidden = false
        self.noDataLabel.isHidden = true
        oopsLabel.isHidden = true
        tryAgainButton.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        oopsLabel.isHidden = true
        noNetworkText.isHidden = true
        tryAgainButton.isHidden = true
    }
    
    func stopLoading() {
        self.isNoDataDisplayed = true
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
        oopsLabel.isHidden = true
        noNetworkText.isHidden = true
        tryAgainButton.isHidden = true
    }
    
    func showNoDataView() {
        self.isNoDataDisplayed = true
        //self.isHidden = false
        self.oopsLabel.isHidden = true
        self.noNetworkText.isHidden = true
        self.tryAgainButton.isHidden = true
        let noDataText = NSLocalizedString("NO_RESULT_MESSAGE", comment: "No result message")
        self.noDataLabel.font = UIFont.closeButtonFont
        self.noDataLabel.text = noDataText
        self.noDataView.isHidden = false
        self.noDataView.backgroundColor = UIColor.noDataViewGray
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.noDataLabel.isHidden = false
    }
    
    func showYetNoNotificationDataView() {
        self.isNoDataDisplayed = true
        self.oopsLabel.isHidden = true
        self.noNetworkText.isHidden = true
        self.tryAgainButton.isHidden = true
        let noDataText = NSLocalizedString("YET_NO_NOTIFICATION_MESSAGE", comment: "Yet no notification message")
        self.noDataLabel.font = UIFont.closeButtonFont
        self.noDataLabel.text = noDataText
        self.noDataView.isHidden = false
        self.noDataView.backgroundColor = UIColor.noDataViewGray
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.noDataLabel.isHidden = false
    }
    
    func hideNoDataView() {
        self.isNoDataDisplayed = false
        //self.isHidden = true
        self.noDataView.isHidden = true
        //self.activityIndicatorControl.stopAnimating()
        self.noDataLabel.isHidden = true
        self.noNetworkText.isHidden = true
        self.oopsLabel.isHidden = true
        self.tryAgainButton.isHidden = true
    }
    func showNoNetworkView()  {
        let nonetworkMsg = NSLocalizedString("NO_INTERNET", comment: "NO_INTERNET message") + "\n" + NSLocalizedString("CHECK_INTERNET", comment: "CHECK_INTERNET message")
        self.oopsLabel.text = NSLocalizedString("OOPS_MESSAGE", comment: "OOPS_MESSAGE")
        self.tryAgainButton.setTitle(NSLocalizedString("TRY_AGAIN", comment: "TRY_AGAIN message"), for: .normal)
        self.noNetworkText.text = nonetworkMsg
        self.noDataView.isHidden = false
        self.noDataView.backgroundColor = UIColor.noDataViewGray
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.noDataLabel.isHidden = true
        self.noNetworkText.isHidden = false
        self.oopsLabel.isHidden = false
        self.tryAgainButton.isHidden = false
        self.noNetworkText.font = UIFont.heritageTitleFont
        self.oopsLabel.font = UIFont.oopsTitleFont
        self.tryAgainButton.titleLabel?.font = UIFont.tryAgainFont
        self.tryAgainButton.layer.cornerRadius = 24
    }
    @IBAction func didTapTryAgain(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.2,
                         animations: {
                            self.tryAgainButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.1, animations: {
                                self.tryAgainButton.transform = CGAffineTransform.identity
                                
                            })
                            self.loadingViewDelegate?.tryAgainButtonPressed()
        })
        
    }
    @IBAction func tryAgainButtonTouchDown(_ sender: UIButton) {
    }
    
    
}
