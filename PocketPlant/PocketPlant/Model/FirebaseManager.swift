//
//  FirebaseManager.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/18.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private let dataBase = Firestore.firestore()
    
    func uploadPlant(plant: inout Plant, image: UIImage, isSuccess: @escaping (Bool) -> Void) {
        
        let plantRef = dataBase.collection("plant")
        
        let documentID = plantRef.document().documentID
        
        var uploadPlant = plant
        
        uploadPlant.id = documentID
        
        uploadImageToGetURL(image: image) { result in
            
            switch result {
                
            case .success(let (uuid, urlString)):
                
                uploadPlant.imageURL = urlString
                
                uploadPlant.imageID = uuid
                
                do {
                    
                    try plantRef.document(documentID).setData(from: uploadPlant)
                    
                    isSuccess(true)
                    
                } catch {
                    
                    isSuccess(false)
                    
                }
                
            case .failure(let error):
                
                print(error)
                
            }
        }
                
    }
    
    func uploadImageToGetURL(image: UIImage, completion: @escaping (Result<(uuid: String, url: String), Error>) -> Void) {
        
        let uniqueString = NSUUID().uuidString
        
        let storageRef = Storage.storage().reference().child("plantPhoto").child("\(uniqueString).jpg")
        
        let metadata = StorageMetadata()
        
        metadata.contentType = "image/jpg"
        
        if let uploadData =  image.scale(newWidth: 100).pngData() {
            
            let uploadTask = storageRef.putData(uploadData, metadata: nil)
            
            uploadTask.observe(.success) { snapshot in
                snapshot.reference.downloadURL { url, _ in
                    guard let url = url else {
                        return
                    }
                    
                    completion(Result.success((uniqueString, url.absoluteString)))
                }
            }
        }
    }
    
    func fetchPlants(completion: @escaping (Result<[Plant], Error>) -> Void) {
    
        dataBase.collection("plant").order(by: "buyTime", descending: true).getDocuments { snapshot, error in
            
            if let error = error {
                
                completion(Result.failure(error))
                
            }
            
            guard let snapshot = snapshot else { return }
            
            let plant = snapshot.documents.compactMap { snapshot in
                
                try? snapshot.data(as: Plant.self)
            }
            
            completion(Result.success(plant))
        }
    }
    
    func fetchFavoritePlants(completion: @escaping (Result<[Plant], Error>) -> Void) {
    
        dataBase.collection("plant")
            .whereField("favorite", isEqualTo: true)
            .getDocuments { snapshot, error in
            
            if let error = error {
                
                completion(Result.failure(error))
                
            }
            
            guard let snapshot = snapshot else { return }
            
            let plant = snapshot.documents.compactMap { snapshot in
                
                try? snapshot.data(as: Plant.self)
            }
            
            completion(Result.success(plant))
        }
    }
    
    func switchFavoritePlant(plantID: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        let documentRef = dataBase.collection("plant").document(plantID)
        
        documentRef.getDocument { document, error in
            
            guard let document = document,
                  document.exists,
                  var plant = try? document.data(as: Plant.self) else { return }
            
            plant.favorite = !plant.favorite
            
            do {
                
                try documentRef.setData(from: plant)
                
                completion(Result.success(true))
                
            } catch {
                
                print(error)
                
                completion(Result.failure(error))
            }
        }
        
    }
    
}
