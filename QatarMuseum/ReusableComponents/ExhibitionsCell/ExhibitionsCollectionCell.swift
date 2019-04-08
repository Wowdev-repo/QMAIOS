//
//  ExhibitionsCollectionCell.swift
//  QatarMuseum
//
//  Created by Exalture on 10/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Kingfisher
import UIKit

class ExhibitionsCollectionCell: UITableViewCell {
    @IBOutlet weak var exhibitionImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var openCloseView: UIView!
    @IBOutlet weak var openCloseLabel: UILabel!
    @IBOutlet weak var fullDateLabel: UILabel!
    @IBOutlet weak var tourGuideImage: UIImageView!
    
    var isFavourite : Bool = false
    var exhibitionCellItemBtnTapAction : (()->())?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setGradientLayer()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            titleLabel.textAlignment = .left
            dateLabel.textAlignment = .left
            addressLabel.textAlignment = .left
            fullDateLabel.textAlignment = .left
        } else {
            titleLabel.textAlignment = .right
            dateLabel.textAlignment = .right
            addressLabel.textAlignment = .right
            fullDateLabel.textAlignment = .right
        }
    }
    //MARK: HomeExhibitionList data
    func setExhibitionCellValues(exhibition: Exhibition) {
        openCloseView.layer.cornerRadius = 12
        titleLabel.text = exhibition.name?.uppercased()
        //Hide Date and Location from Exhibition List page.
//        dateLabel.text = ((exhibition.startDate?.uppercased())!).replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) + " - " + ((exhibition.endDate?.uppercased())!).replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        //addressLabel.text = exhibition.location?.uppercased()
        
        dateLabel.text = exhibition.displayDate
        titleLabel.font = UIFont.heritageTitleFont
        dateLabel.font = UIFont.downloadLabelFont
        addressLabel.font = UIFont.exhibitionDateLabelFont
        if (exhibition.isFavourite == true) {
            favouriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
        } else {
            favouriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
        }
        openCloseView.isHidden = false
        openCloseLabel.isHidden = false
        openCloseLabel.font = UIFont.closeButtonFont
        let nowOpenString = NSLocalizedString("NOW_OPEN_TITLE", comment: "NOW_OPEN_TITLE in the exhibition page")
        if (exhibition.status?.lowercased() == nowOpenString.lowercased())  {
            openCloseView.backgroundColor = UIColor.yellow
            openCloseLabel.text = exhibition.status
            openCloseLabel.textColor = UIColor.black
        } else {
            openCloseView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.45)
            openCloseLabel.text = exhibition.status
            openCloseLabel.textColor = UIColor.white
        }
        if let imageUrl = exhibition.image {
            exhibitionImageView.kf.setImage(with: URL(string: imageUrl))
        }
        if (exhibitionImageView.image == nil) {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
    }
    
    //MARK: MuseumExhibitionList data
    func setMuseumExhibitionCellValues(exhibition: Exhibition) {
        openCloseView.layer.cornerRadius = 12
        titleLabel.text = exhibition.name?.uppercased()
        dateLabel.text = ((exhibition.startDate?.uppercased())!).replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) + " - " + ((exhibition.endDate?.uppercased())!).replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        addressLabel.text = exhibition.location?.uppercased()
        titleLabel.font = UIFont.heritageTitleFont
        dateLabel.font = UIFont.downloadLabelFont
        addressLabel.font = UIFont.exhibitionDateLabelFont
        if (exhibition.isFavourite == true) {
            favouriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
        } else {
            favouriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
        }
        let nowOpenString = NSLocalizedString("NOW_OPEN_TITLE", comment: "NOW_OPEN_TITLE in the exhibition page")
        if (exhibition.status?.lowercased() == nowOpenString.lowercased()) {
            openCloseView.backgroundColor = UIColor.yellow
            openCloseLabel.text = exhibition.status
            openCloseLabel.textColor = UIColor.black
        } else {
            openCloseView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.45)
            openCloseLabel.text = exhibition.status
            openCloseLabel.textColor = UIColor.white
        }
        if let imageUrl = exhibition.image {
            // exhibitionImageView.kf.indicatorType = .activity
            exhibitionImageView.kf.setImage(with: URL(string: imageUrl))
        }
        if (exhibitionImageView.image == nil) {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
    }
    
    
    //NMoQ Tour
    func setTourMiddleDate(tourList: NMoQTourDetail?) {
        dateLabel.font  = UIFont.homeTitleFont
        dateLabel.text = tourList?.title?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        titleLabel.isHidden = true
        dateLabel.isHidden = false
        fullDateLabel.isHidden = true
        //dayLabel.text = tourList?.title
        //dateLabel.text = changeDateFormat(dateString: tourList?.eventDate)
        
        if ((tourList?.imageBanner?.count)! > 0) {
            if let imageUrl = tourList?.imageBanner![0]{
                exhibitionImageView.kf.setImage(with: URL(string: imageUrl))
            }
        } else {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
        if (exhibitionImageView.image == nil) {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
    }
    //MARK: Facilities
    func setFacilitiesDetail(FacilitiesDetailData: FacilitiesDetail?) {
        dateLabel.font  = UIFont.homeTitleFont
        dateLabel.text = FacilitiesDetailData?.title?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        titleLabel.isHidden = true
        dateLabel.isHidden = false
        fullDateLabel.isHidden = true
        
        
        if ((FacilitiesDetailData?.images?.count)! > 0) {
            if let imageUrl = FacilitiesDetailData?.images![0]{
                exhibitionImageView.kf.setImage(with: URL(string: imageUrl))
            }
        } else {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
        if (exhibitionImageView.image == nil) {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
    }
    //MARK: TourList
    func setTourListDate(tourList: NMoQTour?,isTour: Bool?) {
        titleLabel.font = UIFont.homeTitleFont
        dateLabel.font  = UIFont.homeTitleFont
        fullDateLabel.font = UIFont.sideMenuLabelFont
        titleLabel.text = tourList?.subtitle
        dateLabel.text = tourList?.title
        if (isTour)! {
            fullDateLabel.text = changeDateFormat(dateString: tourList?.eventDate)
        } else {
            fullDateLabel.isHidden = true
        }
        
        
        if ((tourList?.images?.count)! > 0) {
            if let imageUrl = tourList?.images![0]{
                exhibitionImageView.kf.setImage(with: URL(string: imageUrl))
            }
        } else {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
        if (exhibitionImageView.image == nil) {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            titleLabel.textAlignment = .left
            dateLabel.textAlignment = .left
            fullDateLabel.textAlignment = .left
        } else {
            titleLabel.textAlignment = .right
            dateLabel.textAlignment = .right
            fullDateLabel.textAlignment = .right
        }
    }
    //MARK: ActivityList
    func setActivityListDate(activityList: NMoQActivitiesList?) {
        titleLabel.font = UIFont.homeTitleFont
        dateLabel.font  = UIFont.settingsUpdateLabelFont
        titleLabel.text = activityList?.subtitle
        dateLabel.text = activityList?.title
        fullDateLabel.isHidden = true
        if ((activityList?.images?.count)! > 0) {
            if let imageUrl = activityList?.images![0]{
                exhibitionImageView.kf.setImage(with: URL(string: imageUrl))
            }
        } else {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
        if (exhibitionImageView.image == nil) {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            titleLabel.textAlignment = .left
            dateLabel.textAlignment = .left
            fullDateLabel.textAlignment = .left
        } else {
            titleLabel.textAlignment = .right
            dateLabel.textAlignment = .right
            fullDateLabel.textAlignment = .right
        }
    }
    //MARK: TravelList
    func setTravelListData(travelListData: HomeBanner) {
        dateLabel.font = UIFont.homeTitleFont
        dateLabel.text = travelListData.title
        titleLabel.isHidden = true
        dateLabel.isHidden = false
        fullDateLabel.isHidden = true
        if let imgUrl = travelListData.bannerLink {
            exhibitionImageView.kf.setImage(with: URL(string: imgUrl))
            if(imgUrl == "") {
                exhibitionImageView.image = UIImage(named: "default_imageX2")
            }
        } else {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
    }
    //MARK: Facilities List
    func setFacilitiesListData(facilitiesListData: Facilities?) {
        dateLabel.font = UIFont.homeTitleFont
        dateLabel.text = facilitiesListData!.title!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "&amp;", with: "&", options: .regularExpression, range: nil)
        titleLabel.isHidden = true
        dateLabel.isHidden = false
        fullDateLabel.isHidden = true
        if ((facilitiesListData?.images?.count)! > 0) {
            if let imageUrl = facilitiesListData?.images![0]{
                exhibitionImageView.kf.setImage(with: URL(string: imageUrl))
            }
        } else {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
        if (exhibitionImageView.image == nil) {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
    }
    //MARK: ParkList
    func setParkListData(parkList: NMoQPark) {
        titleLabel.font = UIFont.homeTitleFont
        titleLabel.text = parkList.title?.htmlString
        //?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        fullDateLabel.isHidden = true
        if ((parkList.images?.count)! > 0) {
            if let imageUrl = parkList.images?[0]{
                exhibitionImageView.kf.setImage(with: URL(string: imageUrl))
            }
        } else {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
        if (exhibitionImageView.image == nil) {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            titleLabel.textAlignment = .left
            dateLabel.textAlignment = .left
            fullDateLabel.textAlignment = .left
        } else {
            titleLabel.textAlignment = .right
            dateLabel.textAlignment = .right
            fullDateLabel.textAlignment = .right
        }
    }
    //MARK: HeritageList data
    func setHeritageListCellValues(heritageList: Heritage) {
        dateLabel.text = heritageList.name?.uppercased()
        if (heritageList.isFavourite == true)  {
            favouriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
        }
        else {
            favouriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
        }
        
        if let imageUrl = heritageList.image{
            exhibitionImageView.kf.setImage(with: URL(string: imageUrl))
        }
        if (exhibitionImageView.image == nil) {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
        titleLabel.font = UIFont.heritageTitleFont
        dateLabel.font = UIFont.heritageTitleFont
    }
    //MARK: Public Arts List Data
    func setPublicArtsListCellValues(publicArtsList: PublicArtsList) {
        dateLabel.text = publicArtsList.name?.uppercased()
        if (publicArtsList.isFavourite == true) {
            favouriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
        }
        else {
            favouriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
        }
        if let imageUrl = publicArtsList.image {
            exhibitionImageView.kf.setImage(with: URL(string: imageUrl))
        }
        if (exhibitionImageView.image == nil) {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
        titleLabel.font = UIFont.heritageTitleFont
        dateLabel.font = UIFont.heritageTitleFont
    }
    //MARK: Collections List Data
    func setCollectionsCellValues(collectionList: Collection) {
        dateLabel.text = collectionList.name?.uppercased().replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        favouriteButton.isHidden = true
        if let imageUrl = collectionList.image {
            exhibitionImageView.kf.setImage(with: URL(string: imageUrl))
        }
        if (exhibitionImageView.image == nil) {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
        dateLabel.font = UIFont.heritageTitleFont
        
    }
    //MARK: Dining List Data
    func setDiningListValues(diningList: Dining) {
        dateLabel.text = diningList.name?.uppercased()
        if let imageUrl = diningList.image{
            exhibitionImageView.kf.setImage(with: URL(string: imageUrl))
        }
        if (exhibitionImageView.image == nil) {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
        dateLabel.font = UIFont.heritageTitleFont
    }
    //MARK: ScienceTour Data
    func setScienceTourGuideCellData(homeCellData: TourGuide) {
        dateLabel.font = UIFont.homeTitleFont
        dateLabel.text = homeCellData.title
        if (homeCellData.nid == "12216") || (homeCellData.nid == "12226") {
            tourGuideImage.isHidden = true
        } else {
            tourGuideImage.isHidden = false
        }
        if let multimedia = homeCellData.multimediaFile{
            if (multimedia.count > 0) {
                if (homeCellData.multimediaFile![0] != nil) {
                    exhibitionImageView.kf.setImage(with: URL(string: homeCellData.multimediaFile![0]))
                }
            }
        }
        if(exhibitionImageView.image == nil) {
            exhibitionImageView.image = UIImage(named: "default_imageX2")
        }
        exhibitionImageView.contentMode = .scaleAspectFill
        
    }
    func setGradientLayer() {
        self.exhibitionImageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let width = self.bounds.width
        let height = self.bounds.height
        let sHeight:CGFloat = 110.0
        let shadow = UIColor.black.withAlphaComponent(0.8).cgColor
        
        let bottomImageGradient = CAGradientLayer()
        bottomImageGradient.frame = CGRect(x: 0, y: height - sHeight, width: width, height: sHeight)
        bottomImageGradient.colors = [UIColor.clear.cgColor, shadow]
        exhibitionImageView.layer.insertSublayer(bottomImageGradient, at: 0)
    }
    @IBAction func didTapExhibitionCellButton(_ sender: UIButton) {
        exhibitionCellItemBtnTapAction?()
        self.favouriteButton.transform = CGAffineTransform(scaleX:1, y: 1)
    }
    
    @IBAction func favoriteTouchDownPressed(_ sender: UIButton) {
        self.favouriteButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        if (isFavourite) {
            favouriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
            isFavourite = false
        } else {
            favouriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
            isFavourite = true
        }
    }
    
    
}
