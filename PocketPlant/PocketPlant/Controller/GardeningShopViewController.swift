//
//  GardeningShopViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/30.
//

import UIKit

class GardeningShopViewController: UIViewController {
    
    @IBOutlet weak var shopTableView: UITableView! {
        didSet {
            shopTableView.delegate = self
            shopTableView.dataSource = self
            shopTableView.registerCellWithNib(
                identifier: String(describing: GardeningShopTableViewCell.self),
                bundle: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension GardeningShopViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = shopTableView.dequeueReusableCell(
            withIdentifier: String(describing: GardeningShopTableViewCell.self),
            for: indexPath)
        
        guard let shopCell = cell as? GardeningShopTableViewCell else { return cell }
        
        return shopCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "detail") else { return }
        
        present(vc, animated: true, completion: nil)
    }
}
