//
//  CheckoutBasket.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 14/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import Foundation

class CheckoutBasket: NSObject {
    var id = ""
    var isValid = false
    var message = ""
    var resultState = 0
    var salesOrderNumber = ""
    var salesSeriesId = ""
    var salesItem = [SalesItem]()
}
