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
        
        updateMyPlants()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        
        updateMyPlants()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func updateMyPlants() {
        
        firebaseManager.fetchPlants { result in
            
            switch result {
                
            case .success(let plants):
                
                self.plants = plants
                
                self.plantCollectionView.reloadData()
                
                self.plantCollectionTitle.text = "我的植物"
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func updateMyFavoritePlants() {
        
        firebaseManager.fetchFavoritePlants { result in
            
            switch result {
                
            case .success(let plants):
                
                self.plants = plants
                
                self.plantCollectionView.reloadData()
                
                self.plantCollectionTitle.text = "最愛植物"
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
}

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
                
                updateMyPlants()
                
            case .myFavorite:
                
                updateMyFavoritePlants()
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destinationVC = segue.destination as? PlantDetailViewController,
              let plant = sender as? Plant else { return }
        
        destinationVC.plant = plant
    }
    
}
