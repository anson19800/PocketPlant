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
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var backgroundView: UIView! {
        didSet {
            backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            backgroundView.layer.cornerRadius = 10
        }
    }
    
    var shop: GardeningShop?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let shop = shop {
            shopTitle.text = shop.name
            addressLabel.text = shop.address
            
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
}
