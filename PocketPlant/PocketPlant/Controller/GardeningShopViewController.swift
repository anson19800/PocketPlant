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
    
    let shops: [GardeningShop] = [
        GardeningShop(name: "竹藝花坊",
                      address: "台中市潭子區昌平路三段352巷8號"),
        GardeningShop(name: "信和園藝",
                      address: "桃園市平鎮區振興西路6號"),
        GardeningShop(name: "富國園藝花卉坊",
                      address: "桃園市中壢區後寮二路350號1樓"),
        GardeningShop(name: "快栽園藝",
                      address: "桃園市中壢區民權路三段852號")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .plain,
                                                                target: nil,
                                                                action: nil)
    }
}

extension GardeningShopViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = shopTableView.dequeueReusableCell(
            withIdentifier: String(describing: GardeningShopTableViewCell.self),
            for: indexPath)
        
        guard let shopCell = cell as? GardeningShopTableViewCell else { return cell }
        
        shopCell.layoutCell(gardeningShop: shops[indexPath.row])
        
        return shopCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let nextPageVC = storyboard?.instantiateViewController(withIdentifier: "detail"),
              let detailPageVC = nextPageVC as? ShopDetailViewController else { return }
        
        detailPageVC.shop = shops[indexPath.row]
        
        detailPageVC.modalPresentationStyle = .overCurrentContext
        
        navigationController?.pushViewController(detailPageVC, animated: true)
    }
}
