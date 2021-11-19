//
//  UIViewController+Extension.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/31.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String, buttonTitle: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func darkView() -> UIView {
        
        let maskView = UIView()
        
        maskView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        maskView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)

        view.addSubview(maskView)
        
        return maskView
    }
}
