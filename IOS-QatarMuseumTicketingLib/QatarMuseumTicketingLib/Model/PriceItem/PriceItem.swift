//
//  PriceItem.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 06/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import Foundation

class PriceItem: NSObject {
    var amount = 0
    var id = ""
    var name = ""
    var code = ""
    var ticketPicked = 00
    var totalAmount = 0
    var isToShowDesc = false
    var ticketCellHeight = 111
    var maxTicketAllowed = 25
    var isUserCanBuyThis = true
    var cantBuyErrMsgStr = ""
}
