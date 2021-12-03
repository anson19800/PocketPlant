//
//  SharePlantViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/7.
//

import UIKit
import SwiftUI

enum SharePlantSection {
    case share
}

class SharePlantViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.registerCellWithNib(identifier: String(describing: PlantCollectionViewCell.self),
                                               bundle: nil)
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    var plants: [Plant] = []
    
    var plantsID: [String]?
    
    var dataSource: UICollectionViewDiffableDataSource<SharePlantSection, Plant>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserManager.shared.fetchCurrentUserInfo { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                guard let plants = user.sharePlants else { return }
                self.plantsID = plants
                self.getUserSharePlants()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getUserSharePlants() {
        
        guard let plantsID = plantsID else { return }
        
        let group = DispatchGroup()
        
        self.plants = []

        plantsID.forEach { plantID in
            group.enter()
            FirebaseManager.shared.fetchPlants(plantID: plantID) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let plant):
                    self.plants.append(plant)
                    group.leave()
                case .failure(let error):
                    print(error)
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.collectionView.reloadData()
        }
    }
}

extension SharePlantViewController: UICollectionViewDataSource,
                                    UICollectionViewDelegate,
                                    UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return plants.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: PlantCollectionViewCell.self),
            for: indexPath)
        
        guard let plantCell = cell as? PlantCollectionViewCell else { return cell }
        
        let imageURL = plants[indexPath.row].imageURL
        
        let name = plants[indexPath.row].name
        
        plantCell.layoutCell(imageURL: imageURL, name: name)
        
        return plantCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let itemSpace: CGFloat = 10
        let columCount: CGFloat = 3

        let width = floor( (collectionView.bounds.width - itemSpace * (columCount - 1)) / columCount )

        return CGSize(width: width, height: width * 1.2)
    }
}
