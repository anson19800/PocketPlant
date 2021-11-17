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
        
        guard let waterLevel = WaterLevel(rawValue: plant.water),
              let lightLevel = LightLevel(rawValue: plant.light)
        else { return }
        setLevelImage(water: waterLevel,
                      light: lightLevel)
    }
    
    func setLevelImage(water: WaterLevel, light: LightLevel) {
        
        switch water {
        case .zero:
            waterLabel.text = "不需水份"
        case .one:
            waterLabel.text = "少量水份"
            waterLevel1Image.tintColor = .CloudBlue
        case .two:
            waterLabel.text = "適中水份"
            waterLevel1Image.tintColor = .CloudBlue
            waterLevel2Image.tintColor = .CloudBlue
        case .three:
            waterLabel.text = "大量水份"
            waterLevel1Image.tintColor = .CloudBlue
            waterLevel2Image.tintColor = .CloudBlue
            waterLevel3Image.tintColor = .CloudBlue
        }
        
        switch light {
        case .zero:
            lightLabel.text = "不需日照"
        case .one:
            lightLabel.text = "少量日照"
            lightLevel1Image.tintColor = .orange
        case .two:
            lightLabel.text = "適中日照"
            lightLevel1Image.tintColor = .orange
            lightLevel2Image.tintColor = .orange
        case .three:
            lightLabel.text = "大量日照"
            lightLevel1Image.tintColor = .orange
            lightLevel1Image.tintColor = .orange
            lightLevel1Image.tintColor = .orange
        }
        
    }
    
}
