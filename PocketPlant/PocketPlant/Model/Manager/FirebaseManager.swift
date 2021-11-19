//
//  FirebaseManager.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/18.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

typealias GenericCompletion<T: Decodable> = (([T]?, Error?) -> Void)

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private let dataBase = Firestore.firestore()
    
    private init() {}
    
    private let imageManager = ImageManager.shared
    
    let userID: String = {
        
        if let user = Auth.auth().currentUser {
            
            return user.uid
        
        } else {
            
            return "0"
            
        }
        
    }()
    
    func uploadPlant(plant: inout Plant, image: UIImage, isSuccess: @escaping (Bool) -> Void) {
        
        let plantRef = dataBase.collection("plant")
        
        let documentID = plantRef.document().documentID
        
        var uploadPlant = plant
        
        uploadPlant.id = documentID
        
        uploadPlant.ownerID = userID
        
        imageManager.uploadImageToGetURL(image: image) { result in
            
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
    
    func fetchPlants(completion: @escaping (Result<[Plant], Error>) -> Void) {
    
        dataBase.collection("plant")
            .whereField("ownerID", isEqualTo: userID)
            .order(by: "buyTime", descending: true)
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
    
    func fetchPlants(plantID: String, completion: @escaping (Result<Plant, Error>) -> Void) {
    
        dataBase.collection("plant").document(plantID).getDocument { document, error in
            guard let document = document,
                  document.exists,
                  let plant = try? document.data(as: Plant.self)
            else { return }
            
            completion(Result.success(plant))
        }
    }
    
    func fetchFavoritePlants(completion: @escaping (Result<[Plant], Error>) -> Void) {
    
        dataBase.collection("plant")
            .whereField("ownerID", isEqualTo: userID)
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
    
    func deletePlant(plant: Plant, isSuccess: @escaping (Bool) -> Void) {
        
        let batch = dataBase.batch()
        
        let plantRef = dataBase.collection("plant").document(plant.id)
        
        let waterRecordRef = dataBase.collection("water").whereField("plantID", isEqualTo: plant.id)
        
        let commentRef = dataBase.collection("comment")
            .whereField("commentType", isEqualTo: "plant")
            .whereField("objectID", isEqualTo: plant.id)
        
        let group = DispatchGroup()
        
        guard let imageID = plant.imageID else { return }
        
        imageManager.deleteImage(imageID: imageID)
        
        group.enter()
        
        waterRecordRef.getDocuments { snapshot, _ in
            
            guard let snapshot = snapshot else { return }
            
            snapshot.documents.forEach { snapshot in
                
                batch.deleteDocument(snapshot.reference)
            }
            
            group.leave()
        }
        
        group.enter()
        
        commentRef.getDocuments { snapshot, _ in
            
            guard let snapshot = snapshot else { return }
            
            snapshot.documents.forEach { snapshot in
                
                batch.deleteDocument(snapshot.reference)
            }
            
            group.leave()
        }
        
        RemindManager.shared.deleteReminder(plantID: plant.id)
        
        batch.deleteDocument(plantRef)
        
        group.notify(queue: .main) {
            
            batch.commit { error in
                
                if error != nil {
                    
                    isSuccess(false)
                    
                } else {
                    
                    isSuccess(true)
                    
                }
            }
        }
    }
    
    func updatePlant(plant: Plant, isSuccess: @escaping (Result<Bool, Error>) -> Void) {
        
        let documentRef = dataBase.collection("plant").document(plant.id)
        
        RemindManager.shared.deleteReminder(plantID: plant.id)
        
        documentRef.getDocument { document, error in
            guard let document = document,
                  document.exists else { return }
            
            do {
                
                try documentRef.setData(from: plant)
                
                isSuccess(Result.success(true))
                
            } catch {
                
                print(error)
                
                isSuccess(Result.failure(error))
                
            }
        }
    }
    
    func updateWater(plant: Plant, isSuccess: @escaping (Bool) -> Void) {
        
        let waterRef = dataBase.collection("water")
        
        let documentID = waterRef.document().documentID
        
        let waterRecord = WaterRecord(id: documentID,
                                       plantID: plant.id,
                                       plantName: plant.name,
                                       plantImage: plant.imageURL,
                                       waterDate: Date().timeIntervalSince1970)
        
        do {
            
            try waterRef.document(documentID).setData(from: waterRecord)
            
            isSuccess(true)
            
        } catch {
            
            isSuccess(false)
            
        }
    }
    
    func fetchWaterRecord(plantID: String, completion: @escaping (Result<[WaterRecord], Error>) -> Void) {
        
        let waterRef = dataBase.collection("water")
        
        waterRef
            .whereField("plantID", isEqualTo: plantID)
            .getDocuments { snapshot, error in
            
            if let error = error {
                
                completion(Result.failure(error))
                
            }
            
            guard let snapshot = snapshot else { return }
            
            let waterRecord = snapshot.documents.compactMap { snapshot in
                
                try? snapshot.data(as: WaterRecord.self)
            }
            
            completion(Result.success(waterRecord))
        }
    }
    
    func fetchWaterRecord(date: Date, completion: @escaping (Result<[WaterRecord], Error>) -> Void) {
        
        let waterRef = dataBase.collection("water")
        
        waterRef
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
            
            if let error = error {
                
                completion(Result.failure(error))
            }
            
            guard let snapshot = snapshot else { return }
            
            let waterRecord = snapshot.documents.compactMap { snapshot in
                
                try? snapshot.data(as: WaterRecord.self)
            }
            
            let recordDay = waterRecord.compactMap { (record) -> WaterRecord? in
                let recordDate = Date(timeIntervalSince1970: record.waterDate)
                if recordDate.hasSame(.year, as: date)
                    && recordDate.hasSame(.month, as: date)
                    && recordDate.hasSame(.day, as: date) {
                    
                    return record
                    
                } else {
                    
                    return nil
                    
                }
            }
            completion(.success(recordDay))
        }
    }
    
    func deleteWaterRecord(recordID: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let waterRef = dataBase.collection("water").document(recordID)
        
        waterRef.delete { error in
            if let error = error {
                completion(Result.failure(error))
            } else {
                completion(Result.success("Delete Success"))
            }
        }
    }
    
    func deleteWaterRecord(plantID: String) {
        
        dataBase.collection("water")
            .whereField("plantID", isEqualTo: plantID).getDocuments { snapshot, error in
                
                guard let snapshot = snapshot else { return }
                
                snapshot.documents.forEach { snapshot in
                    snapshot.reference.delete()
                }
        }
    }
    
    func addGardeningShop(shop: inout GardeningShop, isSuccess: @escaping (Bool) -> Void) {
        
        let shopRef = dataBase.collection("shop")
        
        let documentID = shopRef.document().documentID
        
        shop.id = documentID
        
        do {
            
            try shopRef.document(documentID).setData(from: shop)
            
            isSuccess(true)
            
        } catch {
            
            isSuccess(false)
        }
    }
    
    func fetchShops(completion: @escaping (Result<[GardeningShop], Error>) -> Void) {
        dataBase.collection("shop")
            .whereField("ownerID", isEqualTo: userID)
            .getDocuments { snapshot, error in
            
            if let error = error {
                
                completion(Result.failure(error))
                
            }
            
            guard let snapshot = snapshot else { return }
            
            let shop = snapshot.documents.compactMap { snapshot in
                
                try? snapshot.data(as: GardeningShop.self)
            }
            
            completion(Result.success(shop))
        }
    }
    
    func deleteShop(shop: GardeningShop) {
        
        guard let id = shop.id else { return }
        
        let documentRef = dataBase.collection("shop").document(id)
        
        documentRef.delete()
    }
    
    func fetchDiscoverObject<T: Decodable>(_ type: DiscoverType, completion: @escaping GenericCompletion<T>) {
        
        let documentRef: CollectionReference?
        
        switch type {
        case .plant:
            documentRef = dataBase.collection("plant")
        case .shop:
            documentRef = dataBase.collection("shop")
        }
        
        guard let documentRef = documentRef else { return }

        documentRef
            .whereField("ownerID", isNotEqualTo: UserManager.shared.userID)
            .getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
            }
            
            guard let snapshot = snapshot else { return }
            
            let object = snapshot.documents.compactMap { snapshot in
                
                try? snapshot.data(as: T.self)
            }
            
            completion(object, nil)
            
        }
    }
    
    func uploadTool(tool: Tool, isSuccess: (Bool) -> Void) {
        
        let toolRef = dataBase.collection("Tools").document(self.userID).collection("toolList")
        
        var documentID: String = ""
        
        if tool.id == "" {
            documentID = toolRef.document().documentID
        } else {
            documentID = tool.id
        }
        
        var tool = tool
        
        tool.id = documentID
        
        do {
            
            try toolRef.document(documentID).setData(from: tool)
            
            isSuccess(true)
            
        } catch {
            
            isSuccess(false)
            
        }
    }
    
    func fetchTool(completion: @escaping (Result<[Tool], Error>) -> Void) {
        
        let toolRef = dataBase.collection("Tools").document(self.userID).collection("toolList")
        
        toolRef.getDocuments { snapshot, error in
            
            if let error = error {
                completion(Result.failure(error))
            }
            
            guard let snapshot = snapshot else { return }
            
            let tools = snapshot.documents.compactMap { snapshot in
                
                try? snapshot.data(as: Tool.self)
            }
            
            completion(Result.success(tools))
        }
    }
    
    func updateTool(toolID: String, tool: Tool, isSuccess: (Bool) -> Void) {
        
        let toolRef = dataBase.collection("Tools").document(self.userID).collection("toolList").document(toolID)
        
        do {
            
            try toolRef.setData(from: tool)
            
            isSuccess(true)
            
        } catch {
            
            isSuccess(false)
            
        }
    }
    
    func deleteTool(toolID: String, isSuccess: @escaping (Bool) -> Void) {
        let toolRef = dataBase.collection("Tools").document(self.userID).collection("toolList").document(toolID)
        
        toolRef.delete { error in
            if let error = error {
                isSuccess(false)
            } else {
                isSuccess(true)
            }
        }
    }
}
