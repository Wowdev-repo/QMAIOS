//
//  MiaCollectionReusableView.swift
//  QatarMuseums
//
//  Created by Exalture on 17/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit
class MiaCollectionReusableView: UITableViewCell {
    @IBOutlet weak var miaTourGuideText: UILabel!
    @IBOutlet weak var selfGuidedText: UILabel!
    @IBOutlet weak var exploreButton: UIButton!
    @IBOutlet weak var audioCircleImage: UIImageView!
    @IBOutlet weak var selfGuidedTitle: UILabel!
    @IBOutlet weak var exploreButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var miaTitle: UILabel!
    @IBOutlet weak var tourGuideTextBottomConstraint: NSLayoutConstraint!
   // var miaTourDelegate : MiaTourProtocol?
    @IBOutlet weak var tourGuideTextTop: NSLayoutConstraint!
    
    @IBOutlet weak var exploreButtonBottom: NSLayoutConstraint!
    var exploreButtonTapAction : (()->())?
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
    func setNMoQHeaderData() {
        exploreButton.isHidden = true
        miaTourGuideText.isHidden = true
        audioCircleImage.isHidden = true
        exploreButtonHeight.constant = 0
        tourGuideTextBottomConstraint.constant = 0
        tourGuideTextTop.constant = 0
        exploreButtonBottom.constant = 5
        miaTitle.text = NSLocalizedString("NMOQ_TOUR_HEADER", comment: "NMOQ_TOUR_HEADER in TourGuide page")
        selfGuidedTitle.text = NSLocalizedString("SELF_GUIDED_TOUR_TITLE", comment: "SELF_GUIDED_TOUR_TITLE in TourGuide page")
        selfGuidedText.text = NSLocalizedString("SELF_GUIDED_TEXT1", comment: "SELF_GUIDED_TEXT1 in TourGuide page") + "\n" + NSLocalizedString("SELF_GUIDED_TEXT2", comment: "SELF_GUIDED_TEXT2 in TourGuide page")
    }
    func setTourHeader() {
        exploreButton.isHidden = true
        miaTourGuideText.isHidden = true
        audioCircleImage.isHidden = true
        exploreButtonHeight.constant = 0
        tourGuideTextBottomConstraint.constant = 0
        tourGuideTextTop.constant = 0
        exploreButtonBottom.constant = 5
        miaTitle.text = NSLocalizedString("TOUR_GUIDES", comment: "TOUR_GUIDES in TourGuide page")
        selfGuidedText.text = NSLocalizedString("TOUR_GUIDE_TEXT", comment: "TOUR_GUIDE_TEXT in TourGuide page") 
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
                            self.exploreButtonTapAction?()
        })
    }
    
    @IBAction func exploreButtonTouchDown(_ sender: UIButton) {

    }
}
