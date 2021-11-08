//
//  InputShopInfoTableViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/2.
//

import UIKit

class InputShopInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var shopNameTextField: UITextField!
    
    @IBOutlet weak var addressTextfield: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextView! {
        didSet {
            descriptionTextField.layer.borderWidth = 1
            descriptionTextField.layer.borderColor = UIColor.systemGray5.cgColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func renderInfo() -> GardeningShop? {
        guard let name = shopNameTextField.text,
              name != "",
              let address = addressTextfield.text,
              address != "",
              let phone = phoneTextField.text,
              let description = descriptionTextField.text else { return nil }
        
        let shop = GardeningShop(name: name,
                                 address: address,
                                 phone: phone,
                                 description: description)
        return shop
    }
}
