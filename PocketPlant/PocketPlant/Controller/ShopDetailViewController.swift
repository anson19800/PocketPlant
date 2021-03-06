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
    @IBOutlet weak var phoneTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
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
            tableView.registerCellWithNib(identifier: String(describing: ImageCollectionViewTableViewCell.self), bundle: nil)
        }
    }
    @IBOutlet weak var userImage: UIImageView! {
        didSet {
            userImage.layer.cornerRadius = userImage.frame.width / 2
        }
    }
    @IBOutlet weak var commentTextField: UITextField!
    
    let commentManager = CommentManager.shared
    
    var shop: GardeningShop?
    
    var comments: [Comment]?
    
    var commentUser: [String: User] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let useImageURL = UserManager.shared.currentUser?.userImageURL {
            userImage.kf.setImage(with: URL(string: useImageURL))
        }
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
        phoneTextView.text = "電話：\(shop.phone)"
        if shop.description == "" {
            descriptionTextView.text = "備註：上傳者沒有留訊息呦～"
        } else {
            descriptionTextView.text = "備註：\(shop.description)"
        }
        
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
                                    objectID: shopID) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                
            case .success(let comments):
                
                self.comments = comments
                
                let group = DispatchGroup()
                
                comments.forEach { comment in
                    
                    group.enter()
                    
                    if self.commentUser[comment.senderID] == nil {
                        UserManager.shared.fetchUserInfo(userID: comment.senderID) { [weak self] result in
                            guard let self = self else { return }
                            
                            switch result {
                            case .success(let user):
                                self.commentUser[comment.senderID] = user
                                group.leave()
                            case .failure(let error):
                                print(error)
                                group.leave()
                            }
                        }
                    } else {
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    
                    self.tableView.performBatchUpdates {
                        let indexSet = IndexSet(integersIn: 0...0)
                        self.tableView.reloadSections(indexSet, with: .fade)
                    }
                }
                
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
            commentManager.publishComment(comment: comment) { [weak self] isSuccess in
                guard let self = self else { return }
                
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
                withIdentifier: String(describing: ImageCollectionViewTableViewCell.self),
                for: indexPath)
            
            guard let imageCell = cell as? ImageCollectionViewTableViewCell else { return cell }
            
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
            
            let comment = comments[indexPath.row - 2]
            
            if let user = self.commentUser[comment.senderID] {
                
                commentCell.layoutCell(comment: comment, user: user, isOwner: false)
                
            } else {
                
                commentCell.layoutCell(comment: comment, user: nil, isOwner: false)
                
            }
            
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
            imageCell.mainImageView.kf.setImage(with: URL(string: images[indexPath.row]))
        } else {
            imageCell.mainImageView.image = UIImage(named: "plant")
        }
        
        return imageCell
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard indexPath.row > 1 else { return nil }
        
        guard let comments = self.comments,
              let currentUser = UserManager.shared.currentUser
        else { return nil }
        
        let comment = comments[indexPath.row - 2]
        
        if comment.senderID == currentUser.userID {
            return nil
        }
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) { _ in
            
            let blockAction = UIAction(title: "封鎖使用者",
                                       image: UIImage(systemName: "person.fill.xmark"),
                                       attributes: .destructive) { _ in
                
                let commentIndex = indexPath.row - 2
                
                guard let comments = self.comments else { return }
                
                let comment = comments[commentIndex]
                
                let blockedUserID = comment.senderID
                
                UserManager.shared.addBlockedUser(blockedID: blockedUserID) { [weak self] isSuccess in
                    guard let self = self else { return }
                    
                    if isSuccess {
                        self.fetchComment()
                        print("Success Blocked user \(blockedUserID)")
                    }
                }
            }
            return UIMenu(title: "", children: [blockAction])
        }
    }
}
