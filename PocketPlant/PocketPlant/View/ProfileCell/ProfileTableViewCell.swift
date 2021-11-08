//
//  ProfileTableViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/4.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        contentView.layer.cornerRadius = 10
        
        iconImageView.applyshadowWithCorner(containerView: imageContainer,
                                            cornerRadious: 10,
                                            opacity: 0.1)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0))
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 1, height: 1)
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.masksToBounds = false
        layer.masksToBounds = false
    }
    
    func layoutCell(title: String, subTitle: String, image: UIImage?) {
        titleLabel.text = title
        subTitleLabel.text = subTitle
        if let image = image {
            iconImageView.image = image
        }
    }
}
