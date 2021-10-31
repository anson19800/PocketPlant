//
//  Comment.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/31.
//

import Foundation

enum CommentType: String {
    case plant
    case shop
}

struct Comment: Codable {
    let id: String
    let commentType: String
    let objectID: String
    let senderID: String
    let content: String
    let createdTime: TimeInterval
}
