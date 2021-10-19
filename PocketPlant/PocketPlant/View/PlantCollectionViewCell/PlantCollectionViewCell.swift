//
//  PlantCollectionViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/18.
//

import UIKit

class PlantCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.hexStringToUIColor(hex: "D9E5D9").cgColor
    }

    func layoutCell(image: UIImage, name: String) {
        plantImageView.image = image
        nameLabel.text = name
    }
}
