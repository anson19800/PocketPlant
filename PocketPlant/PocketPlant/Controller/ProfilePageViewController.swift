//
//  ProfilePageViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/29.
//

import UIKit
import FirebaseAuth
import Lottie

enum SettingSelection: String, CaseIterable {
    case userInfo = "編輯個人資訊"
    case representPlant = "編輯代表植物"
    case toolStock = "材料庫存"
    case acountManagement = "帳號管理"
    
    func suntitle() -> String {
        switch self {
        case .userInfo:
            return "1"
        case .representPlant:
            return "2"
        case .toolStock:
            return "3"
        case .acountManagement:
            return "4"
        }
    }
    
    func iconImage() -> UIImage? {
        switch self {
        case .userInfo:
            return UIImage(systemName: "person.circle")
        case .representPlant:
            return UIImage(systemName: "leaf.fill")
        case .toolStock:
            return UIImage(systemName: "hammer.fill")
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
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            let width = userImageView.frame.width
            userImageView.layer.cornerRadius = width / 2
            userImageView.applyshadowWithCorner(containerView: imageContainer, cornerRadious: width / 2)
        }
    }
    
    @IBOutlet weak var logoutButton: UIButton! {
        didSet {
            logoutButton.layer.cornerRadius = 5
        }
    }
    
    var plantCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserManager.shared.fetchCurrentUserInfo { result in
            switch result {
            case .success(let user):
                self.userNameLabel.text = user.name
            case .failure(let error):
                self.userNameLabel.text = "使用者"
                print(error)
            }
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
    
    @IBAction func logOutAction(_ sender: UIButton) {
        
        let controller = UIAlertController(title: "登出提醒", message: "確定要登出嗎?", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "確定", style: .default) { _ in
            
            do {
                
                try Auth.auth().signOut()
                
                guard let loginVC = self.storyboard?.instantiateViewController(
                    withIdentifier: String(describing: LoginViewController.self))
                else { return }
                
                loginVC.modalPresentationStyle = .fullScreen
                
                self.present(loginVC, animated: true, completion: nil)
                
            } catch let signOutError as NSError {
                
               print("Error signing out: \(signOutError)")
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        controller.addAction(okAction)
        
        controller.addAction(cancelAction)
        
        present(controller, animated: true, completion: nil)
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
            
            animationView.loopMode = .loop
            
            if let plantCount = plantCount {
                
                historyCell.layoutCell(animationView: animationView,
                                       historyTitle: "已經紀錄了\(plantCount)棵植物！")
            } else {
                
                historyCell.layoutCell(animationView: animationView,
                                       historyTitle: "還沒紀錄植物。")
            }
            
            return historyCell
            
        } else {
        
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ProfileTableViewCell.self),
                for: indexPath)
            
            guard let profileCell = cell as? ProfileTableViewCell else { return cell }
            
            let settingSelection = SettingSelection.allCases[indexPath.row - 1]
            
            let title = settingSelection.rawValue
            
            let subTitle = settingSelection.suntitle()
            
            let image = settingSelection.iconImage()
            
            profileCell.layoutCell(title: title, subTitle: subTitle, image: image)
            
            return profileCell
        }
    }
}
