//
//  UIImageView+Extension.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/27.
//

import UIKit

extension UIImageView {
    
    func generateQRCode(from string: String) {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("Q", forKey: "inputCorrectionLevel")
            if let ciImage = filter.outputImage {
                let scaleX = bounds.width / ciImage.extent.width
                let scaleY = bounds.height / ciImage.extent.height
                let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                self.image = UIImage(ciImage: ciImage.transformed(by: transform))
            }
        }
    }
    
    func applyshadowWithCorner(containerView: UIView, cornerRadious: CGFloat) {
        
        containerView.backgroundColor = .clear
        containerView.clipsToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 0.3)
        containerView.layer.shadowRadius = 10
        containerView.layer.cornerRadius = cornerRadious
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds,
                                                      cornerRadius: cornerRadious).cgPath
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadious
    }
}
