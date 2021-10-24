//
//  NewPlantPageViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/19.
//

import UIKit
import PhotosUI
import FirebaseStorage
import Kingfisher

enum NewPlantPageMode {
    case edit(editedPlant: Plant)
    case create
}

class NewPlantPageViewController: UIViewController {
    
    var pageMode: NewPlantPageMode = .create
    
    let imageManager = ImageManager.shared
    
    let firebaseManager = FirebaseManager.shared

    @IBOutlet weak var titleLabel: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerCellWithNib(
            identifier: String(describing: InputPlantTableViewCell.self),
            bundle: nil)
        
        switch pageMode {
        case .edit(let editedPlant):
            
            guard let imageURL = editedPlant.imageURL else { return }
            
            plantImageView.kf.setImage(with: URL(string: imageURL))
            
            titleLabel.text = "編輯植物"
            
        case .create:
            
            titleLabel.text = "新增植物"
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch pageMode {
        case .edit(let editedPlant):
            
            guard let imageURL = editedPlant.imageURL else { return }
            
            plantImageView.kf.setImage(with: URL(string: imageURL))
            
            titleLabel.text = "編輯植物"
            
        case .create:
            
            titleLabel.text = "新增植物"
        }
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
        
        switch pageMode {
            
        case .edit(editedPlant: let editedPlant):
            
            inputCell.layoutCell(plant: editedPlant)
            
            inputCell.postButton.setTitle("編輯植物", for: .normal)
            
        case .create:
            
            inputCell.postButton.setTitle("新增植物", for: .normal)
            
        }
        
        return inputCell
    }
}

extension NewPlantPageViewController: InputPlantDelegate {
    
    func addNewPlant(plant: inout Plant) {
        
        guard let image = self.plantImageView.image else { return }
        
        switch pageMode {
            
        case .create:
            
            self.firebaseManager.uploadPlant(plant: &plant, image: image) { isSuccess in
                
                if isSuccess {
                    
                    self.dismiss(animated: true, completion: nil)
                    
                    guard let parentNVC = self.presentingViewController as? UINavigationController,
                          let parentVC = parentNVC.viewControllers.first,
                          let homePageVC = parentVC as? HomePageViewController else { return }
                    
                    homePageVC.updateMyPlants(withAnimation: false)
                }
                
            }
            
        case .edit(let editPlant):
            
            var newPlant = plant
            
            newPlant.id = editPlant.id
            
            imageManager.deleteImage(imageID: editPlant.imageID!)
            
            imageManager.uploadImageToGetURL(image: image) { result in
                
                switch result {
                    
                case .success((let uuid, let url)):
                    
                    newPlant.imageID = uuid
                    
                    newPlant.imageURL = url
                    
                    self.firebaseManager.updatePlant(plant: newPlant) { result in
                        
                        switch result {
                        case .success:
                            
                            self.dismiss(animated: true, completion: nil)
                            
                            guard let parentNVC = self.presentingViewController as? UINavigationController,
                                  let parentVC = parentNVC.viewControllers.first,
                                  let homePageVC = parentVC as? HomePageViewController else { return }
                            
                            homePageVC.updateMyPlants(withAnimation: false)
                            
                        case .failure(let error):
                            
                            print(error)
                            
                        }
                    }
                    
                case .failure(let error):
                    
                    print(error)
                }
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
            
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                
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
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            self.plantImageView.image = image
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
}
