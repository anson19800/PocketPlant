//
//  PlantDetailViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/19.
//

import UIKit
import Kingfisher

class PlantDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.registerCellWithNib(
                identifier: String(describing: PlantDetailTableViewCell.self),
                bundle: nil)
            
            tableView.registerCellWithNib(
                identifier: String(describing: CommentTitleTableViewCell.self),
                bundle: nil)
            
            tableView.registerCellWithNib(
                identifier: String(describing: CommentTableViewCell.self),
                bundle: nil)
            
        }
    }
    
    @IBOutlet weak var infoView: UIView! {
        didSet {
            infoView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            infoView.layer.cornerRadius = 30
            infoView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var plantNameLabel: UILabel!
    
    @IBOutlet weak var plantCategoryLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton! {
        didSet {
            favoriteButton.layer.cornerRadius = favoriteButton.frame.width / 2
        }
    }
    @IBOutlet weak var qrcodeButton: UIImageView! {
        didSet {
            qrcodeButton.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var plantPhotoImageView: UIImageView!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var remindButton: UIButton! {
        didSet {
            remindButton.layer.cornerRadius = remindButton.frame.width / 2
        }
    }
    
    var plant: Plant?
    
    var comments: [Comment]?
    
    var commentUser: [String: User] = [:]
    
    let firebaseManager = FirebaseManager.shared
    
    let commentManager = CommentManager.shared
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        guard let plant = plant,
              let imageUrl = plant.imageURL else { return }
        
        plantNameLabel.text = plant.name
        
        plantCategoryLabel.text = plant.category
        
        favoriteButton.tintColor = plant.favorite ? .red : .gray
        
        plantPhotoImageView.kf.setImage(with: URL(string: imageUrl))
        
        if plant.ownerID != UserManager.shared.userID {
            remindButton.isHidden = true
            favoriteButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchComment()
    }
    
    func fetchComment() {
        guard let plant = plant else { return }
        
        commentManager.fetchComment(type: .plant,
                                    objectID: plant.id) { result in
            switch result {
                
            case .success(let comments):
                
                self.comments = comments
                
                let group = DispatchGroup()
                
                comments.forEach { comment in
                    
                    group.enter()
                    
                    if self.commentUser[comment.senderID] == nil {
                        UserManager.shared.fetchUserInfo(userID: comment.senderID) { result in
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
                        self.tableView.reloadSections(indexSet, with: .none)
                    }
                }
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    @IBAction func addToFavorite(_ sender: UIButton) {
        
        guard var plant = plant else { return }
        
        firebaseManager.switchFavoritePlant(plantID: plant.id) { result in
            
            switch result {
                
            case .success(_):
                
                plant.favorite = !plant.favorite
                
                self.plant = plant
                
                self.favoriteButton.tintColor = plant.favorite ? .red : .gray
                
            case .failure(let error):
                
                print(error)
                
            }
        }
    }
    
    @IBAction func showRemindFloating(_ sender: UIButton) {
        
        let storyBoard = UIStoryboard(name: "RemindPage", bundle: nil)
        
        guard let remindVC = storyBoard.instantiateViewController(
            withIdentifier: String(describing: RemindViewController.self)) as? RemindViewController else { return }
        
        remindVC.modalTransitionStyle = .crossDissolve
        remindVC.modalPresentationStyle = .overCurrentContext
        remindVC.plant = self.plant
        remindVC.delegate = self
        present(remindVC, animated: true, completion: nil)
        
    }
    
    @IBAction func tapOnQRCode(_ sender: UITapGestureRecognizer) {
        
        guard let plant = plant else {
            return
        }

        let qrcodePage = storyboard?.instantiateViewController(
            withIdentifier: String(describing: ShowQRCodePageViewController.self))
        
        guard let qrcodePageVC = qrcodePage as? ShowQRCodePageViewController else { return }
        
        qrcodePageVC.modalTransitionStyle = .crossDissolve
        
        qrcodePageVC.modalPresentationStyle = .overCurrentContext
        
        qrcodePageVC.plantID = plant.id
        
        present(qrcodePageVC, animated: true, completion: nil)
    }
    
    @IBAction func publishAction(_ sender: UIButton) {
        guard let plant = plant,
              let comment = commentTextField.text else { return }
        
        if comment != "" {
            let comment = Comment(commentType: .plant,
                                  objectID: plant.id,
                                  content: comment,
                                  createdTime: Date().timeIntervalSince1970)
            
            commentManager.publishComment(comment: comment) { isSuccess in
                
                if isSuccess {
                    
                    self.fetchComment()
                    
                    self.commentTextField.text = ""
                    
                    self.view.endEditing(true)
                    
                    if let comments = comments,
                       comments.count != 0 {
                        
                        self.tableView.scrollToRow(at: IndexPath(row: 2, section: 0), at: .top, animated: false)
                    }
                    
                } else {
                    showAlert(title: "發送失敗", message: "發送的過程出了點問題，請再試一次！", buttonTitle: "確定")
                }
            }
        }
    }
}

extension PlantDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let comments = comments else { return 1 }
        
        return comments.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
        
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: PlantDetailTableViewCell.self),
                for: indexPath)
            
            guard let detailCell = cell as? PlantDetailTableViewCell,
                  let plant = self.plant else { return cell }
            
            detailCell.layoutCell(plant: plant)
            
            return detailCell
            
        } else if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: CommentTitleTableViewCell.self),
                for: indexPath)
            
            guard let titleCell = cell as? CommentTitleTableViewCell,
                  let comments = comments else { return cell }
            
            titleCell.layoutCell(commentCount: comments.count)
            
            return titleCell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: CommentTableViewCell.self),
                for: indexPath)
            
            guard let commentCell = cell as? CommentTableViewCell,
                  let comments = comments else { return cell }
            
            let comment = comments[indexPath.row - 2]
            
            if let user = self.commentUser[comment.senderID] {
                
                commentCell.layoutCell(comment: comment, user: user)
                
            } else {
                
                commentCell.layoutCell(comment: comment, user: nil)
                
            }
            
            return commentCell
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard indexPath.row > 1 else { return nil }
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) { _ in
            
            let blockAction = UIAction(title: "封鎖使用者",
                                        image: UIImage(systemName: "person.fill.xmark"),
                                        attributes: .destructive) { _ in
                
                let commentIndex = indexPath.row - 2
                
                guard let comments = self.comments else { return }
                
                let comment = comments[commentIndex]
                
                let blockedUserID = comment.senderID
                
                UserManager.shared.addBlockedUser(blockedID: blockedUserID) { isSuccess in
                    if isSuccess {
                        print("Success Blocked user \(blockedUserID)")
                    }
                }
            }
            return UIMenu(title: "", children: [blockAction])
        }
    }
}

extension PlantDetailViewController: RemindDelegate {
    func updateRemind(plant: Plant) {
        self.plant = plant
    }
}
