//
//  ViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/18.
//

import UIKit
import FirebaseAuth

enum HomePageButton: String, CaseIterable {
    case myPlant = "我的植物"
    case myFavorite = "最愛植物"
    case gardeningShop = "園藝店"
}

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.autocapitalizationType = .none
            searchBar.placeholder = "搜尋"
            searchBar.backgroundImage = UIImage()
            searchBar.searchTextField.backgroundColor = .white
            searchBar.searchTextField.layer.cornerRadius = 15
            searchBar.searchTextField.layer.shadowColor = UIColor.black.cgColor
            searchBar.searchTextField.layer.shadowOffset = CGSize.zero
            searchBar.searchTextField.layer.shadowRadius = 4
            searchBar.searchTextField.layer.shadowOpacity = 0.1
        }
    }
    
    @IBOutlet weak var headerBackground: UIView! {
        didSet {
            headerBackground.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var plantCollectionView: UICollectionView!
    
    @IBOutlet weak var buttonCollectionView: UICollectionView!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var qrcodeButton: UIButton!
    
    @IBOutlet weak var homeTitleLabel: UILabel!
    
    let firebaseManager = FirebaseManager.shared
    
    var plants: [Plant]?
    
    var searchPlants: [Plant]?
    
    var searching: Bool = false
    
    var isSelectedAt: HomePageButton = .myPlant
    
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var waterImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
              if let userName = user.displayName {
                self.homeTitleLabel.text = "Hi！\(userName)"
              } else {
                self.homeTitleLabel.text = "Hi！歡迎"
              }
            } else {
                self.homeTitleLabel.text = "Hi！訪客"
            }
        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .plain,
                                                                target: nil,
                                                                action: nil)
        
        plantCollectionView.delegate = self
        plantCollectionView.dataSource = self
        buttonCollectionView.delegate = self
        buttonCollectionView.dataSource = self
        searchBar.delegate = self
        buttonCollectionView.layer.masksToBounds = false
        
        buttonCollectionView.registerCellWithNib(
            identifier: String(describing: ButtonCollectionViewCell.self),
            bundle: nil)
        
        plantCollectionView.registerCellWithNib(
            identifier: String(describing: PlantCollectionViewCell.self),
            bundle: nil)
        
        buttonCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        
        updateMyPlants(withAnimation: false)
        
        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height
        waterImageView.center = CGPoint(x: viewWidth - 50, y: viewHeight - 130)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch isSelectedAt {
            
        case .myPlant:
            
            updateMyPlants(withAnimation: false)
            
        case .myFavorite:
            
            updateMyFavoritePlants(withAnimation: false)
            
        case .gardeningShop:
            
            buttonCollectionView.selectItem(at: IndexPath(row: 0, section: 0),
                                            animated: false,
                                            scrollPosition: .top)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.searchBar.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.searchBar.endEditing(true)
    }
    
    func updateMyPlants(withAnimation: Bool) {
        
        firebaseManager.fetchPlants { result in
            
            switch result {
                
            case .success(let plants):
                
                self.plants = plants
                
                if withAnimation {
                
                    self.plantCollectionView.performBatchUpdates({
                        let indexSet = IndexSet(integersIn: 0...0)
                        self.plantCollectionView.reloadSections(indexSet)
                    }, completion: nil)
                    
                } else {
                    
                    self.plantCollectionView.reloadData()
                    
                }
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func updateMyFavoritePlants(withAnimation: Bool) {
        
        firebaseManager.fetchFavoritePlants { result in
            
            switch result {
                
            case .success(let plants):
                
                self.plants = plants
                
                if withAnimation {
                    
                    self.plantCollectionView.performBatchUpdates({
                        let indexSet = IndexSet(integersIn: 0...0)
                        self.plantCollectionView.reloadSections(indexSet)
                    }, completion: nil)
                    
                } else {
                    
                    self.plantCollectionView.reloadData()
                    
                }
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func deletePlantAction(indexPath: IndexPath) {
        
        guard var plants = plants else { return }
        
        let plant = plants[indexPath.row]
        
        plants.remove(at: indexPath.row)
        
        self.plants = plants

        firebaseManager.deletePlant(plant: plant)
        
        plantCollectionView.deleteItems(at: [indexPath])
    }
    
    func editPlantAction(indexPath: IndexPath) {
        
        guard let plants = plants else { return }
        
        let plant = plants[indexPath.row]
        
        performSegue(withIdentifier: "editPlant", sender: plant)
        
    }
    
    func deathPlantAction(indexPath: IndexPath) {
        
        guard let plants = plants else { return }
        
        let plant = plants[indexPath.row]
        
        performSegue(withIdentifier: "deathPlant", sender: plant)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
        case "showPlantDetail":
            
            guard let destinationVC = segue.destination as? PlantDetailViewController,
                  let plant = sender as? Plant else { return }
            
            destinationVC.plant = plant
            
        case "createPlant":
            
            guard let destinationNVC = segue.destination as? UINavigationController,
                  let destinationVC = destinationNVC.viewControllers.first,
                  let newPlantVC = destinationVC as? NewPlantPageViewController else { return }
            
            newPlantVC.pageMode = .create
            
            newPlantVC.parentVC = self
            
        case "editPlant":
            
            guard let destinationNVC = segue.destination as? UINavigationController,
                  let destinationVC = destinationNVC.viewControllers.first as? NewPlantPageViewController,
                  let plant = sender as? Plant else { return }
            
            destinationVC.pageMode = .edit(editedPlant: plant)
            
            destinationVC.parentVC = self
            
        case "deathPlant":
            
            guard let destinationVC = segue.destination as? DeathPlantViewController,
                  let plant = sender as? Plant else { return }
            
            destinationVC.plant = plant
            
        case "showShop":
            
            break

        default:
            
            break
        }
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        
        guard let plants = plants else { return }
        
        var waterCount = 0
        plants.forEach({ plant in
            firebaseManager.updateWater(plant: plant) { isSuccess in
                if isSuccess {
                    waterCount += 1
                    print("\(waterCount) / \(plants.count)")
                }
            }
        })
        
        let controller = UIAlertController(title: "一鍵澆水",
                                           message: "對畫面上所有植物澆水",
                                           preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
        
    }
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        
        guard let dropView = sender.view else { return }
        
        UIView.animate(withDuration: 0.1) {() -> Void in
            dropView.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
        
        let translation = sender.translation(in: view)
        dropView.center.x += translation.x
        dropView.center.y += translation.y
        sender.setTranslation(.zero, in: view)
        
        if sender.state == .ended {
            
            dropView.isUserInteractionEnabled = false
            
            let point = dropView.convert(CGPoint.zero, to: self.plantCollectionView)
            
            UIView.animate(withDuration: 0.3, animations: {
                
                dropView.transform = CGAffineTransform(scaleX: 1, y: 1)
                
                let safeX = self.view.bounds.size.width - 50
                let safeY = self.view.bounds.size.height - 130
                
                dropView.center = CGPoint(x: safeX, y: safeY)
                
            }, completion: nil)
            
            if let indexPath = plantCollectionView.indexPathForItem(at: point),
               let plants = self.plants {
                let plantName = plants[indexPath.row].name
                
                firebaseManager.updateWater(plant: plants[indexPath.row]) { isSuccess in
                    
                    if isSuccess {
                        
                        self.waterAlert(plantName: plantName)
                        
                        dropView.isUserInteractionEnabled = true
                        
                    }
                }
            } else {
                
                dropView.shake()
                
                dropView.isUserInteractionEnabled = true
            }
        }
    }
    
    func waterAlert(plantName: String) {
        
        let controller = UIAlertController(title: "已紀錄",
                                           message: "對\(plantName)澆水",
                                           preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
}

// MARK: - CollectionViewDelegate & CollectionViewDataSource
extension HomePageViewController: UICollectionViewDelegate, UICollectionViewDataSource,
                                  UICollectionViewDelegateFlowLayout {
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        searchBar.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == buttonCollectionView {
            
            return HomePageButton.allCases.count
            
        } else {
            
            if searching {
                
                guard let searchPlants = self.searchPlants else { return 0 }
                
                return searchPlants.count
                
            } else {
                
                guard let plants = self.plants else { return 0 }
                
                return plants.count
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == buttonCollectionView {
            
            let cell = buttonCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: ButtonCollectionViewCell.self),
                for: indexPath
            )
            
            guard let buttonCell = cell as? ButtonCollectionViewCell else { return cell }
            
            let title = HomePageButton.allCases[indexPath.row].rawValue
            
            buttonCell.layoutCell(image: UIImage(systemName: "leaf.fill")!, title: title)
            
            return buttonCell
            
        } else if collectionView == plantCollectionView {
            
            let cell = plantCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: PlantCollectionViewCell.self),
                for: indexPath
            )
            
            guard let plantCell = cell as? PlantCollectionViewCell else { return cell }
            
            if searching {
                
                guard let searchPlants = self.searchPlants,
                      let imageURL = searchPlants[indexPath.row].imageURL
                else { return cell }
                
                plantCell.layoutCell(imageURL: imageURL,
                                     name: searchPlants[indexPath.row].name)
                
                return plantCell
                
            } else {
                
                guard let plants = self.plants,
                      let imageURL = plants[indexPath.row].imageURL
                else { return cell }
                
                plantCell.layoutCell(imageURL: imageURL,
                                     name: plants[indexPath.row].name)
                
                return plantCell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemSpace: CGFloat = 10
        let columCount: CGFloat = 3
        
        let plantWidth = floor( (plantCollectionView.bounds.width - itemSpace * (columCount - 1)) / columCount )
        
        let buttonWidth = floor((buttonCollectionView.bounds.width - itemSpace * (columCount - 1)) / columCount )

        if collectionView == plantCollectionView {
            return CGSize(width: plantWidth, height: plantWidth * 1.2)
        } else {
            return CGSize(width: buttonWidth, height: buttonWidth)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchBar.endEditing(true)
        
        if collectionView == plantCollectionView {
        
            guard let plants = self.plants else { return }
        
            let plant = plants[indexPath.row]
            
            tabBarController?.tabBar.isHidden = true
        
            performSegue(withIdentifier: "showPlantDetail", sender: plant)
            
        } else if collectionView == buttonCollectionView {
            
            let buttonType = HomePageButton.allCases[indexPath.row]
            
            switch buttonType {
                
            case .myPlant:
                
                if isSelectedAt == .myPlant {
                    
                    break
                    
                }
                
                updateMyPlants(withAnimation: true)
                
                self.isSelectedAt = .myPlant
                
            case .myFavorite:
                
                if isSelectedAt == .myFavorite {
                    
                    break
                    
                }
                
                searching = false
                
                updateMyFavoritePlants(withAnimation: true)
                
                isSelectedAt = .myFavorite
                
            case .gardeningShop:
                
                isSelectedAt = .gardeningShop
                
                searching = false
                
                tabBarController?.tabBar.isHidden = true
                
                performSegue(withIdentifier: "shopList", sender: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard collectionView == plantCollectionView else { return nil }
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) { _ in
            
            let deleteAction = UIAction(title: "刪除",
                                        image: UIImage(systemName: "trash"),
                                        attributes: .destructive) { _ in
                
                self.deletePlantAction(indexPath: indexPath)
                
            }
            
            let editAction = UIAction(title: "編輯", image: nil) { _ in
                
                self.editPlantAction(indexPath: indexPath)
                
            }
            
            let deathAction = UIAction(title: "澆水紀錄", image: nil) { _ in
                
                self.deathPlantAction(indexPath: indexPath)
                
            }
            
            return UIMenu(title: "", children: [editAction, deathAction, deleteAction])
        }
    }
}

extension HomePageViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard let plants = plants else { return }
        
        searchPlants = plants.filter { plant -> Bool in
            
            return plant.name.prefix(searchText.count) == searchText
            
        }
        
        searching = true
        
        self.plantCollectionView.performBatchUpdates({
            let indexSet = IndexSet(integersIn: 0...0)
            self.plantCollectionView.reloadSections(indexSet)
        }, completion: nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searching = false
        
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
    }
}
