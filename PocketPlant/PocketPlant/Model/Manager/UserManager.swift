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
    
    var currentUser: User?
    
    private init() {}
    
    private let dataBase = Firestore.firestore()
    
    func createUserInfo(name: String, imageURL: String?, imageID: String?, completion: @escaping (_ isSuccess: Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let userID = currentUser.uid
        let user = User(userID: userID,
                        name: name,
                        userImageURL: imageURL,
                        userImageID: imageID,
                        sharePlants: nil,
                        favoriteShop: nil)
        
        let userRef = dataBase.collection(FirebaseCollectionList.user)
        
        searchUserIsExist(userID: userID ) { isExists in
            if !isExists {
                do {
                    
                    try userRef.document(user.userID).setData(from: user)
                    
                    self.currentUser = user
                    
                    completion(true)
                    
                } catch {
                    
                    completion(false)
                    print("Fail to create user.")
                }
            }
        }
    }
    
    func updateUserInfo(userName: String?,
                        userImageID: String?,
                        userImageURL: String?,
                        completion: @escaping (_ isSuccess: Bool) -> Void) {
        
        let userRef = dataBase.collection(FirebaseCollectionList.user)
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let userID = currentUser.uid
        
        userRef.document(userID).getDocument { document, error in
            if error != nil {
                completion(false)
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
                
                self.currentUser = user
                
                try userRef.document(userID).setData(from: user)
                
                completion(true)
                
            } catch {
                
                completion(false)
            }
        }
    }
    
    func addBlockedUser(blockedID: String, completion: @escaping (_ isSuccess: Bool) -> Void) {
        let userRef = dataBase.collection(FirebaseCollectionList.user)
        
        guard let userID = currentUser?.userID else { return }
        
        userRef.document(userID).getDocument { document, error in
            
            if error != nil {
                completion(false)
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
                
                self.currentUser = user
                
                try userRef.document(user.userID).setData(from: user)
                
                completion(true)
                
            } catch {
                
                completion(false)
            }
        }
    }
    
    func searchUserIsExist(userID: String, completion: @escaping (_ isExist: Bool) -> Void) {
        
        let userRef = dataBase.collection(FirebaseCollectionList.user)
        
        userRef.document(userID).getDocument { document, _ in
            if let document = document {
                
                if document.exists {
                    
                    completion(true)
                    
                } else {
                    
                    completion(false)
                }
                
            } else {
                
                completion(false)
            }
        }
    }
    
    func fetchUserInfo(userID: String, completion: @escaping (Result<User, Error>) -> Void) {
        
        let userRef = dataBase.collection(FirebaseCollectionList.user)
        
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
        
        let userRef = dataBase.collection(FirebaseCollectionList.user)
        
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
            
            self.currentUser = user
            
            completion(Result.success(user))
        }
    }
    
    func addSharePlant(plantID: String, completion: @escaping (_ isSuccess: Bool) -> Void) {
        
        let userRef = dataBase.collection(FirebaseCollectionList.user)
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let userID = currentUser.uid
        
        userRef.document(userID).getDocument { document, error in
            
            if error != nil {
                
                completion(false)
                
            } else if let document = document,
                      document.exists {
                
                do {
                    
                    guard var user = try document.data(as: User.self)
                    else {
                        completion(false)
                        return
                    }
                    
                    if var sharePlants = user.sharePlants {
                        sharePlants.append(plantID)
                        user.sharePlants = sharePlants
                    } else {
                        user.sharePlants = [plantID]
                    }
                    
                    self.currentUser = user
                    
                    try userRef.document(userID).setData(from: user)
                    completion(true)
                
                } catch {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    func deleteSharePlant(sharePlants: [String], completion: (_ isSuccess: Bool) -> Void) {
        guard var currentUser = currentUser else {
            return
        }
        
        currentUser.sharePlants = sharePlants
        
        self.currentUser = currentUser
        
        let userRef = dataBase.collection(FirebaseCollectionList.user)
        
        let userID = currentUser.userID
        
        do {
            
            try userRef.document(userID).setData(from: currentUser)
            
            completion(true)
            
        } catch {
            
            completion(false)
        }
    }
    
    func deleteBlockedUser(blockedUserID: String, completion: (_ isSuccess: Bool) -> Void) {
        
        guard var blockedUsersID = self.currentUser?.blockedUserID,
              var currentUser = self.currentUser else {
            completion(false)
            return
        }
        
        blockedUsersID.removeAll { userID -> Bool in
            return userID == blockedUserID
        }
        
        currentUser.blockedUserID = blockedUsersID
        
        self.currentUser = currentUser
        
        let userRef = dataBase.collection(FirebaseCollectionList.user)
        
        do {
        
            try userRef.document(currentUser.userID).setData(from: currentUser)
            
            completion(true)
            
        } catch {
            
            completion(false)
        }
    }
}
