//
//  SettingPageViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/5.
//

import UIKit
import FirebaseAuth

enum AccountSetting: String, CaseIterable {
    case logOut = "登出"
    case deleteAccount = "刪除帳號"
    
    var iconImage: UIImage {
        get {
            switch self {
            case .logOut:
                if let image = UIImage(systemName: "person.fill.xmark") {
                    return image
                } else {
                    return UIImage()
                }
            case .deleteAccount:
                if let image = UIImage(systemName: "trash.fill") {
                    return image
                } else {
                    return UIImage()
                }
            }
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
        
        settingCell.layoutCell(title: title, subTitle: title, image: image)
        
        return settingCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
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
}
