//
//  ReminderTableViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/26.
//

import UIKit

enum ReminderType: String, CaseIterable {
    case water = "澆水"
    case fertilizer = "施肥"
    case soil = "補土"
}

class ReminderTableViewCell: UITableViewCell {

    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var typelabel: UILabel!
    @IBOutlet weak var dayTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func layoutCell(type: ReminderType) {
        
        typelabel.text = "\(type.rawValue)提醒週期"
        
        switch type {
        case .water:
            typeImageView.image = UIImage(systemName: "drop.fill")
        case .fertilizer:
            typeImageView.image = UIImage(systemName: "leaf.circle.fill")
            typeImageView.tintColor = UIColor.hexStringToUIColor(hex: "A2CDA2")
        case .soil:
            typeImageView.image = UIImage(systemName: "globe.asia.australia.fill")
            typeImageView.tintColor = UIColor.hexStringToUIColor(hex: "BC956F")
        }
        
    }
    
}
