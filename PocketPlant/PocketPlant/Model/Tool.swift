//
//  Tool.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/10.
//

import Foundation

struct Tool: Codable {
    var id: String
    let name: String
    let stock: Int
    let buyPlace: String
    
    init(id: String = "", name: String, stock: Int = 0, buyPlace: String = "未紀錄") {
        self.id = id
        self.name = name
        self.stock = stock
        self.buyPlace = buyPlace != "" ? buyPlace : "未紀錄"
    }
}
