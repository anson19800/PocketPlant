//
//  WaterRecord.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/22.
//

import Foundation

struct WaterRecord: Codable {
    
    let id: String
    let plantID: String
    let waterDate: TimeInterval
}
