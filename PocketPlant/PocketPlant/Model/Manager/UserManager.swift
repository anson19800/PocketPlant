//
//  UserManager.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/3.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class UserManager {
    
    static let shared = UserManager()
    
    var userName: String = "使用者"
    
    private init() {}
    
    let userID: String = {
        
        if let user = Auth.auth().currentUser {
            return user.uid
        } else {
            return "0"
        }
    }()
    
    let userDisplayName: String = {
        
        if let user = Auth.auth().currentUser,
           let userName = user.displayName {
            return userName
        } else {
            return "使用者"
        }
    }()
    
    private let dataBase = Firestore.firestore()
    
    func createUserInfo() {
        let user = User(userID: userID,
                        name: userDisplayName,
                        userImageURL: nil,
                        representPlamtID: nil,
                        sharePlants: nil,
                        favoriteShop: nil)
        
        let userRef = dataBase.collection("User")
        
        searchUserisExist(userID: userID ) { isExists in
            if !isExists {
                do {
                    
                    try userRef.document(user.userID).setData(from: user)
                    
                } catch {
                    
                    print("Fail to create user.")
                }
            }
        }
    }
    
    func searchUserisExist(userID: String, isExists: @escaping (Bool) -> Void) {
        
        let userRef = dataBase.collection("User")
        
        userRef.document(userID).getDocument { document, _ in
            if let document = document {
                
                if document.exists {
                    
                    isExists(true)
                    
                } else {
                    
                    isExists(false)
                }
                
            } else {
                
                isExists(false)
            }
        }
    }
    
}
