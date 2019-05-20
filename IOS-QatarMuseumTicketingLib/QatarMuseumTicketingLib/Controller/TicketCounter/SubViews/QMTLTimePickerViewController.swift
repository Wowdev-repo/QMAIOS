//
//  QMTLTimePickerViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 27/02/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit

class QMTLTimePickerViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    //MARK:- Decleration
    var expositionPeriodsList = [ExpositionPeriods]()

    var isTimePickingCellSelected = false
    
    @IBOutlet weak var timePickerCollectionView: UICollectionView!

    //MARK:- Controller Defaults
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:false)
        self.navigationItem.title = ""
self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
        
        timePickerCollectionView.allowsMultipleSelection = false
        
    }
    
    //MARK:- Collection view data source and delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = 0
        
        switch collectionView {
        case timePickerCollectionView:
            count = expositionPeriodsList.count
            break
        default:
            break
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        switch collectionView {
        case timePickerCollectionView:
            
            let cellID = QMTLConstants.CellId.timePickerCellId
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
            
            cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
            cell.contentView.layer.borderWidth = 0.5
            
            let timeLbl = cell.contentView.viewWithTag(10) as! UILabel
            
            let fromTimeStr = expositionPeriodsList[indexPath.row].from
            let fromTimeSepArr = fromTimeStr.components(separatedBy: "T")
            
            timeLbl.text = fromTimeSepArr[1]
            
            if !isTimePickingCellSelected {
                cell.layer.borderWidth = 0
                cell.layer.borderColor = UIColor.white.cgColor
            }
            
            return cell
            
        default:
            break
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        isTimePickingCellSelected = true
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 2.0
        cell?.layer.borderColor = UIColor.darkGray.cgColor
        
        switch collectionView {
        case timePickerCollectionView:
            break
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0
        cell?.layer.borderColor = UIColor.white.cgColor
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
