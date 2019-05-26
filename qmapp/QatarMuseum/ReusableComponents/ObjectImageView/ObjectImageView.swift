//
//  ObjectImageView.swift
//  QatarMuseums
//
//  Created by Developer on 17/08/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit
import CocoaLumberjack

protocol ObjectImageViewProtocol {
    func dismissImagePopUpView()
}

class ObjectImageView: UIView, UIScrollViewDelegate  {
    @IBOutlet var imageViewPopup: UIView!
    @IBOutlet weak var objectImagePopUpInnerView: UIView!
    @IBOutlet weak var objectImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var objectImageViewDelegate : ObjectImageViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ObjectImageXib", owner: self, options: nil)
        addSubview(imageViewPopup)
        imageViewPopup.frame = self.bounds
        imageViewPopup.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        setUpUI()
    }
    
    func setUpUI() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        closeButton.layer.shadowRadius = 5
        closeButton.layer.shadowOpacity = 1.0
        self.backgroundColor = UIColor.popupBackgroundWhite
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.scrollView.delegate = self
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.flashScrollIndicators()
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 8.0
        
        imageViewPopup.isUserInteractionEnabled = true
        
        objectImageView.isUserInteractionEnabled = true
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(zoomOnDoubleTap))
        tapGesture2.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(tapGesture2)
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return objectImageView
    }
    
    func loadPopup(image : String) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        //objectImageView.image = UIImage(named: image)
        if  image != nil {
            objectImageView.kf.setImage(with: URL(string: image))
        }
    }
    
    @objc func zoomOnDoubleTap() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if (self.scrollView.zoomScale == self.scrollView.maximumZoomScale) {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        } else if(self.scrollView.zoomScale >= 3) {
            self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
        } else {
            self.scrollView.setZoomScale(3, animated: true)
        }
        objectImageView.isUserInteractionEnabled = false
    }
    
    @objc func dismissView() {
        
    }
    @IBAction func didTapCloseButton(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        objectImageViewDelegate?.dismissImagePopUpView()
        self.removeFromSuperview()
    }
    
    
    
}

