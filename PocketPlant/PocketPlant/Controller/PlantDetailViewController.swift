//
//  PlantDetailViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/19.
//

import UIKit

class PlantDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var plant: Plant?
    
    @IBOutlet weak var plantNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCellWithNib(identifier: String(describing: PlantDetailTableViewCell.self), bundle: nil)
        guard let plant = plant else { return }
        plantNameLabel.text = plant.name
    }
    @IBAction func addToFavorite(_ sender: UIButton) {
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
