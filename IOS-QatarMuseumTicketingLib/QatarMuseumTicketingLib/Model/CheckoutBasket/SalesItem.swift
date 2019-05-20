//
//  SalesItem.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 14/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import Foundation
import SwiftyJSON

class SalesItem: NSObject {
    var id = ""
    var articleId = ""
    var barcodes = [JSON]()
    var name = ""
    var quantity = 0
    var unitPrice = 0.0
    var salesHeaderID = ""
    var date = ""
    var amount = 0.0
    var salesNumber = ""
}
