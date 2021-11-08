//
//  UIView+Extension.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/26.
//

import UIKit

extension UIView {
    func shake(count: Float = 4, for duration: TimeInterval = 0.5, withTranslation translation: Float = 5) {
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
}
