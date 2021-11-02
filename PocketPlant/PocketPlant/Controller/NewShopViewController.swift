//
//  NewShopViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/31.
//

import UIKit

class NewShopViewController: UIViewController {
    
    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet {
            imageCollectionView.delegate = self
            imageCollectionView.dataSource = self
            imageCollectionView.registerCellWithNib(
                identifier: String(describing: ImageCollectionViewCell.self),
                bundle: nil)
        }
    }
    
    @IBOutlet weak var infoTableView: UITableView! {
        didSet {
            infoTableView.delegate = self
            infoTableView.dataSource = self
            infoTableView.registerCellWithNib(
                identifier: String(describing: InputShopInfoTableViewCell.self),
                bundle: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        
    }
}

extension NewShopViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: InputShopInfoTableViewCell.self),
            for: indexPath)
        
        guard let infoCell = cell as? InputShopInfoTableViewCell else { return cell }
        
        return infoCell
    }
}

extension NewShopViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ImageCollectionViewCell.self),
            for: indexPath)
        
        guard let imageCell = cell as? ImageCollectionViewCell else { return cell }
        
        imageCell.imageView.image = UIImage(named: "plant")
        
        return imageCell
    }
}
