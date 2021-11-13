//
//  UIColor+Extension.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/18.
//

import UIKit

private enum PPColor: String {

    // swiftlint:disable identifier_name
    case DarkGreen
    
    case BackgroundGreen
    
    case NavTabColor
    
    case CloudBlue
    
}

extension UIColor {
    
    static let DarkGreen = PPColor(.DarkGreen)

    static let BackgroundGreen = PPColor(.BackgroundGreen)

    static let NavTabColor = PPColor(.NavTabColor)

    static let CloudBlue = PPColor(.CloudBlue)
    
    // swiftlint:enable identifier_name
    
    static let cloudBlue = UIColor.hexStringToUIColor(hex: "CCE5FF")
    static let darkGreen1 = UIColor.hexStringToUIColor(hex: "347159")
    
    private static func PPColor(_ color: PPColor) -> UIColor? {

        return UIColor(named: color.rawValue)
    }
    
    static func hexStringToUIColor(hex: String) -> UIColor {

        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
