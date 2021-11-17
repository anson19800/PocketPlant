//
//  BlockedUserViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/13.
//

import UIKit

class BlockedUserViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.registerCellWithNib(identifier: String(describing: ProfileTableViewCell.self),
                                          bundle: nil)
        }
    }
    
    private var blockedUsers: [User]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.blockedUsers = nil
        getBlockUser()
    }
    
    func getBlockUser() {
        
        guard let blockedUserID = UserManager.shared.currentUser?.blockedUserID
        else { return }
        
        let group = DispatchGroup()
        
        blockedUserID.forEach { userID in
            group.enter()
            UserManager.shared.fetchUserInfo(userID: userID) { result in
                switch result {
                case .success(let blockedUser):
                    if var blockedUsers = self.blockedUsers {
                        blockedUsers.append(blockedUser)
                        self.blockedUsers = blockedUsers
                        group.leave()
                    } else {
                        self.blockedUsers = [blockedUser]
                        group.leave()
                    }
                case .failure(let error):
                    print(error)
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }
}

extension BlockedUserViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let blockedUser = self.blockedUsers else { return 0 }
        return blockedUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileTableViewCell.self),
                                                 for: indexPath)
        
        guard let userCell = cell as? ProfileTableViewCell,
              let blockedUsers = self.blockedUsers else { return cell }
        
        let user = blockedUsers[indexPath.row]
        
        if let name = user.name {
            
            userCell.layoutCell(title: name, imageURL: user.userImageURL)
        }
        
        return userCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            guard var blockedUsers = self.blockedUsers else { return }
            
            let blockedUserID = blockedUsers[indexPath.row].userID
            
            blockedUsers.remove(at: indexPath.row)
            
            self.blockedUsers = blockedUsers
            
            UserManager.shared.deleteBlockedUser( blockedUserID: blockedUserID) { isSuccess in
                    
                    if isSuccess {
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
        }
    }
    
}
