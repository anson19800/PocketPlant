//
//  CalendarInfoTableViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/27.
//

import UIKit
import Kingfisher

class CalendarInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func layoutCell(imageURL: String?, plantName: String, time: TimeInterval) {
        
        if let imageURL = imageURL {
            
            plantImageView.kf.setImage(with: URL(string: imageURL))
        }
        
        titleLabel.text = "對\(plantName)澆水"
        
        timeLabel.text = String(time)
        
    }
}
