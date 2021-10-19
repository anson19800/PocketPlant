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
        
        updatePlants()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        
        updatePlants()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func updatePlants() {
        
        firebaseManager.fetchPlants { result in
            
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

extension HomePageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == buttonCollectionView {
            
            return 4
            
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemSpace: CGFloat = 10
        let columCount: CGFloat = 3
        
        let width = floor( (plantCollectionView.bounds.width - itemSpace * (columCount - 1)) / columCount )

        return CGSize(width: width, height: width * 1.8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let plants = self.plants else { return }
        
        let plant = plants[indexPath.row]
        
        performSegue(withIdentifier: "showPlantDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Detail")
    }
    
}
