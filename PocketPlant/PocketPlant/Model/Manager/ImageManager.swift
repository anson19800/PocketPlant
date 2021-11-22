//
//  ImageManager.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/21.
//

import UIKit
import FirebaseStorage

class ImageManager {
    
    static let shared = ImageManager()
    
    private init() {}
    
    func uploadImageToGetURL(image: UIImage, completion: @escaping (Result<(uuid: String, url: String), Error>) -> Void) {
        
        let uniqueString = NSUUID().uuidString
        
        let storageRef = Storage.storage().reference().child("plantPhoto").child("\(uniqueString).png")
        
        let metadata = StorageMetadata()
        
        metadata.contentType = "image/png"
        
        if let uploadData =  image.pngData() {
            
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
    
    func deleteImage(imageID: String) {
        
        let imageRef = Storage.storage().reference().child("plantPhoto").child("\(imageID).png")
        
        imageRef.delete { error in
            
            if let error = error {
                
                print(error)
                
            } 
            
        }
    }
    
}
