//
//  InputPlantTableViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/19.
//

import UIKit

class InputPlantTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    
    @IBOutlet weak var tempSlider: UISlider!
    @IBOutlet weak var humiditySlider: UISlider!
    
    @IBOutlet weak var buyTimeTextField: UITextField!
    @IBOutlet weak var buyPlaceTextField: UITextField!
    @IBOutlet weak var buyPriceTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
    }
    
}
