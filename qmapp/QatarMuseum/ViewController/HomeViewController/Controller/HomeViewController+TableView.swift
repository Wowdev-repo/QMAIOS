//
//  HomeViewController+TableView.swift
//  QatarMuseums
//
//  Created by Exalture Software Labs on 24/06/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Foundation

extension HomeViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        loadingView.stopLoading()
        loadingView.isHidden = true
        if((UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != nil) && (UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != "")  && (self.homeBannerList.count > 0)) {
            if(indexPath.row == 0) {
                let cell = homeTableView.dequeueReusableCell(withIdentifier: "bannerCellId", for: indexPath) as! NMoQHeaderCell
                cell.setBannerData(bannerData: homeBannerList[0])
                return cell
            } else {
                let cell = homeTableView.dequeueReusableCell(withIdentifier: "commonListCellId", for: indexPath) as! CommonListCell
                cell.setHomeCellData(home: homeList[indexPath.row])
                
                loadingView.stopLoading()
                loadingView.isHidden = true
                return cell
            }
        }else {
            let cell = homeTableView.dequeueReusableCell(withIdentifier: "commonListCellId", for: indexPath) as! CommonListCell
            cell.setHomeCellData(home: homeList[indexPath.row])
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        let panelAndTalks = NSLocalizedString("PANEL_AND_TALKS",comment: "PANEL_AND_TALKS in Home Page")
        if((UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != nil) && (UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != "") && (self.homeBannerList.count > 0)) {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), -- Home Screen banner true")
            
            if(indexPath.row == 0) {
                homePageNameString = HomePageName.bannerMuseumLandingPage
                self.performSegue(withIdentifier: "homeToMuseumLandingSegue", sender: self)
            } else {
                if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
                    DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), lang: \(LocalizationLanguage.currentAppleLanguage())")
                    
                    if (homeList[indexPath.row].id == "12181") {
                        loadExhibitionPage()
                    } else if (homeList[indexPath.row].id == "13976") {
                        loadTourViewPage(nid: "13976", subTitle: panelAndTalks, isFromTour: false)
                    } else {
                        loadMuseumsPage(curretRow: indexPath.row)
                    }
                }
                else {
                    DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), lang: \(LocalizationLanguage.currentAppleLanguage())")
                    if (homeList[indexPath.row].id == "12186") {
                        loadExhibitionPage()
                    } else if (homeList[indexPath.row].id == "15631") {
                        loadTourViewPage(nid: "15631", subTitle: panelAndTalks, isFromTour: false)
                    }
                    else {
                        loadMuseumsPage(curretRow: indexPath.row)
                    }
                }
            }
        } else {
            if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
                DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), lang: \(LocalizationLanguage.currentAppleLanguage())")
                if (homeList[indexPath.row].id == "12181") {
                    loadExhibitionPage()
                } else if (homeList[indexPath.row].id == "13976") {
                    loadTourViewPage(nid: "13976", subTitle: panelAndTalks, isFromTour: false)
                }
                else {
                    loadMuseumsPage(curretRow: indexPath.row)
                }
            }
            else {
                DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), lang: \(LocalizationLanguage.currentAppleLanguage())")
                if (homeList[indexPath.row].id == "12186") {
                    loadExhibitionPage()
                }
                else if (homeList[indexPath.row].id == "15631") {
                    loadTourViewPage(nid: "15631", subTitle: panelAndTalks, isFromTour: false)
                }
                else {
                    loadMuseumsPage(curretRow: indexPath.row)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let heightValue = UIScreen.main.bounds.height/100
        if((UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != nil) && (UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != "")  && (self.homeBannerList.count > 0)) {
            if(indexPath.row == 0) {
                return 120
            } else {
                return heightValue*27
            }
        }
        else {
            return heightValue*27
        }
    }
}
