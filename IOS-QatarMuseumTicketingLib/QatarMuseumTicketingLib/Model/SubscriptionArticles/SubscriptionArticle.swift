//
//  SubscriptionArticle.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 12/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import Foundation

class SubscriptionArticle: NSObject {
    var id = ""
    var name = ""
    var imgUrl = ""
    var code = ""
    var price = 0
    var prices = [PriceItem]()
    var durationInMonths = 0
    var cellHeight = 0

}
