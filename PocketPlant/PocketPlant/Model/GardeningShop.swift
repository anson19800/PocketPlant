//
//  GardeningShop.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/30.
//

import Foundation

struct GardeningShop: Codable {
    var id: String?
    let name: String
    let address: String
    let phone: String
    let description: String
    var images: [String]?
    var imagesID: [String]?
    var ownerID: String
    
    init(name: String,
         address: String,
         phone: String = "未知",
         description: String = "沒有備註",
         image: [String]? = nil,
         imageID: [String]? = nil) {
        
        self.id = "0"
        self.name = name
        self.address = address
        self.phone = phone
        self.description = description
        self.images = image
        self.imagesID = imageID
        self.ownerID = UserManager.shared.currentUser?.userID ?? "0"
    }
}
