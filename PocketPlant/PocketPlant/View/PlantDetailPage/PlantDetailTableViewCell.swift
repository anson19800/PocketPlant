//
//  PlantDetailTableViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/20.
//

import UIKit

class PlantDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: PaddingLabel!
    
    @IBOutlet weak var lightLevel1Image: UIImageView!
    @IBOutlet weak var lightLevel2Image: UIImageView!
    @IBOutlet weak var lightLevel3Image: UIImageView!
    @IBOutlet weak var lightLabel: UILabel!
    
    @IBOutlet weak var waterLevel1Image: UIImageView!
    @IBOutlet weak var waterLevel2Image: UIImageView!
    @IBOutlet weak var waterLevel3Image: UIImageView!
    @IBOutlet weak var waterLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var temperatureProgressView: UIProgressView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var humidityProgressView: UIProgressView!
    
    @IBOutlet weak var buyPlaceLabel: UILabel!
    @IBOutlet weak var buyTimeLabel: UILabel!
    @IBOutlet weak var buyPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
    }
    
    func layoutCell(plant: Plant) {
        
        descriptionLabel.text = plant.description
        
        temperatureLabel.text = "溫度：\(plant.temperature)"
        self.temperatureProgressView.setProgress(0, animated: false)
        UIView.animate(withDuration: 1) {
            self.temperatureProgressView.setProgress(Float(plant.temperature)/100, animated: true)
        }
        
        humidityLabel.text = "濕度：\(plant.humidity)%"
        self.humidityProgressView.setProgress(0, animated: false)
        UIView.animate(withDuration: 1.35) {
            self.humidityProgressView.setProgress(Float(plant.humidity)/100, animated: true)
        }
        
        let buyDate = Date(timeIntervalSince1970: plant.buyTime)
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let butDateString = dateFormater.string(from: buyDate)
        
        buyPlaceLabel.text = plant.buyPlace
        buyTimeLabel.text = butDateString
        buyPriceLabel.text = String(plant.buyPrice)
    }
    
}
