//
//  PlantDetailViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/19.
//

import UIKit
import Kingfisher

class PlantDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var plant: Plant?
    
    let firebaseManager = FirebaseManager.shared
    
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var plantCategoryLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var plantPhotoImageView: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.registerCellWithNib(identifier: String(describing: PlantDetailTableViewCell.self), bundle: nil)
        
        guard let plant = plant,
              let imageUrl = plant.imageURL else { return }
        
        plantNameLabel.text = plant.name
        
        plantCategoryLabel.text = plant.category
        
        favoriteButton.tintColor = plant.favorite ? .red : .gray
        
        plantPhotoImageView.kf.setImage(with: URL(string: imageUrl))
    }
    @IBAction func addToFavorite(_ sender: UIButton) {
        
        guard var plant = plant else { return }
        
        firebaseManager.switchFavoritePlant(plantID: plant.id) { result in
            
            switch result {
                
            case .success(_):
                
                plant.favorite = !plant.favorite
                
                self.plant = plant
                
                self.favoriteButton.tintColor = plant.favorite ? .red : .gray
                
            case .failure(let error):
                
                print(error)
                
            }
        }
    }
}

extension PlantDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: PlantDetailTableViewCell.self),
            for: indexPath)
        
        guard let detailCell = cell as? PlantDetailTableViewCell,
              let plant = self.plant else { return cell }
        
        detailCell.layoutCell(plant: plant)
        
        return detailCell
    }
}
