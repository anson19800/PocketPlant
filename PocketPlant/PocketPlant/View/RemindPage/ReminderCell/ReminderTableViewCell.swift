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
    
    var imageIsSelectes: Bool = false {
        didSet {
            typeImageView.tintColor = imageIsSelectes ? imageColor : .lightGray
            typelabel.textColor = imageIsSelectes ? UIColor.hexStringToUIColor(hex: "424B5A") : .lightGray
            trailLabel.textColor = imageIsSelectes ? UIColor.hexStringToUIColor(hex: "424B5A") : .lightGray
            dayTextField.textColor = imageIsSelectes ? UIColor.hexStringToUIColor(hex: "424B5A") : .lightGray
            dayTextField.isEnabled = imageIsSelectes
        }
    }
    
    private var imageColor: UIColor = .gray
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(tapOnImage(_:)))
        typeImageView.isUserInteractionEnabled = true
        typeImageView.addGestureRecognizer(tap)
    }
    
    func layoutCell(type: ReminderType, reminds: [Remind]?) {
        
        typelabel.text = "\(type.rawValue)提醒"
        
        switch type {
        case .water:
            typeImageView.image = UIImage(systemName: "drop.circle.fill")
            imageColor = UIColor.CloudBlue ?? .blue
        case .fertilizer:
            typeImageView.image = UIImage(systemName: "leaf.circle.fill")
            imageColor = UIColor.hexStringToUIColor(hex: "A2CDA2")
        case .soil:
            typeImageView.image = UIImage(systemName: "globe.asia.australia.fill")
            imageColor = UIColor.hexStringToUIColor(hex: "BC956F")
        }
        
        typeImageView.tintColor = imageIsSelectes ? imageColor : .lightGray
        typelabel.textColor = imageIsSelectes ? UIColor.hexStringToUIColor(hex: "424B5A") : .lightGray
        trailLabel.textColor = imageIsSelectes ? UIColor.hexStringToUIColor(hex: "424B5A") : .lightGray
        dayTextField.textColor = imageIsSelectes ? UIColor.hexStringToUIColor(hex: "424B5A") : .lightGray
        dayTextField.isEnabled = imageIsSelectes
        
        guard let reminds = reminds else { return }

        reminds.forEach { remind in
            if type.rawValue == remind.type {
                if remind.times != 0 {
                    dayTextField.text = String(remind.times)
                    self.imageIsSelectes = true
                }
            }
        }
    }
    @objc private func tapOnImage(_ sender: UITapGestureRecognizer) {
        
        imageIsSelectes = !imageIsSelectes
        
        if imageIsSelectes {
            
            dayTextField.isEnabled = true
            
            UIView.animate(withDuration: 0.1, animations: {() -> Void in
                self.typeImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion: {(_ finished: Bool) -> Void in
                UIView.animate(withDuration: 0.1, animations: {() -> Void in
                    self.typeImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
            })

        } else {
            
            typeImageView.shake(count: 3, for: 0.2, withTranslation: 2)
            
            dayTextField.isEnabled = false
            
        }
    }
    
}
