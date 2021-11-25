//
//  NewShopViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/31.
//

import UIKit
import PhotosUI
import Kingfisher

class NewShopViewController: UIViewController {
    
    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet {
            imageCollectionView.delegate = self
            imageCollectionView.dataSource = self
            imageCollectionView.registerCellWithNib(
                identifier: String(describing: ImageCollectionViewCell.self),
                bundle: nil)
            imageCollectionView.clipsToBounds = false
        }
    }
    
    @IBOutlet weak var infoTableView: UITableView! {
        didSet {
            infoTableView.delegate = self
            infoTableView.dataSource = self
            infoTableView.registerCellWithNib(
                identifier: String(describing: InputShopInfoTableViewCell.self),
                bundle: nil)
        }
    }
    
    var selectedImages: [UIImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        
        let cell = infoTableView.cellForRow(at: IndexPath(row: 0, section: 0))
        
        guard let infoCell = cell as? InputShopInfoTableViewCell,
              var shop = infoCell.renderInfo() else { return }
        
        var imageURLList: [String] = []
        var imageIDList: [String] = []
        
        if let selectedImage = selectedImages {
            
            let group: DispatchGroup = DispatchGroup()
            
            selectedImage.forEach { image in
                
                group.enter()
                
                let scaleImage = image.scale(newWidth: 100)
                
                ImageManager.shared.uploadImageToGetURL(image: scaleImage) { result in
                    switch result {
                    case .success((let uuid, let url)):
                        imageURLList.append(url)
                        imageIDList.append(uuid)
                        
                        group.leave()
                        
                    case .failure(let error):
                        print(error)
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: DispatchQueue.main) {
                
                shop.images = imageURLList
                shop.imagesID = imageIDList
                
                FirebaseManager.shared.addGardeningShop(shop: &shop) { isSuccess in
                    if isSuccess {
                        print("upload success!")
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
        }
    }
}

extension NewShopViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: InputShopInfoTableViewCell.self),
            for: indexPath)
        
        guard let infoCell = cell as? InputShopInfoTableViewCell else { return cell }
        
        return infoCell
    }
}

extension NewShopViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let images = selectedImages else { return 1 }
        
        if images.count < 5 {
            
            return images.count + 1
            
        } else {
            
            return images.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ImageCollectionViewCell.self),
            for: indexPath)
        
        guard let imageCell = cell as? ImageCollectionViewCell else { return cell }
        
        if let images = selectedImages {
            
            if indexPath.row >= images.count {
                
                let placeHolderImage = UIImage(systemName: "plus.square.dashed")
                
                imageCell.mainImageView.image = placeHolderImage
                
                imageCell.mainImageView.tintColor = .DarkGreen
                
            } else {
                
                imageCell.mainImageView.image = images[indexPath.row]
            }
            
        } else if selectedImages == nil {
            
            let placeHolderImage = UIImage(systemName: "plus.square.dashed")
            
            imageCell.mainImageView.image = placeHolderImage
            
            imageCell.mainImageView.tintColor = .DarkGreen
        }
        
        return imageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let images = selectedImages else {
            print("Add")
            if #available(iOS 14, *) {
                addImage()
            }
            return
        }
        
        if images.count == 5 {
            
            return
            
        } else if indexPath.row == images.count {
            
            print("Add")
            if #available(iOS 14, *) {
                addImage()
            }
        }
        
    }
    
    @available(iOS 14, *)
    func addImage() {
        
        var configuration = PHPickerConfiguration()
        
        configuration.filter = .images
        
//        if let selectedImage = selectedImage {
//            configuration.selectionLimit = 5 - selectedImage.count
//        } else {
//            configuration.selectionLimit = 5
//        }
        configuration.selectionLimit = 5
        
        let picker = PHPickerViewController(configuration: configuration)
        
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    }
}

@available(iOS 14, *)
extension NewShopViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        var images: [UIImage] = []
        picker.dismiss(animated: true, completion: nil)
        
        let itemProviders = results.map(\.itemProvider)
        
        itemProviders.forEach { itemProvider in
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                
                itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        guard let image = image as? UIImage else { return }
                        images.append(image)
                        self.selectedImages = images
                        self.imageCollectionView.reloadData()
                    }
                }
            }
        }
    }
}
