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
    case sharePlants = "共享植物"
    case acountManagement = "帳號管理"
    
    var subTitle: String {
        switch self {
        case .userInfo:
            return "1"
        case .representPlant:
            return "2"
        case .toolStock:
            return "3"
        case .acountManagement:
            return "4"
        case .sharePlants:
            return "5"
        }
    }
    
    var iconImage: UIImage? {
        switch self {
        case .userInfo:
            return UIImage(systemName: "person.circle")
        case .representPlant:
            return UIImage(systemName: "leaf.fill")
        case .toolStock:
            return UIImage(systemName: "hammer.fill")
        case .acountManagement:
            return UIImage(systemName: "gearshape")
        case .sharePlants:
            return UIImage(systemName: "leaf.fill")
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
    
    var plantCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
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
                                       historyTitle: "已經紀錄了\(plantCount)棵植物！")
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
            
            let subTitle = settingSelection.subTitle
            
            let image = settingSelection.iconImage
            
            profileCell.layoutCell(title: title, subTitle: subTitle, image: image)
            
            return profileCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.row > 0 else { return }
        
        let selectionType = SettingSelection.allCases[indexPath.row - 1]
        
        switch selectionType {
        case .userInfo:
            break
        case .representPlant:
            break
        case .toolStock:
            break
        case .sharePlants:
            
            let storyBoard = UIStoryboard(name: "SharePlantPage", bundle: nil)
            
            let viewController = storyBoard.instantiateViewController(
                withIdentifier: String(describing: SharePlantViewController.self))
            
            guard let sharePlantVC = viewController as? SharePlantViewController else { return }
            
            sharePlantVC.modalPresentationStyle = .fullScreen
            
            self.navigationController?.pushViewController(sharePlantVC, animated: true)
            
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
