//
//  UISearchBar+Extension.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/25.
//

import UIKit

extension UISearchBar {
    
    func setTextFieldShadow() {
        
        self.searchTextField.backgroundColor = .white
        
        self.searchTextField.layer.cornerRadius = 15
        
        self.searchTextField.layer.shadowColor = UIColor.black.cgColor
        
        self.searchTextField.layer.shadowOffset = CGSize.zero
        
        self.searchTextField.layer.shadowRadius = 4
        
        self.searchTextField.layer.shadowOpacity = 0.1
    }
    
}
