//
//  ToolStockTableViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/10.
//

import UIKit

class ToolStockTableViewCell: UITableViewCell {

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var buyPlaceTextField: UITextField!
    
    var stockNumber: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        contentView.layer.cornerRadius = 10
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
    
    func layoutCell(tool: Tool) {
        amountTextField.text = "x\(tool.stock)"
        nameTextField.text = tool.name
        buyPlaceTextField.text = tool.buyPlace
    }
}
