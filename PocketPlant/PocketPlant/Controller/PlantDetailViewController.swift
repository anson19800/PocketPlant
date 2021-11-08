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
            tableView.registerCellWithNib(
                identifier: String(describing: PlantDetailTableViewCell.self),
                bundle: nil)
        }
    }
    
    @IBOutlet weak var infoView: UIView! {
        didSet {
            infoView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            infoView.layer.cornerRadius = 30
            infoView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var plantNameLabel: UILabel!
    
    @IBOutlet weak var plantCategoryLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var plantPhotoImageView: UIImageView!
    
    var plant: Plant?
    
    let firebaseManager = FirebaseManager.shared
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        guard let plant = plant,
              let imageUrl = plant.imageURL else { return }
        
        plantNameLabel.text = plant.name
        
        plantCategoryLabel.text = plant.category
        
        favoriteButton.tintColor = plant.favorite ? .red : .gray
        
        plantPhotoImageView.kf.setImage(with: URL(string: imageUrl))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
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
    
    @IBAction func showRemindFloating(_ sender: UIButton) {
        
        let storyBoard = UIStoryboard(name: "RemindPage", bundle: nil)
        
        guard let remindVC = storyBoard.instantiateViewController(
            withIdentifier: String(describing: RemindViewController.self)) as? RemindViewController else { return }
        
        remindVC.modalTransitionStyle = .crossDissolve
        remindVC.modalPresentationStyle = .overCurrentContext
        remindVC.plant = self.plant
        present(remindVC, animated: true, completion: nil)
        
    }
    
    @IBAction func tapOnQRCode(_ sender: UITapGestureRecognizer) {
        
        guard let plant = plant else {
            return
        }

        let qrcodePage = storyboard?.instantiateViewController(
            withIdentifier: String(describing: ShowQRCodePageViewController.self))
        
        guard let qrcodePageVC = qrcodePage as? ShowQRCodePageViewController else { return }
        
        qrcodePageVC.modalTransitionStyle = .crossDissolve
        
        qrcodePageVC.modalPresentationStyle = .overCurrentContext
        
        qrcodePageVC.plantID = plant.id
        
        present(qrcodePageVC, animated: true, completion: nil)
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
