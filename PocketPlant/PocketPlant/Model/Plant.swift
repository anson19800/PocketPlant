//
//  Plant.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/18.
//

import Foundation
import FirebaseFirestoreSwift

struct Plant: Identifiable, Codable {
    
    var id: String
    let name: String
    let category: String
    let water: Int
    let light: Int
    let temperature: Int
    let humidity: Int
    let buyTime: TimeInterval
    let buyPlace: String
    let buyPrice: Int
    let description: String
    let lastWater: TimeInterval?
    let lastFertilizer: TimeInterval?
    let lastSoil: TimeInterval?
    var favorite: Bool
    let ownerID: Int
    let isPublic: Bool
    var imageURL: String?
}
