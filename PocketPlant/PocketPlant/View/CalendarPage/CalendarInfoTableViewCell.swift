//
//  CalendarInfoTableViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/27.
//

import UIKit
import Kingfisher

class CalendarInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var plantImageView: UIImageView! {
        didSet {
            plantImageView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        contentView.layer.cornerRadius = 10
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
    }
    
    func layoutCell(imageURL: String?, plantName: String, time: TimeInterval) {
        
        if let imageURL = imageURL {
            
            plantImageView.kf.setImage(with: URL(string: imageURL))
        }
        
        titleLabel.text = "對\(plantName)澆水"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        let dayString = dateFormatter.string(
            from: Date(timeIntervalSince1970: time))
        timeLabel.text = dayString
        
    }
}
