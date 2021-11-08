//
//  NewShopViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/31.
//

import UIKit

class NewShopViewController: UIViewController {
    
    @IBOutlet weak var shopNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        
        guard let name = shopNameTextField.text,
              let address = addressTextField.text else { return }
        
        var shop = GardeningShop(name: name,
                                 address: address)
        
        FirebaseManager.shared.addGardeningShop(shop: &shop) { isSuccess in
            if isSuccess {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
