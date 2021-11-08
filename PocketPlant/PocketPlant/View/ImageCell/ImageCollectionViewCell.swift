//
//  ImageCollectionViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/1.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainImageView: UIImageView! {
        didSet {
            mainImageView.applyshadowWithCorner(
                containerView: imageContainer,
                cornerRadious: 10)
            mainImageView.layer.cornerRadius = 10
            mainImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var imageContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
