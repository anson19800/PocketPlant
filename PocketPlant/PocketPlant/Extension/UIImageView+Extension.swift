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
}
