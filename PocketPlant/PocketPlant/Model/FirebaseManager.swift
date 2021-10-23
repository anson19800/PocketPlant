//
//  FirebaseManager.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/18.
//

import Foundation
import FirebaseFirestore

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private let db = Firestore.firestore()
    
    func uploadPlant(plant: inout Plant) {
        
        let plantRef = db.collection("plant")
        
        let documentID = plantRef.document().documentID
        
        plant.id = documentID
                
        do {
            
            try plantRef.document(documentID).setData(from: plant)
            
            print("Success")
            
        } catch {
            
            print(error)
            
        }
    }
    
    func fetchPlants(completion: @escaping (Result<[Plant], Error>) -> Void) {
    
        db.collection("plant").order(by: "buyTime", descending: true).getDocuments { snapshot, error in
            
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
    
}
