//
//  MiaCollectionReusableView.swift
//  QatarMuseums
//
//  Created by Exalture on 17/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit
protocol MiaTourProtocol {
    func exploreButtonTapAction( miaHeader: MiaCollectionReusableView)
}
class MiaCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var miaTourGuideText: UITextView!
    @IBOutlet weak var selfGuidedText: UITextView!
    @IBOutlet weak var exploreButton: UIButton!
    @IBOutlet weak var audioCircleImage: UIImageView!
    @IBOutlet weak var selfGuidedTitle: UILabel!
    
    @IBOutlet weak var miaTitle: UITextView!
    var miaTourDelegate : MiaTourProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        miaTourGuideText.font = UIFont.settingsUpdateLabelFont
        miaTitle.font = UIFont.tourGuidesFont
        exploreButton.titleLabel?.font = UIFont.headerFont
        selfGuidedTitle.font = UIFont.selfGuidedFont
        selfGuidedText.font = UIFont.settingsUpdateLabelFont
        
        
        
    }
    func setHeader() {
        exploreButton.isHidden = false
        miaTitle.text = NSLocalizedString("MIA_TOUR_GUIDE_TITLE", comment: "MIA_TOUR_GUIDE_TITLE in TourGuide page")
        miaTourGuideText.text = NSLocalizedString("TOUR_GUIDE_TEXT", comment: "TOUR_GUIDE_TEXT in TourGuide page")
        exploreButton.setTitle(NSLocalizedString("EXPLORE_BUTTON", comment: "EXPLORE_BUTTON in TourGuide page"), for: .normal)
        selfGuidedTitle.text = NSLocalizedString("SELF_GUIDED_TOUR_TITLE", comment: "SELF_GUIDED_TOUR_TITLE in TourGuide page")
        selfGuidedText.text = NSLocalizedString("SELF_GUIDED_TEXT1", comment: "SELF_GUIDED_TEXT1 in TourGuide page") + "\n" + NSLocalizedString("SELF_GUIDED_TEXT2", comment: "SELF_GUIDED_TEXT2 in TourGuide page")
    }
    
    @IBAction func didTapExplore(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.2,
                         animations: {
                            self.exploreButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.1, animations: {
                                self.exploreButton.transform = CGAffineTransform.identity
                                
                            })
                            self.miaTourDelegate?.exploreButtonTapAction(miaHeader: self)
        })
    }
    
    @IBAction func exploreButtonTouchDown(_ sender: UIButton) {

    }
}
