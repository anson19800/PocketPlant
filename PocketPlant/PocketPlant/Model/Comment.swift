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
    var id: String
    let commentType: String
    let objectID: String
    let senderID: String
    let content: String
    let createdTime: TimeInterval
    
    init(commentType: CommentType, objectID: String, content: String, createdTime: TimeInterval) {
        self.id = "0"
        self.commentType = commentType.rawValue
        self.objectID = objectID
        self.senderID = UserManager.shared.currentUser?.userID ?? "0"
        self.content = content
        self.createdTime = createdTime
    }
}
