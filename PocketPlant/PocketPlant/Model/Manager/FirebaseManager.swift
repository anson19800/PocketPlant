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

enum DataType {
    case waterRecord
    case shop
    case tool
}

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private let dataBase = Firestore.firestore()
    
    private init() {}
    
    private let imageManager = ImageManager.shared
    
    private let userManager = UserManager.shared
    
    private let plantRef = Firestore.firestore().collection(FirebaseCollectionList.plants)
    
    private let waterRef = Firestore.firestore().collection(FirebaseCollectionList.water)
    
    private let shopRef = Firestore.firestore().collection(FirebaseCollectionList.shop)
    
    private let toolRef = Firestore.firestore().collection(FirebaseCollectionList.tools)
    
    func fetchPlants(_ type: HomePagePlantType, completion: @escaping (Result<[Plant], Error>) -> Void) {
        
        guard let userID = userManager.currentUser?.userID else { return }
        
        let documentRef: Query?
        
        switch type {
        case .myPlant:
            
            documentRef = plantRef
                .whereField("ownerID", isEqualTo: userID)
                .order(by: "buyTime", descending: true)
            
        case .myFavorite:
            
            documentRef = plantRef
                .whereField("ownerID", isEqualTo: userID)
                .whereField("favorite", isEqualTo: true)
            
        case .sharePlants: return
            
        }
        
        guard let documentRef = documentRef else { return }
        
        documentRef.getDocuments { snapshot, error in
            if let error = error { completion(Result.failure(error)) }
            
            guard let snapshot = snapshot else { return }
            
            let plants = snapshot.documents.compactMap { snapshot in
                
                try? snapshot.data(as: Plant.self)
            }
            
            completion(Result.success(plants))
        }
    }

    func uploadPlant(plant: inout Plant, image: UIImage, completion: @escaping (_ isSuccess: Bool) -> Void) {
        
        guard let userID = userManager.currentUser?.userID else { return }
        
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
                    
                    try self.plantRef.document(documentID).setData(from: uploadPlant)
                    
                    completion(true)
                    
                } catch {
                    
                    completion(false)
                }
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func fetchPlants(plantID: String, completion: @escaping (Result<Plant, Error>) -> Void) {
    
        plantRef.document(plantID).getDocument { document, error in
            
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            guard let document = document,
                  document.exists,
                  let plant = try? document.data(as: Plant.self)
            else { return }
            
            completion(Result.success(plant))
        }
    }
    
    func switchFavoritePlant(plantID: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        let documentRef = plantRef.document(plantID)
        
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
    
    func deletePlant(plant: Plant, completion: @escaping (_ isSuccess: Bool) -> Void) {
        
        let batch = dataBase.batch()
        
        let plantRef = plantRef.document(plant.id)
        
        let waterRecordRef = waterRef
            .whereField("plantID", isEqualTo: plant.id)
        
        let commentRef = dataBase.collection(FirebaseCollectionList.comment)
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
                
                completion( error == nil )
            }
        }
    }
    
    func updatePlant(plant: Plant, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        let documentRef = plantRef.document(plant.id)
        
        RemindManager.shared.deleteReminder(plantID: plant.id)
        
        documentRef.getDocument { document, error in
            guard let document = document,
                  document.exists else { return }
            
            do {
                try documentRef.setData(from: plant)
                
                completion(Result.success(true))
            } catch {
                completion(Result.failure(error))
            }
        }
    }
    
    func updateWater(plant: Plant, completion: @escaping (_ isSuccess: Bool) -> Void) {
        
        let documentID = waterRef.document().documentID
        
        let waterRecord = WaterRecord(id: documentID,
                                       plantID: plant.id,
                                       plantName: plant.name,
                                       plantImage: plant.imageURL,
                                       waterDate: Date().timeIntervalSince1970)
        
        do {
            try self.waterRef.document(documentID).setData(from: waterRecord)
            
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    func fetchWaterRecord(plantID: String, completion: @escaping (Result<[WaterRecord], Error>) -> Void) {
        
        waterRef
            .whereField("plantID", isEqualTo: plantID)
            .getDocuments { snapshot, error in
            
            if let error = error { completion(Result.failure(error)) }
            
            guard let snapshot = snapshot else { return }
            
            let waterRecord = snapshot.documents.compactMap { snapshot in
                
                try? snapshot.data(as: WaterRecord.self)
            }
            completion(Result.success(waterRecord))
        }
    }
    
    func fetchWaterRecord(date: Date, completion: @escaping (Result<[WaterRecord], Error>) -> Void) {
        
        guard let userID = userManager.currentUser?.userID else { return }
        
        waterRef
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
            
            if let error = error { completion(Result.failure(error)) }
            
            guard let snapshot = snapshot else { return }
            
            let waterRecord = snapshot.documents.compactMap { snapshot in
                
                try? snapshot.data(as: WaterRecord.self)
            }
            
            let recordDay = waterRecord.compactMap { (record) -> WaterRecord? in
                let recordDate = Date(timeIntervalSince1970: record.waterDate)
                guard recordDate.hasSame(.year, as: date)
                        && recordDate.hasSame(.month, as: date)
                        && recordDate.hasSame(.day, as: date) else { return nil }
                
                return record
            }
            completion(.success(recordDay))
        }
    }
    
    func addGardeningShop(shop: inout GardeningShop, completion: @escaping (_ isSuccess: Bool) -> Void) {
        
        let documentID = shopRef.document().documentID
        
        shop.id = documentID
        
        do {
            try shopRef.document(documentID).setData(from: shop)
            
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    func fetchShops(completion: @escaping (Result<[GardeningShop], Error>) -> Void) {
        
        guard let userID = userManager.currentUser?.userID else { return }
        
        shopRef.whereField("ownerID", isEqualTo: userID)
            .getDocuments { snapshot, error in
            
            if let error = error { completion(Result.failure(error)) }
            
            guard let snapshot = snapshot else { return }
            
            let shop = snapshot.documents.compactMap { snapshot in
                
                try? snapshot.data(as: GardeningShop.self)
            }
            
            completion(Result.success(shop))
        }
    }
    
    func fetchDiscoverObject<T: Decodable>(_ type: DiscoverType, completion: @escaping GenericCompletion<T>) {
        
        let documentRef: CollectionReference?
        
        switch type {
        case .plant:
            documentRef = plantRef
        case .shop:
            documentRef = shopRef
        }
        
        guard let documentRef = documentRef else { return }
        
        if userManager.currentUser == nil {
            
            documentRef
                .getDocuments { snapshot, error in
                    
                if let error = error { completion(nil, error) }
                
                guard let snapshot = snapshot else { return }
                
                let object = snapshot.documents.compactMap { snapshot in
                    
                    try? snapshot.data(as: T.self)
                }
                completion(object, nil)
            }
            
        } else {
            
            documentRef
                .whereField("ownerID", isNotEqualTo: UserManager.shared.userID)
                .getDocuments { snapshot, error in
                if let error = error { completion(nil, error) }
                
                guard let snapshot = snapshot else { return }
                
                let object = snapshot.documents.compactMap { snapshot in
                    
                    try? snapshot.data(as: T.self)
                }
                completion(object, nil)
            }
        }
    }
    
    func uploadTool(tool: Tool, completion: (_ isSuccess: Bool) -> Void) {
        
        guard let userID = userManager.currentUser?.userID else { return }
        
        let toolRef = toolRef
            .document(userID)
            .collection(FirebaseCollectionList.toolList)
        
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
            
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    func fetchTool(completion: @escaping (Result<[Tool], Error>) -> Void) {
        
        guard let userID = userManager.currentUser?.userID else { return }
        
        let toolRef = toolRef
            .document(userID)
            .collection(FirebaseCollectionList.toolList)
        
        toolRef.getDocuments { snapshot, error in
            
            if let error = error { completion(Result.failure(error)) }
            
            guard let snapshot = snapshot else { return }
            
            let tools = snapshot.documents.compactMap { snapshot in
                
                try? snapshot.data(as: Tool.self)
            }
            
            completion(Result.success(tools))
        }
    }
    
    func deleteData(_ type: DataType, dataID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let userID = userManager.currentUser?.userID else { return }
        
        let documentRef: DocumentReference?
        
        switch type {
        case .waterRecord:
            documentRef = waterRef.document(dataID)
        case .shop:
            documentRef = shopRef.document(dataID)
        case .tool:
            documentRef = toolRef
                .document(userID)
                .collection(FirebaseCollectionList.toolList)
                .document(dataID)
        }
        
        documentRef?.delete(completion: { error in
            if let error = error {
                completion(Result.failure(error))
            } else {
                completion(Result.success(Void()))
            }
        })
    }
}
