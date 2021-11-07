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
        }
    }
    
    var plants: [Plant]?
    
    var dataSource: UICollectionViewDiffableDataSource<SharePlantSection, Plant>?
    
    var snapshot = NSDiffableDataSourceSnapshot<SharePlantSection, Plant>()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        FirebaseManager.shared.fetchPlants { result in
            switch result {
            case .success(let plants):
                self.plants = plants
                self.configureCollectionView()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseManager.shared.fetchPlants { result in
            switch result {
            case .success(let plants):
                self.plants = plants
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<SharePlantSection, Plant>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, plant in
                
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: PlantCollectionViewCell.self),
                    for: indexPath)
                
                guard let plantCell = cell as? PlantCollectionViewCell else { return cell }
                
                if let imageURL = plant.imageURL {
                    plantCell.layoutCell(imageURL: imageURL,
                                     name: plant.name)
                } else {
                    plantCell.layoutCell(imageURL: "",
                                     name: plant.name)
                }
                
                return plantCell
            })
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        snapshot.appendSections([.share])
        
        if let plants = plants {
            snapshot.appendItems(plants, toSection: .share)
        }
        
        if let dataSource = dataSource {
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
}

extension SharePlantViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let itemSpace: CGFloat = 10
        let columCount: CGFloat = 3

        let width = floor( (collectionView.bounds.width - itemSpace * (columCount - 1)) / columCount )

        return CGSize(width: width, height: width * 1.2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Hi")
    }
    
}
