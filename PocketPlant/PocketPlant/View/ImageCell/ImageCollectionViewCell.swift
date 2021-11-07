//
//  ImageCollectionViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/1.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.applyshadowWithCorner(containerView: imageContainer, cornerRadious: 10)
        }
    }
    @IBOutlet weak var imageContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
        self.layer.cornerRadius = 10
    }

}
