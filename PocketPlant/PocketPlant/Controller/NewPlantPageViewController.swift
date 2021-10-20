//
//  NewPlantPageViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/19.
//

import UIKit

class NewPlantPageViewController: UIViewController {

    @IBOutlet weak var uploadImageButton: UIButton! {
        didSet {
            uploadImageButton.layer.borderWidth = 2
            uploadImageButton.layer.borderColor = UIColor.lightGray.cgColor
            uploadImageButton.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var takePhotoButton: UIButton! {
        didSet {
            takePhotoButton.layer.borderWidth = 2
            takePhotoButton.layer.borderColor = UIColor.lightGray.cgColor
            takePhotoButton.layer.cornerRadius = 20
        }
    }
    
    @IBOutlet weak var plantImageView: UIImageView! {
        didSet {
            plantImageView.layer.cornerRadius = 8
            plantImageView.layer.borderColor = UIColor.lightGray.cgColor
            plantImageView.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    let firebaseManager = FirebaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerCellWithNib(
            identifier: String(describing: InputPlantTableViewCell.self),
            bundle: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
}

extension NewPlantPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: InputPlantTableViewCell.self),
            for: indexPath)
        
        guard let inputCell = cell as? InputPlantTableViewCell else { return cell }
        
        inputCell.delegate = self
        
        return inputCell
    }
}

extension NewPlantPageViewController: InputPlantDelegate {
    
    func addNewPlant(plant: inout Plant) {
        
        firebaseManager.uploadPlant(plant: &plant)
        
        guard let parentVC = presentingViewController as? HomePageViewController else { return }
        
        parentVC.updatePlants()
        
        self.dismiss(animated: true, completion: nil)
    }
}
