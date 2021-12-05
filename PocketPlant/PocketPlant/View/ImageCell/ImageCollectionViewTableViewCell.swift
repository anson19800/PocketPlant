//
//  ImageCollectionVIewTableViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/31.
//

import UIKit

class ImageCollectionViewTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        isUserInteractionEnabled = true
        collectionView.registerCellWithNib(identifier: String(describing: ImageCollectionViewCell.self),
                                           bundle: nil)
    }
}
