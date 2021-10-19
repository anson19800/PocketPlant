//
//  ViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/18.
//

import UIKit

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
        
        firebaseManager.getArticle { result in
            
            switch result {
                
            case .success(let plants):
                
                self.plants = plants
                
                self.plantCollectionView.reloadData()
                
            case .failure(let error):
                
                print(error)
            }
        }
    }

    @IBAction func addButton(_ sender: UIButton) {
        
        var plant = Plant(id: "0",
                          name: "小草一號",
                          category: "可愛艸",
                          water: 3,
                          light: 2,
                          temperature: 50,
                          humidity: 50,
                          buyTime: Date().timeIntervalSince1970,
                          buyPlace: "園藝店",
                          buyPrice: 450,
                          description: "勾衣鉤意的",
                          lastWater: nil,
                          lastFertilizer: nil,
                          lastSoil: nil,
                          favorite: false,
                          ownerID: 2223,
                          isPublic: true)
        
//        firebaseManager.addArticle(plant: &plant)
        
        firebaseManager.getArticle { result in
            
            switch result {
                
            case .success(let plants):
                
                self.plants = plants
                
                self.plantCollectionView.reloadData()
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
}

extension HomePageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == buttonCollectionView {
            
            return 4
            
        } else {
            
            guard let plants = self.plants else { return 0 }
            
            return plants.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == buttonCollectionView {
            
            let cell = buttonCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: ButtonCollectionViewCell.self),
                for: indexPath
            )
            
            guard let buttonCell = cell as? ButtonCollectionViewCell else { return cell }
            
            buttonCell.layoutCell(image: UIImage(systemName: "leaf.fill")!, title: "我的植物")
            
            return buttonCell
            
        } else if collectionView == plantCollectionView {
            
            let cell = plantCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: PlantCollectionViewCell.self),
                for: indexPath
            )
            
            guard let plantCell = cell as? PlantCollectionViewCell,
                  let plants = self.plants else { return cell }
            
            plantCell.layoutCell(image: UIImage(named: "plant")!,
                                 name: plants[indexPath.row].name)
            
            return plantCell
        }
        
        return UICollectionViewCell()
    }
    
}
