//
//  UserInfo.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 05/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import Foundation

class UserInfo: NSObject {
    var username = ""
    var password = ""
    var id = ""
    var anonymousUserId = ""
    var name = ""
    var email = ""
    var phone = ""
    var nationality = ""
    var subscriptionArticle:SubscriptionArticle? = SubscriptionArticle()
    var currentSubscribtion = Subscription()
    var isSubscribed = false
    var isLoggedIn = false
}
