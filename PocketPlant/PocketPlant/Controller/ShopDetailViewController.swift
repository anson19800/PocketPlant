//
//  ShopDetailViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/30.
//

import UIKit
import MapKit

class ShopDetailViewController: UIViewController {
    
    @IBOutlet weak var shopTitle: UILabel!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var backgroundView: UIView! {
        didSet {
            backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            backgroundView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.registerCellWithNib(identifier: String(describing: CommentTableViewCell.self), bundle: nil)
            tableView.registerCellWithNib(identifier: String(describing: CommentTitleTableViewCell.self), bundle: nil)
            tableView.registerCellWithNib(identifier: String(describing: ImageCollectionVIewTableViewCell.self), bundle: nil)
        }
    }
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    
    let commentManager = CommentManager.shared
    
    var shop: GardeningShop?
    
    var comments: [Comment]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        layoutMapLocation()
        fetchComment()
    }
    
    func layoutMapLocation() {
        
        guard let shop = shop else { return }
        
        shopTitle.text = shop.name
        addressTextView.text = shop.address
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(shop.address) { placemarks, _ in
            
            let annotation = MKPointAnnotation()
            
            if let location = placemarks?.first?.location {
                
                annotation.coordinate = location.coordinate
                
                self.mapView.addAnnotation(annotation)
                
                let region = MKCoordinateRegion(center: annotation.coordinate,
                                                latitudinalMeters: 500,
                                                longitudinalMeters: 500)
                self.mapView.setRegion(region, animated: false)
            }
        }
    }
    
    func fetchComment() {
        guard let shop = shop,
              let shopID = shop.id else {
            return
        }

        commentManager.fetchComment(type: .shop,
                                    objectID: shopID) { result in
            switch result {
                
            case .success(let comments):
                
                self.comments = comments
                
                self.tableView.performBatchUpdates {
                    let indexSet = IndexSet(integersIn: 0...0)
                    self.tableView.reloadSections(indexSet, with: .fade)
                }
                
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        addressTextView.selectedTextRange = nil
    }
    
    @IBAction func publishComment(_ sender: UIButton) {
        guard let shop = shop,
              let comment = commentTextField.text,
              let shopID = shop.id else { return }
        if comment != "" {
            let comment = Comment(commentType: .shop,
                                  objectID: shopID,
                                  content: comment,
                                  createdTime: Date().timeIntervalSince1970)
            commentManager.publishComment(comment: comment) { isSuccess in
                if isSuccess {
                    
                    self.fetchComment()
                    
                    self.commentTextField.text = ""
                    
                    self.view.endEditing(true)
                    
                } else {
                    showAlert(title: "發送失敗", message: "發送的過程出了點問題，請再試一次！", buttonTitle: "確定")
                }
            }
        }
    }
}

extension ShopDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let comments = comments else { return 1 }
        
        return comments.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let comments = comments else { return UITableViewCell() }
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ImageCollectionVIewTableViewCell.self),
                for: indexPath)
            
            guard let imageCell = cell as? ImageCollectionVIewTableViewCell else { return cell }
            
            imageCell.collectionView.delegate = self
            
            imageCell.collectionView.dataSource = self
            
            return imageCell
            
        } else if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CommentTitleTableViewCell.self),
                                                     for: indexPath)
            guard let titleCell = cell as? CommentTitleTableViewCell else { return cell }
            
            titleCell.layoutCell(commentCount: comments.count)
            
            return titleCell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CommentTableViewCell.self),
                                                     for: indexPath)
            guard let commentCell = cell as? CommentTableViewCell else { return cell }
            
            commentCell.layoutCell(comment: comments[indexPath.row - 2])
            
            return commentCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addressTextView.selectedTextRange = nil
    }
    
}

extension ShopDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let shop = shop,
              let images = shop.images else { return 0 }
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ImageCollectionViewCell.self),
            for: indexPath)
        
        guard let imageCell = cell as? ImageCollectionViewCell,
              let shop = shop else { return cell }
        
        if let images = shop.images {
            imageCell.imageView.kf.setImage(with: URL(string: images[indexPath.row]))
        } else {
            imageCell.imageView.image = UIImage(named: "plant")
        }
        
        return imageCell
    }
    
}
