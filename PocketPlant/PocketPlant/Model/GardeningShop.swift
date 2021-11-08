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
    let images: [String]?
    
    init(name: String, address: String) {
        self.id = "0"
        self.name = name
        self.address = address
        self.images = nil
    }
}
