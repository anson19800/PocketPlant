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
    
    var userID: String {
        if let user = Auth.auth().currentUser {
            return user.uid
        } else {
            return "0"
        }
    }
    
    var currentUser: User?
    
    private init() {}
    
    private let dataBase = Firestore.firestore()
    
    func getUserID() -> String {
        if let user = Auth.auth().currentUser {
            return user.uid
        } else {
            return "0"
        }
    }
    
    func createUserInfo(name: String, imageURL: String?, imageID: String?) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let userID = currentUser.uid
        let user = User(userID: userID,
                        name: name,
                        userImageURL: imageURL,
                        userImageID: imageID,
                        sharePlants: nil,
                        favoriteShop: nil)
        
        let userRef = dataBase.collection("User")
        
        searchUserisExist(userID: userID ) { isExists in
            if !isExists {
                do {
                    
                    try userRef.document(user.userID).setData(from: user)
                    
                    self.currentUser = user
                    
                } catch {
                    
                    print("Fail to create user.")
                }
            }
        }
    }
    
    func updateUserInfo(userName: String?,
                        userImageID: String?,
                        userImageURL: String?,
                        isSuccess: @escaping (Bool) -> Void) {
        
        let userRef = dataBase.collection("User")
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let userID = currentUser.uid
        
        userRef.document(userID).getDocument { document, error in
            if error != nil {
                isSuccess(false)
            }
            
            guard let document = document,
                  document.exists,
            var user = try? document.data(as: User.self)
            else { return }
            
            do {
                
                if let userName = userName {
                    user.name = userName
                }
                
                if let imageID = user.userImageID {
                    ImageManager.shared.deleteImage(imageID: imageID)
                }
                
                if let userImageID = userImageID,
                   let userImageURL = userImageURL {
                    user.userImageID = userImageID
                    user.userImageURL = userImageURL
                }
                
                try userRef.document(userID).setData(from: user)
                
                isSuccess(true)
                
            } catch {
                
                isSuccess(false)
            }
        }
    }
    
    func addBlockedUser(blockedID: String, isSuccess: @escaping (Bool) -> Void) {
        let userRef = dataBase.collection("User")
        
        userRef.document(self.userID).getDocument { document, error in
            
            if error != nil {
                isSuccess(false)
            }
            
            guard let document = document,
                  document.exists,
            var user = try? document.data(as: User.self)
            else { return }
            
            do {
                if user.blockedUserID == nil {
                    
                    user.blockedUserID = [blockedID]
                    
                } else {
                    
                    user.blockedUserID?.append(blockedID)
                    
                }
                
                try userRef.document(self.userID).setData(from: user)
                
                isSuccess(true)
                
            } catch {
                
                isSuccess(false)
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
    
    func fetchUserInfo(userID: String, completion: @escaping (Result<User, Error>) -> Void) {
        
        let userRef = dataBase.collection("User")
        
        userRef.document(userID).getDocument { document, error in
            if let error = error {
                completion(Result.failure(error))
            }
            guard let document = document,
                  document.exists,
                  let user = try? document.data(as: User.self)
            else { return }
            
            completion(Result.success(user))
        }
    }
    
    func fetchCurrentUserInfo(completion: @escaping (Result<User, Error>) -> Void) {
        
        let userRef = dataBase.collection("User")
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let userID = currentUser.uid
        
        userRef.document(userID).getDocument { document, error in
            if let error = error {
                completion(Result.failure(error))
            }
            guard let document = document,
                  document.exists,
                  let user = try? document.data(as: User.self)
            else { return }
            
            completion(Result.success(user))
        }
    }
    
    func addSharePlant(plantID: String, isSuccess: @escaping (Bool) -> Void) {
        
        let userRef = dataBase.collection("User")
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let userID = currentUser.uid
        
        userRef.document(userID).getDocument { document, error in
            
            if error != nil {
                
                isSuccess(false)
                
            } else if let document = document,
                      document.exists {
                
                do {
                    
                    guard var user = try document.data(as: User.self)
                    else {
                        isSuccess(false)
                        return
                    }
                    
                    if var sharePlants = user.sharePlants {
                        sharePlants.append(plantID)
                        user.sharePlants = sharePlants
                    } else {
                        user.sharePlants = [plantID]
                    }
                    
                    try userRef.document(userID).setData(from: user)
                    isSuccess(true)
                
                } catch {
                    isSuccess(false)
                }
            } else {
                isSuccess(false)
            }
            
        }
    }
}
