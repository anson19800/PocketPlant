//
//  CommentManager.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/31.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class CommentManager {
    
    static let shared = CommentManager()
    
    private let dataBase = Firestore.firestore()
    
    func publishComment(comment: Comment, isSuccess: (Bool) -> Void) {
        
        let commentRef = dataBase.collection("comment")
        
        let documentID = commentRef.document().documentID
        
        var uploadComment = comment
        
        uploadComment.id = documentID
        
        do {
            
            try commentRef.document(documentID).setData(from: uploadComment)
            
            isSuccess(true)
            
        } catch {
            
            isSuccess(false)
        }
    }
    
    func fetchComment(type: CommentType,
                      objectID: String,
                      completion: @escaping (Result<[Comment], Error>) -> Void) {
        
        dataBase.collection("comment")
            .whereField("objectID", isEqualTo: objectID)
            .order(by: "createdTime", descending: true)
            .getDocuments { snapshot, error in
                
            if let error = error {
                completion(Result.failure(error))
            }
            
            guard let snapshot = snapshot else { return }
            
            let comments = snapshot.documents.compactMap { snapshot in
                try? snapshot.data(as: Comment.self)
            }
            
            completion(Result.success(comments))
        }
    }
}
