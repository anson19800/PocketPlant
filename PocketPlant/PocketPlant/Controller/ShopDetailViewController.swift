//
//  ShopDetailViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/30.
//

import UIKit
import MapKit

class ShopDetailViewController: UIViewController {
    
    @IBOutlet weak var shopTitle: UILabel!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var backgroundView: UIView! {
        didSet {
            backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            backgroundView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.registerCellWithNib(identifier: String(describing: CommentTableViewCell.self), bundle: nil)
            tableView.registerCellWithNib(identifier: String(describing: CommentTitleTableViewCell.self), bundle: nil)
        }
    }
    
    var shop: GardeningShop?
    
    var comments: [Comment]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let shop = shop {
            shopTitle.text = shop.name
            addressTextView.text = shop.address
            
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(shop.address) { placemarks, _ in
                
                let annotation = MKPointAnnotation()
                if let location = placemarks?.first?.location {
                    annotation.coordinate = location.coordinate
                    self.mapView.addAnnotation(annotation)
                    
                    let region = MKCoordinateRegion(center: annotation.coordinate,
                                                    latitudinalMeters: 500,
                                                    longitudinalMeters: 500)
                    self.mapView.setRegion(region, animated: false)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        addressTextView.selectedTextRange = nil
    }
}

extension ShopDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CommentTitleTableViewCell.self),
                                                     for: indexPath)
            guard let titleCell = cell as? CommentTitleTableViewCell else { return cell }
            
            return titleCell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CommentTableViewCell.self),
                                                     for: indexPath)
            guard let commentCell = cell as? CommentTableViewCell else { return cell }
            
            return commentCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addressTextView.selectedTextRange = nil
    }
    
}
