//
//  SettingPageViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/5.
//

import UIKit
import FirebaseAuth
import SafariServices

enum AccountSetting: String, CaseIterable {
    case logOut = "登出"
    case blockedList = "封鎖用戶"
    case privacyPolicy = "隱私權政策"
    case deleteAccount = "刪除帳號"
    
    var iconImage: UIImage? {
        switch self {
        case .logOut:
            return UIImage(systemName: "clear.fill")
        case .blockedList:
            return UIImage(systemName: "person.fill.xmark")
        case .deleteAccount:
            return UIImage(systemName: "trash.fill")
        case .privacyPolicy:
            return UIImage(systemName: "exclamationmark.circle.fill")
        }
    }
}

class AccountSettingViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.registerCellWithNib(identifier: String(describing: ProfileTableViewCell.self),
                                          bundle: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension AccountSettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountSetting.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ProfileTableViewCell.self),
            for: indexPath)
        
        guard let settingCell = cell as? ProfileTableViewCell else { return cell }
        
        let settingType = AccountSetting.allCases[indexPath.row]
        
        let title = settingType.rawValue
        
        let image = settingType.iconImage
        
        settingCell.layoutCell(title: title, image: image)
        
        if settingType == .deleteAccount {
            settingCell.iconImageView.tintColor = .red
            settingCell.titleLabel.textColor = .red
        }
        
        return settingCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if Auth.auth().currentUser == nil {
            
            showLoginAlert()
            
            return
            
        }
        
        let selection = AccountSetting.allCases[indexPath.row]
        
        switch selection {
        case .logOut:
            
            logOutAction()
            
        case .blockedList:
            
            guard let blockedListVC = self.storyboard?.instantiateViewController(
                withIdentifier: String(describing: BlockedUserViewController.self)) as? BlockedUserViewController
            else { return }
            
            self.navigationController?.pushViewController(blockedListVC, animated: true)
            
        case .deleteAccount:
            
            showAlert(title: "刪除帳號", message: "如果您需要刪除帳號請來信\nanson19800@gmail.com\n感謝您！", buttonTitle: "確認")
            
        case .privacyPolicy:
            
            let privacyPolicyLink = "https://www.privacypolicies.com/live/25920b7a-f6fc-42f1-a6d9-e2a709e1a5fe"
            
            if let url = URL(string: privacyPolicyLink) {
                let safariController = SFSafariViewController(url: url)
                present(safariController, animated: true, completion: nil)
            }
            
        }
    }
    
    func logOutAction() {
        let controller = UIAlertController(title: "登出提醒", message: "確定要登出嗎?", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "確定", style: .default) { _ in
            
            do {
                
                try Auth.auth().signOut()
                let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = mainStoryBoard.instantiateViewController(
                    withIdentifier: String(describing: LoginViewController.self))
                
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
