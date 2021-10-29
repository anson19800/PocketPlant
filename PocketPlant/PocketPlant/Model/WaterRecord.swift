//
//  WaterRecord.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/22.
//

import Foundation

enum RecordType: String{
    case water = "澆水"
    case fertilizer = "施肥"
    case soil = "補土"
}

struct WaterRecord: Codable {
    
    let id: String
    let plantID: String
    let waterDate: TimeInterval
}
