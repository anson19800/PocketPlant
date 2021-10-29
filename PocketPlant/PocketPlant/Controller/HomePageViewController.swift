//
//  ViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/18.
//

import UIKit

enum HomePageButton: String, CaseIterable {
    case myPlant = "我的植物"
    case myFavorite = "最愛植物"
}

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var plantCollectionView: UICollectionView!
    
    @IBOutlet weak var buttonCollectionView: UICollectionView!
    
    @IBOutlet weak var addButton: UIButton! {
        didSet {
            addButton.titleLabel?.text = ""
        }
    }
    
    @IBOutlet weak var qrcodeButton: UIButton! {
        didSet {
            qrcodeButton.titleLabel?.text = ""
        }
    }
    
    let firebaseManager = FirebaseManager.shared
    
    var plants: [Plant]?
    
    var isSelectedAt: HomePageButton = .myPlant
    
    @IBOutlet weak var plantCollectionTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        plantCollectionView.delegate = self
        plantCollectionView.dataSource = self
        buttonCollectionView.delegate = self
        buttonCollectionView.dataSource = self
        
        buttonCollectionView.registerCellWithNib(
            identifier: String(describing: ButtonCollectionViewCell.self),
            bundle: nil)
        
        plantCollectionView.registerCellWithNib(
            identifier: String(describing: PlantCollectionViewCell.self),
            bundle: nil)
        
        updateMyPlants(withAnimation: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        
        switch isSelectedAt {
            
        case .myPlant:
            
            updateMyPlants(withAnimation: false)
            
        case .myFavorite:
            
            updateMyFavoritePlants(withAnimation: false)
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
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
                
                self.plantCollectionTitle.text = "我的植物"
                
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
                
                self.plantCollectionTitle.text = "最愛植物"
                
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
        case "showPlantDetail":
            
            guard let destinationVC = segue.destination as? PlantDetailViewController,
                  let plant = sender as? Plant else { return }
            
            destinationVC.plant = plant
            
        case "createPlant":
            
            guard let destinationVC = segue.destination as? NewPlantPageViewController else { return }
            
            destinationVC.pageMode = .create
            
        case "editPlant":
            
            guard let destinationNVC = segue.destination as? UINavigationController,
                  let destinationVC = destinationNVC.viewControllers.first as? NewPlantPageViewController,
                  let plant = sender as? Plant else { return }
            
            destinationVC.pageMode = .edit(editedPlant: plant)
            
        default:
            
            break
        }
    }
    
}

// MARK: - CollectionViewDelegate & CollectionViewDataSource
extension HomePageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == buttonCollectionView {
            
            return HomePageButton.allCases.count
            
        } else {
            
            guard let plants = self.plants else { return 0 }
            
            return plants.count
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
            
            if indexPath.row == 0 {
                
                buttonCell.isSelected = true
                
            }
            
            let title = HomePageButton.allCases[indexPath.row].rawValue
            
            buttonCell.layoutCell(image: UIImage(systemName: "leaf.fill")!, title: title)
            
            return buttonCell
            
        } else if collectionView == plantCollectionView {
            
            let cell = plantCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: PlantCollectionViewCell.self),
                for: indexPath
            )
            
            guard let plantCell = cell as? PlantCollectionViewCell,
                  let plants = self.plants,
                  let imageURL = plants[indexPath.row].imageURL else { return cell }
            
            plantCell.layoutCell(imageURL: imageURL,
                                 name: plants[indexPath.row].name)
            
            return plantCell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemSpace: CGFloat = 10
        let columCount: CGFloat = 3
        
        let width = floor( (plantCollectionView.bounds.width - itemSpace * (columCount - 1)) / columCount )

        return CGSize(width: width, height: width * 1.8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == plantCollectionView {
        
            guard let plants = self.plants else { return }
        
            let plant = plants[indexPath.row]
        
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
                
                updateMyFavoritePlants(withAnimation: true)
                
                self.isSelectedAt = .myFavorite
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) { _ in
            
            let deleteAction = UIAction(title: "刪除",
                                        image: UIImage(systemName: "trash"),
                                        attributes: .destructive) { _ in
                
                self.deletePlantAction(indexPath: indexPath)
                
            }
            
            let editAction = UIAction(title: "編輯",
                                      image: nil,
                                      attributes: .destructive) { _ in
                
                self.editPlantAction(indexPath: indexPath)
                
            }
            
            return UIMenu(title: "", children: [deleteAction, editAction])
        }
        
    }
    
}
