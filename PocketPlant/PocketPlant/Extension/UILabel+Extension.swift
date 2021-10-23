//
//  UILabel+Extension.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/19.
//

import UIKit

extension UILabel {
    
    @IBInspectable var lkBorderColor: UIColor? {
        get {

            guard let borderColor = layer.borderColor else {

                return nil
            }

            return UIColor(cgColor: borderColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    // Border width
    @IBInspectable var lkBorderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    // Corner radius
    @IBInspectable var lkCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}
