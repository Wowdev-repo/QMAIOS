//
//  TicketInfo.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 06/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import Foundation

class TicketInfo: NSObject {

    var division = Divisions()
    var expositions = Exposition()
    var expositionPeriod = ExpositionPeriods()
    var prices = [PriceItem]()
    var lockBasket = LockBasket()
    var date = Date()
    var paymentId = ""
    var isCartContainsItem = false
}
