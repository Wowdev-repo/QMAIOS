//
//  Singleton.swift
//  QMLibPreProduction
//
//  Created by Jeeva.S.K on 18/02/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import Foundation

final class QMTLSingleton{
    static let sharedInstance = QMTLSingleton()
    var baseURL = ""
    let bundle = Bundle(identifier: QMTLConstants.lib.bundleId)
    var userInfo = UserInfo()
    var ticketInfo = TicketInfo()
    var memberShipInfo = TicketInfo()
    var subscriptionArticle = SubscriptionArticle()
    
    var listCountriesArr = [CountryList]()
    var listPersonTitlesArr = [ListPersonTitles]()
    
    var initialViewControllerToCall = ""
    var isGuestCheckout = false

    private init() {}
}
