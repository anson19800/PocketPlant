//
//  User.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/3.
//

import Foundation

struct User: Codable {
    let userID: String
    var name: String?
    var userImageURL: String?
    var userImageID: String?
    var sharePlants: [String]?
    var favoriteShop: [GardeningShop]?
    var blockedUserID: [String]?
    
}
