//
//  PlantCollectionViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/18.
//

import UIKit
import Kingfisher

class PlantCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var plantImageView: UIImageView! {
        didSet {
            plantImageView.layer.cornerRadius = 5
            plantImageView.layer.borderWidth = 1
            plantImageView.layer.borderColor = UIColor.lightGray.cgColor
        }
        
    }
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.hexStringToUIColor(hex: "D9E5D9").cgColor
    }

    func layoutCell(imageURL: String, name: String) {
        plantImageView.kf.setImage(with: URL(string: imageURL))
        nameLabel.text = name
    }
}
