//
//  EventViewController+CollectionView.swift
//  QatarMuseums
//
//  Created by Exalture on 24/06/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Foundation

extension EventViewController: UICollectionViewDelegate,UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    //MARK: CollectionView delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heightValue = UIScreen.main.bounds.height/100
        
        return CGSize(width: eventCollectionView.frame.width, height: heightValue*18)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return educationEventArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : EventCollectionViewCell = eventCollectionView.dequeueReusableCell(withReuseIdentifier: "eventCellId", for: indexPath) as! EventCollectionViewCell
        cell.viewDetailsBtnAction = {
            () in
            self.loadEventPopup(currentRow: indexPath.row)
            
        }
        if (indexPath.row % 2 == 0) {
            cell.cellBackgroundView?.backgroundColor = UIColor.eventCellAshColor
        }
        else {
            cell.cellBackgroundView.backgroundColor = UIColor.whiteColor
        }
        if (isLoadEventPage == true) {
            cell.setEventCellValues(event: educationEventArray[indexPath.row])
        }
        else {
            cell.setEducationCalendarValues(educationEvent: educationEventArray[indexPath.row])
        }
        loadingView.stopLoading()
        loadingView.isHidden = true
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        loadEventPopup(currentRow: indexPath.row)
    }
}
