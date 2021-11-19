//
//  ProfilePageViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/29.
//

import UIKit
import FirebaseAuth
import Lottie
import Kingfisher
import SafariServices

enum SettingSelection: String, CaseIterable {
    case toolStock = "材料庫存"
    case gardeningShop = "園藝店收藏"
    case acountManagement = "帳號管理"
    
    var iconImage: UIImage? {
        switch self {
        case .toolStock:
            return UIImage(systemName: "hammer.fill")
        case .gardeningShop:
            return UIImage(systemName: "house.fill")
        case .acountManagement:
            return UIImage(systemName: "gearshape")
        }
    }
}

class ProfilePageViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.registerCellWithNib(identifier: String(describing: ProfileTableViewCell.self), bundle: nil)
            tableView.registerCellWithNib(identifier: String(describing: HistoryTableViewCell.self), bundle: nil)
            tableView.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var imageContainer: UIView!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            let width = userImageView.frame.width
            userImageView.layer.cornerRadius = width / 2
            userImageView.applyshadowWithCorner(containerView: imageContainer, cornerRadious: width / 2)
        }
    }
    @IBOutlet weak var updatePhotoButton: UIImageView! {
        didSet {
            updatePhotoButton.layer.cornerRadius = updatePhotoButton.frame.width / 2
        }
    }
    
    @IBOutlet weak var updateNameButton: UIImageView!
    
    var plantCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .plain,
                                                                target: nil,
                                                                action: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectUserPhoto))
        userImageView.addGestureRecognizer(tap)
        userImageView.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let currentUser = UserManager.shared.currentUser {
            self.userNameTextField.text = currentUser.name
            if let imageURL = currentUser.userImageURL {
                self.userImageView.kf.setImage(with: URL(string: imageURL))
            }
        } else {
            self.userNameTextField.text = "使用者"
        }
        
        if let tabBarCon = self.tabBarController,
           let viewControllers = tabBarCon.viewControllers,
           let firstPageNVC = viewControllers.first as? UINavigationController,
           let firstPageVC = firstPageNVC.viewControllers.first,
           let homePageVC = firstPageVC as? HomePageViewController,
           let plants = homePageVC.plants {
            
            plantCount = plants.count
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
        
    @objc func selectUserPhoto() {
        let controller = UIAlertController(title: nil,
                                           message: nil,
                                           preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "從相簿選擇",
                                        style: .default) { _ in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                let imagePicker = UIImagePickerController()
                
                imagePicker.allowsEditing = true
                
                imagePicker.sourceType = .photoLibrary
                
                imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        let cameraAction = UIAlertAction(title: "開啟相機拍照",
                                         style: .default) { _ in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                let imagePicker = UIImagePickerController()
                
                imagePicker.allowsEditing = true
                
                imagePicker.sourceType = .camera
                
                imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消",
                                         style: .cancel,
                                         handler: nil)
        
        controller.addAction(photoAction)
        controller.addAction(cameraAction)
        controller.addAction(cancelAction)
        
        present(controller, animated: true, completion: nil)
    }
 
    @IBAction func endRenameAction(_ sender: UITextField) {
        guard let userName = sender.text else { return }
        UserManager.shared.updateUserInfo(userName: userName,
                                          userImageID: nil,
                                          userImageURL: nil) { isSuccess in
            if isSuccess {
                return
            }
        }
    }
    
}

extension ProfilePageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingSelection.allCases.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < 1 {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: HistoryTableViewCell.self),
                for: indexPath)
            
            guard let historyCell = cell as? HistoryTableViewCell else { return cell }
            
            let animationView = AnimationView(name: "72610-plantGrowing")
            
            animationView.loopMode = .autoReverse
            
            if let plantCount = plantCount,
               plantCount > 0 {
                
                historyCell.layoutCell(animationView: animationView,
                                       historyTitle: "目前紀錄了\(plantCount)棵植物！")
            } else {
                
                historyCell.layoutCell(animationView: animationView,
                                       historyTitle: "快回到首頁開始紀錄吧！")
            }
            
            return historyCell
            
        } else {
        
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ProfileTableViewCell.self),
                for: indexPath)
            
            guard let profileCell = cell as? ProfileTableViewCell else { return cell }
            
            let settingSelection = SettingSelection.allCases[indexPath.row - 1]
            
            let title = settingSelection.rawValue
            
            let image = settingSelection.iconImage
            
            profileCell.layoutCell(title: title, image: image)
            
            return profileCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.row > 0 else { return }
        
        let selectionType = SettingSelection.allCases[indexPath.row - 1]
        
        switch selectionType {
            
        case .toolStock:
            
            let storyBoard = UIStoryboard(name: "ToolStock", bundle: nil)
            
            let viewController = storyBoard.instantiateViewController(
                withIdentifier: String(describing: ToolStockViewController.self))
            
            guard let toolStockVC = viewController as? ToolStockViewController else { return }
            
            toolStockVC.modalPresentationStyle = .fullScreen
            
            self.navigationController?.pushViewController(toolStockVC, animated: true)
            
        case .gardeningShop:
            
            let storyBoard = UIStoryboard(name: "GardeningShopPage", bundle: nil)
            
            let viewController = storyBoard.instantiateViewController(
                withIdentifier: String(describing: GardeningShopViewController.self))
            
            guard let gardeningShopVC = viewController as? GardeningShopViewController else { return }
            
            gardeningShopVC.modalPresentationStyle = .fullScreen
            
            navigationController?.navigationBar.backgroundColor = .clear
            
            tabBarController?.tabBar.isHidden = true
            
            self.navigationController?.pushViewController(gardeningShopVC, animated: true)
            
        case .acountManagement:
            
            let storyBoard = UIStoryboard(name: "AccountSeetingPage", bundle: nil)
            let viewController = storyBoard.instantiateViewController(
                withIdentifier: String(describing: AccountSettingViewController.self))
            
            guard let accountingSettingVC = viewController as? AccountSettingViewController else { return }
            
            accountingSettingVC.modalPresentationStyle = .fullScreen
            
            self.navigationController?.pushViewController(accountingSettingVC, animated: true)
        }
    }
}

extension ProfilePageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            ImageManager.shared.uploadImageToGetURL(image: image) { result in
                switch result {
                case .success((let uuid, let url)):
                    UserManager.shared.updateUserInfo(userName: nil,
                                                      userImageID: uuid,
                                                      userImageURL: url) { isSuccess in
                        if isSuccess {
                            self.userImageView.image = image
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                case .failure(let error):
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
