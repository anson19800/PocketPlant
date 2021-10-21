//
//  NewPlantPageViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/19.
//

import UIKit
import PhotosUI
import FirebaseStorage

class NewPlantPageViewController: UIViewController {

    @IBOutlet weak var uploadImageButton: UIButton! {
        didSet {
            uploadImageButton.layer.borderWidth = 2
            uploadImageButton.layer.borderColor = UIColor.lightGray.cgColor
            uploadImageButton.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var takePhotoButton: UIButton! {
        didSet {
            takePhotoButton.layer.borderWidth = 2
            takePhotoButton.layer.borderColor = UIColor.lightGray.cgColor
            takePhotoButton.layer.cornerRadius = 20
        }
    }
    
    @IBOutlet weak var plantImageView: UIImageView! {
        didSet {
            plantImageView.layer.cornerRadius = 8
            plantImageView.layer.borderColor = UIColor.lightGray.cgColor
            plantImageView.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
        }
    }
    
    let firebaseManager = FirebaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerCellWithNib(
            identifier: String(describing: InputPlantTableViewCell.self),
            bundle: nil)
    }
    
    @IBAction func uploadImageAction(_ sender: Any) {
        
        if #available(iOS 14, *) {
            
            var configuration = PHPickerConfiguration()
            
            configuration.filter = .images
            
            let picker = PHPickerViewController(configuration: configuration)
            
            picker.delegate = self
            
            present(picker, animated: true, completion: nil)
            
        } else {
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                let imagePicker = UIImagePickerController()
                
                imagePicker.allowsEditing = false
                
                imagePicker.sourceType = .photoLibrary
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func takePhotoAction(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.allowsEditing = false
            
            imagePicker.sourceType = .camera
            
            imagePicker.delegate = self
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
}

extension NewPlantPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: InputPlantTableViewCell.self),
            for: indexPath)
        
        guard let inputCell = cell as? InputPlantTableViewCell else { return cell }
        
        inputCell.delegate = self
        
        return inputCell
    }
}

extension NewPlantPageViewController: InputPlantDelegate {
    
    func addNewPlant(plant: inout Plant) {
        
        guard let image = self.plantImageView.image else { return }
        
        self.firebaseManager.uploadPlant(plant: &plant, image: image) { isSuccess in
            
            if isSuccess {
                
                self.dismiss(animated: true, completion: nil)
                
                guard let parentNVC = self.presentingViewController as? UINavigationController,
                      let parentVC = parentNVC.viewControllers.first,
                      let homePageVC = parentVC as? HomePageViewController else { return }
                
                homePageVC.updateMyPlants()
            }
            
        }
        
    }
    

}

@available(iOS 14, *)
extension NewPlantPageViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        let itemProviders = results.map(\.itemProvider)
        
        if let itemProvider = itemProviders.first,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                
                DispatchQueue.main.async {
                    
                    guard let self = self,
                          let image = image as? UIImage else { return }
                    
                    self.plantImageView.image = image
                }
            }
        }
    }
    
}

extension NewPlantPageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            self.plantImageView.image = image
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
}