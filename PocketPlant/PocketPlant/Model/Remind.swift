//
//  Remind.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/26.
//

import UIKit

struct Remind: Codable, Hashable {
    let plantID: String
    let type: String
    let times: Int
}
