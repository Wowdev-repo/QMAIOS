//
//  HeritageTableViewCell.swift
//  QatarMuseums
//
//  Created by Exalture on 21/06/18.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Alamofire
import Kingfisher
import UIKit
import CocoaLumberjack

class HeritageTableViewCell: UITableViewCell {

    @IBOutlet weak var heritageImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var lineLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var titleBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tourGuideImage: UIImageView!
    let networkReachability = NetworkReachabilityManager()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setGradientLayer()
    }
    override func awakeFromNib() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            titleLabel.textAlignment = .left
            subTitle.textAlignment = .left
        } else {
            titleLabel.textAlignment = .right
            subTitle.textAlignment = .right
        }
    }
    //MARK: HeritageList data
    func setHeritageListCellValues(heritageList: Heritage) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        titleLabel.text = heritageList.name?.uppercased()
        lineLabel.isHidden = true
        //lineLabelHeight.constant = 2
        titleBottomConstraint.constant = 2
        
        if (heritageList.isFavourite == true)  {
            favouriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
        }
        else {
            favouriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
        }
        
        if let imageUrl = heritageList.image{
            heritageImageView.kf.setImage(with: URL(string: imageUrl))
        }
        if (heritageImageView.image == nil) {
            heritageImageView.image = UIImage(named: "default_imageX2")
        }
        titleLabel.font = UIFont.heritageTitleFont
        subTitle.font = UIFont.heritageTitleFont
    }
    
    //MARK: Public Arts List Data
    func setPublicArtsListCellValues(publicArtsList: PublicArtsList) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        titleLabel.text = publicArtsList.name?.uppercased()
        lineLabelHeight.constant = 0
        lineLabel.isHidden = true
        titleBottomConstraint.constant = 0
        
        
        //subTitle.text = (cellValues.value(forKey: "title") as? String)?.uppercased()
        //titleLabel.isHidden = true
        // subLabelHeight.constant = 0
        
        
        if (publicArtsList.isFavourite == true) {
            favouriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
        }
        else {
            favouriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
        }
        if let imageUrl = publicArtsList.image {
            heritageImageView.kf.setImage(with: URL(string: imageUrl))
        }
        if (heritageImageView.image == nil) {
            heritageImageView.image = UIImage(named: "default_imageX2")
        }
        titleLabel.font = UIFont.heritageTitleFont
        subTitle.font = UIFont.heritageTitleFont
    }
    
    //MARK: Collections List Data
    func setCollectionsCellValues(collectionList: Collection) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        titleLabel.text = collectionList.name?.uppercased().replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        lineLabelHeight.constant = 0
        lineLabel.isHidden = true
        titleBottomConstraint.constant = 0
        // subLabelHeight.constant = 0
        favouriteButton.isHidden = true
        if let imageUrl = collectionList.image {
            heritageImageView.kf.setImage(with: URL(string: imageUrl))
        }
        if (heritageImageView.image == nil) {
            heritageImageView.image = UIImage(named: "default_imageX2")
        }
        titleLabel.font = UIFont.heritageTitleFont
        
    }
    
    //MARK: Dining List Data
    func setDiningListValues(diningList: Dining) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        titleLabel.text = diningList.name?.uppercased()
        lineLabelHeight.constant = 0
        lineLabel.isHidden = true
        titleBottomConstraint.constant = 0
        subTitle.isHidden = true
        if let imageUrl = diningList.image{
            heritageImageView.kf.setImage(with: URL(string: imageUrl))
        }
        if (heritageImageView.image == nil) {
            heritageImageView.image = UIImage(named: "default_imageX2")
        }
        titleLabel.font = UIFont.heritageTitleFont
    }
    func setScienceTourGuideCellData(homeCellData: TourGuide) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        subTitle.font = UIFont.homeTitleFont
        subTitle.text = homeCellData.title
        tourGuideImage.isHidden = false
        if (homeCellData.nid == "12216") || (homeCellData.nid == "12226") {
            tourGuideImage.isHidden = true
        } else {
            tourGuideImage.isHidden = false
        }
        if let multimedia = homeCellData.multimediaFile{
            if (multimedia.count > 0) {
                if (homeCellData.multimediaFile![0] != nil) {
                    heritageImageView.kf.setImage(with: URL(string: homeCellData.multimediaFile![0]))
                }
            }
        }
        if(heritageImageView.image == nil) {
            heritageImageView.image = UIImage(named: "default_imageX2")
        }
        heritageImageView.contentMode = .scaleAspectFill
        
    }
    func setGradientLayer() {
        self.heritageImageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let width = self.bounds.width
        let height = self.bounds.height
        let sHeight:CGFloat = 60.0
        let shadow = UIColor.black.withAlphaComponent(0.8).cgColor
        let bottomImageGradient = CAGradientLayer()
        bottomImageGradient.frame = CGRect(x: 0, y: height - sHeight, width: width, height: sHeight)
        bottomImageGradient.colors = [UIColor.clear.cgColor, shadow]
        heritageImageView.layer.insertSublayer(bottomImageGradient, at: 0)
    }

}
