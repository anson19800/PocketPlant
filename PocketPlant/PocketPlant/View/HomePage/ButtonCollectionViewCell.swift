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
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
        backgroundColor = .white
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
