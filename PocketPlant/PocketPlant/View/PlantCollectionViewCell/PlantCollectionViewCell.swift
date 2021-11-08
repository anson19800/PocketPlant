//
//  PlantCollectionViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/18.
//

import UIKit
import Kingfisher

class PlantCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var plantImageView: UIImageView! {
        didSet {
            plantImageView.layer.cornerRadius = 5
            plantImageView.layer.borderWidth = 1
            plantImageView.layer.borderColor = UIColor.hexStringToUIColor(hex: "DFEFDF").cgColor
        }
        
    }
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    func layoutCell(imageURL: String?, name: String) {
        if let imageURL = imageURL {
            plantImageView.kf.setImage(with: URL(string: imageURL))
        } else {
            plantImageView.image = UIImage(named: "plant")
        }
        
        nameLabel.text = name
    }
}
