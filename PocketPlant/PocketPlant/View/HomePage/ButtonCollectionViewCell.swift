//
//  ButtonCollectionViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/18.
//

import UIKit

class ButtonCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.hexStringToUIColor(hex: "7F927F").cgColor
    }
    
    override var isSelected: Bool {
        didSet {
            
            backgroundColor = isSelected ? UIColor.hexStringToUIColor(hex: "7F927F") : .white
            
            iconImage.tintColor = isSelected ? .white : UIColor.hexStringToUIColor(hex: "7F927F")
            
            titleLabel.textColor = isSelected ? .white : UIColor.hexStringToUIColor(hex: "7F927F")
            
        }
    }
    
    func layoutCell(image: UIImage, title: String) {
        
        iconImage.image = image
        
        titleLabel.text = title
        
    }

}
