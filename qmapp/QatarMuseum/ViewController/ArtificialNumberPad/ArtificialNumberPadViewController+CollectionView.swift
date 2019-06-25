//
//  ArtificialNumberPadViewController+CollectionView.swift
//  QatarMuseums
//
//  Created by Exalture on 24/06/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Foundation

extension ArtifactNumberPadViewController: UICollectionViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: collectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ArtifactNumberPadCell = numberPadCollectionView.dequeueReusableCell(withReuseIdentifier: "artifactNumberPadCellId", for: indexPath) as! ArtifactNumberPadCell
        // cell.innerView.layer.cornerRadius = (NUMBER_CELL_WIDTH-10)/2
        let cellWidth = numberPadCollectionView.frame.width/3
        let corner = (cellWidth)/2-15
        cell.innerView.layer.cornerRadius = CGFloat(Int(floorf(Float(corner))))
        if (indexPath.row == 11) {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                cell.imageView.image = UIImage(named: "back_mirrorX1")
            } else {
                cell.imageView.image = UIImage(named: "back_buttonX1")
            }
            cell.innerView.backgroundColor = UIColor.viewMycultureBlue
        } else if (indexPath.row == 10) {
            cell.numLabel.text = "0"
        } else if (indexPath.row == 9) {
            cell.imageView.image = UIImage(named: "closeX1")
            cell.innerView.backgroundColor = UIColor.profilePink
        } else {
            cell.numLabel.text = String(indexPath.row + 1)
        }
        
        if (artifactValue == "") {
            if (indexPath.row == 11) {
                cell.innerView.alpha = 0.3
            } else if (indexPath.row == 9) {
                cell.innerView.alpha = 0.3
            }
        }
        loadingView.stopLoading()
        loadingView.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //return CGSize(width: NUMBER_CELL_WIDTH, height: NUMBER_CELL_WIDTH)
        let heightValue = UIScreen.main.bounds.height/100
        return CGSize(width: numberPadCollectionView.frame.width/3-20, height:numberPadCollectionView.frame.width/3-20)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell : ArtifactNumberPadCell = numberPadCollectionView.dequeueReusableCell(withReuseIdentifier: "artifactNumberPadCellId", for: indexPath) as! ArtifactNumberPadCell
        
        if (indexPath.row == 9) {
            artifactTextField.text = ""
            cell.innerView.alpha = 0.3
            disableButtons(collectionView: collectionView)
        } else if (indexPath.row == 11) {
            if artifactValue != "" {
                getObjectDetail()
            }
        } else {
            enableButtons(collectionView: collectionView)
            if (indexPath.row == 10) {
                artifactTextField.text = artifactValue + "0"
            } else {
                artifactTextField.text = artifactValue + String(indexPath.row + 1)
            }
        }
        artifactValue = artifactTextField.text!
    }
    
    func disableButtons(collectionView: UICollectionView) {
        let closeButtonView = collectionView.cellForItem(at: IndexPath(item: 9,
                                                                       section: 0)) as! ArtifactNumberPadCell
        
        closeButtonView.innerView.alpha = 0.3
        let nextButtonView = collectionView.cellForItem(at: IndexPath(item: 11,
                                                                      section: 0)) as! ArtifactNumberPadCell
        nextButtonView.innerView.alpha = 0.3
    }
    
    func enableButtons(collectionView: UICollectionView) {
        let closeButtonView = collectionView.cellForItem(at: IndexPath(item: 9,
                                                                       section: 0)) as! ArtifactNumberPadCell
        
        closeButtonView.innerView.alpha = 1.0
        let nextButtonView = collectionView.cellForItem(at: IndexPath(item: 11,
                                                                      section: 0)) as! ArtifactNumberPadCell
        nextButtonView.innerView.alpha = 1.0
    }
}
