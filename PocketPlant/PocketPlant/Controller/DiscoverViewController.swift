//
//  DiscoverViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/29.
//

import UIKit

enum DiscoverType: CaseIterable {
    case plant
    case shop
    
    var type: Any {
        switch self {
        case .plant:
            return Plant.self
        case .shop:
            return GardeningShop.self
        }
    }
}

class DiscoverViewController: UIViewController {
    
    @IBOutlet weak var discoverCollectionView: UICollectionView! {
        didSet {
            discoverCollectionView.registerCellWithNib(
                identifier: String(describing: PlantCollectionViewCell.self),
                bundle: nil)
            discoverCollectionView.delegate = self
            discoverCollectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var animationContainer: UIView!
    @IBOutlet weak var emptyLabel: UILabel! {
        didSet {
            emptyLabel.text = "Oops!現在好像沒東西，晚點再來看看吧！"
        }
    }
    
    var discoverObject: [Any]? {
        didSet {
            checkEmpty()
        }
    }
    
    var discoverType: DiscoverType = .plant
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureEmptyAnimation(containerView: animationContainer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func fetchData() {
        
        switch discoverType {
            
        case .plant:
            FirebaseManager.shared.fetchDiscoverObject(
                discoverType,
                completion: { [weak self] (plants: [Plant]?, error: Error?) in
                    guard let self = self else { return }
                
                    if let error = error {
                        print(error)
                    }
                    
                    let anyPlants = self.blockedObject(type: .plant, object: plants)
                    
                    if let anyPlants = anyPlants,
                       let plants = anyPlants as? [Plant] {
                        self.discoverObject = plants.shuffled()
                        self.discoverCollectionView.performBatchUpdates({
                            let indexSet = IndexSet(integersIn: 0...0)
                            self.discoverCollectionView.reloadSections(indexSet)
                        }, completion: nil)
                    }
                    
            })
        case .shop:
            FirebaseManager.shared.fetchDiscoverObject(
                discoverType,
                completion: { (shops: [GardeningShop]?, error: Error?) in
                    
                    if let error = error {
                        print(error)
                    }
                    
                    let anyShops = self.blockedObject(type: .shop, object: shops)
                    
                    if let anyShops = anyShops,
                       let shops = anyShops as? [GardeningShop] {
                        self.discoverObject = shops.shuffled()
                        self.discoverCollectionView.performBatchUpdates({
                            let indexSet = IndexSet(integersIn: 0...0)
                            self.discoverCollectionView.reloadSections(indexSet)
                        }, completion: nil)
                    }
                    
                })
        }
    }
    
    private func blockedObject<T>(type: DiscoverType, object: T) -> Any? {
        switch type {
        case .plant:
            
            if let blockedUserID = UserManager.shared.currentUser?.blockedUserID {
                
                guard let plants = object as? [Plant] else { return nil }
                
                let blockedPlants = plants.filter { plant in
                    !(blockedUserID.contains(plant.ownerID))
                }
                
                return blockedPlants
                
            } else {
                return object
            }
        case .shop:
            
            if let blockedUserID = UserManager.shared.currentUser?.blockedUserID {
                
                guard let shops = object as? [GardeningShop] else { return nil }
                
                let blockedShops = shops.filter { shops in
                    !(blockedUserID.contains(shops.ownerID))
                }
                
                return blockedShops
                
            } else {
                
                return object
                
            }
        }
    }
    
    @IBAction func switchType(_ sender: UISegmentedControl) {
        
        switch discoverType {
            
        case .plant:
            
            discoverType = .shop
            
            fetchData()
            
        case .shop:
            
            discoverType = .plant
            
            fetchData()
            
        }
    }
    private func checkEmpty() {
        if let discoverObject = discoverObject {
            
            animationContainer.isHidden = !(discoverObject.count <= 0)
            
            emptyLabel.isHidden = !(discoverObject.count <= 0)
            
        } else {
            
            animationContainer.isHidden = false
            emptyLabel.isHidden = false
        }
    }
}

extension DiscoverViewController: UICollectionViewDataSource,
                                  UICollectionViewDelegate,
                                  UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let discoverObject = discoverObject else { return 0 }
        
        return discoverObject.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: PlantCollectionViewCell.self),
            for: indexPath)
        
        guard let discoverCell = cell as? PlantCollectionViewCell,
              let discoverObject = discoverObject else { return cell }
        
        let object = discoverObject[indexPath.row]
        
        switch discoverType {
        case .plant:
            
            guard let plant = object as? Plant else { return cell }
            
            discoverCell.layoutCell(imageURL: plant.imageURL, name: plant.name)
            
            return discoverCell
            
        case .shop:
            
            guard let shop = object as? GardeningShop else { return cell }
            
            discoverCell.layoutCell(imageURL: shop.images?.first, name: shop.name)
            
            return discoverCell
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemSpace: CGFloat = 10
        
        let columCount: CGFloat = 3
        
        let width = floor((collectionView.bounds.width - itemSpace * (columCount - 1)) / columCount )
        
        return CGSize(width: width, height: width * 1.2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let discoverObjects =  discoverObject else { return }
        
        switch discoverType {
        case .plant:
            
            guard let plants = discoverObjects as? [Plant] else { return }
            
            let plant = plants[indexPath.row]
            
            let storyboard = UIStoryboard(name: "PlantDetailPage", bundle: nil)
            
            let plantDetailVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: PlantDetailViewController.self))
            
            guard let plantDetailVC = plantDetailVC as? PlantDetailViewController else { return }
            
            plantDetailVC.plant = plant
            
            guard let navigationCon = self.navigationController else { return }
            
            tabBarController?.tabBar.isHidden = true
            
            navigationCon.pushViewController(plantDetailVC, animated: true)
            
        case .shop:
            
            guard let shops = discoverObjects as? [GardeningShop] else { return }
            
            let shop = shops[indexPath.row]
            
            let storyboard = UIStoryboard(name: "GardeningShopPage", bundle: nil)
            
            let shopDetailVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: ShopDetailViewController.self))
            
            guard let shopDetailVC = shopDetailVC as? ShopDetailViewController else { return }
            
            shopDetailVC.shop = shop
            
            guard let navigationCon = self.navigationController else { return }
            
            tabBarController?.tabBar.isHidden = true
            
            navigationCon.pushViewController(shopDetailVC, animated: true)
        }
    }
}
