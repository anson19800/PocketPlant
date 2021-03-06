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
    
    var shops: [GardeningShop]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .plain,
                                                                target: nil,
                                                                action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseManager.shared.fetchShops { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let shops):
                self.shops = shops
                self.shopTableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension GardeningShopViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let shops = shops else { return 0 }
        return shops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = shopTableView.dequeueReusableCell(
            withIdentifier: String(describing: GardeningShopTableViewCell.self),
            for: indexPath)
        
        guard let shopCell = cell as? GardeningShopTableViewCell,
              let shops = shops else { return cell }
        
        shopCell.layoutCell(gardeningShop: shops[indexPath.row])
        
        return shopCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let nextPageVC = storyboard?.instantiateViewController(
            withIdentifier: String(describing: ShopDetailViewController.self)),
              let detailPageVC = nextPageVC as? ShopDetailViewController,
              let shops = shops else { return }
        
        detailPageVC.shop = shops[indexPath.row]
        
        detailPageVC.modalPresentationStyle = .overCurrentContext
        
        navigationController?.pushViewController(detailPageVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            guard var shops = self.shops,
                  let shopID = shops[indexPath.row].id else { return }
            FirebaseManager.shared.deleteData(.shop, dataID: shopID) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    shops.remove(at: indexPath.row)
                    self.shops = shops
                    tableView.deleteRows(at: [indexPath], with: .fade)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
