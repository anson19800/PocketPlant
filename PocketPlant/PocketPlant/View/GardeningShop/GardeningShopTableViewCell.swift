//
//  GardeningShopTableViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/30.
//

import UIKit
import Kingfisher

class GardeningShopTableViewCell: UITableViewCell {

    @IBOutlet weak var shopImage: UIImageView!
    @IBOutlet weak var shopTitle: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func layoutCell(gardeningShop: GardeningShop) {
        
        if let images = gardeningShop.images,
           let firstImage = images.first {
            shopImage.kf.setImage(with: URL(string: firstImage))
        }
        
        shopTitle.text = gardeningShop.name
        addressLabel.text = gardeningShop.address
    }
}
