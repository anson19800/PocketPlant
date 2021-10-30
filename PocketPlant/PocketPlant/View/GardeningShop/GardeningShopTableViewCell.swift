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
    
    func layoutCell(imageURL: String, title: String, address: String) {
        
        shopImage.kf.setImage(with: URL(string: imageURL))
        shopTitle.text = title
        addressLabel.text = address
    }
}
