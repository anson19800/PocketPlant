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
    @IBOutlet weak var trailLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    private var imageColor: UIColor = .gray
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func layoutCell(type: ReminderType, reminds: [Remind]?) {
        
        typelabel.text = "\(type.rawValue)  每"
        
        switch type {
        case .water:
            if #available(iOS 15, *) {
                typeImageView.image = UIImage(systemName: "drop.circle.fill")
            } else {
                typeImageView.image = UIImage(systemName: "drop.fill")
            }
            imageColor = UIColor.CloudBlue ?? .blue
        case .fertilizer:
            if #available(iOS 15, *) {
                typeImageView.image = UIImage(systemName: "leaf.circle.fill")
            } else {
                typeImageView.image = UIImage(systemName: "leaf.fill")
            }
            imageColor = UIColor.hexStringToUIColor(hex: "A2CDA2")
        case .soil:
            if #available(iOS 15, *) {
                typeImageView.image = UIImage(systemName: "globe.asia.australia.fill")
            } else {
                typeImageView.image = UIImage(systemName: "hammer.fill")
            }
            imageColor = UIColor.hexStringToUIColor(hex: "BC956F")
        }
        
        typeImageView.tintColor = imageColor
        typelabel.textColor = UIColor.DarkBlue
        trailLabel.textColor = UIColor.DarkBlue
        dayTextField.textColor = UIColor.DarkBlue
        
        guard let reminds = reminds else { return }

        reminds.forEach { remind in
            if type.rawValue == remind.type {
                if remind.times != 0 {
                    dayTextField.text = String(remind.times)
                    timePicker.setDate(Date(timeIntervalSince1970: remind.time), animated: false)
                }
            }
        }
    }
}
