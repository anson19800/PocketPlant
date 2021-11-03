//
//  InputPlantTableViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/19.
//

import UIKit

protocol InputPlantDelegate: AnyObject {
    
    func addNewPlant(plant: inout Plant)
}

enum WaterLevel: Int {
    case zero = 0
    case one = 1
    case two = 2
    case three = 3
}

enum LightLevel: Int {
    case zero = 0
    case one = 1
    case two = 2
    case three = 3
}

class InputPlantTableViewCell: UITableViewCell {
    
    weak var delegate: InputPlantDelegate?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    
    @IBOutlet weak var tempSlider: UISlider!
    @IBOutlet weak var humiditySlider: UISlider!
    
    @IBOutlet weak var tempLabel: PaddingLabel!
    @IBOutlet weak var humidityLabel: PaddingLabel!
    
    var temperature: Int = 25 {
        didSet {
            tempLabel.text = "\(temperature)°C"
        }
    }
    
    var humidity: Int = 25 {
        didSet {
            humidityLabel.text = "\(humidity)%"
        }
    }
    
    @IBOutlet weak var buyTimePicker: UIDatePicker!
    @IBOutlet weak var buyPlaceTextField: UITextField!
    @IBOutlet weak var buyPriceTextField: UITextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var waterLevel: WaterLevel = .one
    var lightLevel: LightLevel = .one
    
    @IBOutlet weak var waterLevel1: UIButton!
    @IBOutlet weak var waterLevel2: UIButton!
    @IBOutlet weak var waterLevel3: UIButton!
    
    @IBOutlet weak var lightLevel1: UIButton!
    @IBOutlet weak var lightLevel2: UIButton!
    @IBOutlet weak var lightLevel3: UIButton!
    
    @IBOutlet weak var postButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    @IBAction func sliderAction(_ sender: UISlider) {
        
        let currentValue = Int(sender.value)
        
        switch sender {
            
        case tempSlider:
            
            self.temperature = currentValue
            
        case humiditySlider:
            
            self.humidity = currentValue
            
        default:
            
            break
            
        }
    }
    @IBAction func levelButton(_ sender: UIButton) {
     
        switch sender {
        case waterLevel1:
            
            waterLevel = .one
            waterLevel1.tintColor = .cloudBlue
            waterLevel2.tintColor = .gray
            waterLevel3.tintColor = .gray
            
        case waterLevel2:
            
            waterLevel = .two
            waterLevel1.tintColor = .cloudBlue
            waterLevel2.tintColor = .cloudBlue
            waterLevel3.tintColor = .gray
            
        case waterLevel3:
            
            waterLevel = .three
            waterLevel1.tintColor = .cloudBlue
            waterLevel2.tintColor = .cloudBlue
            waterLevel3.tintColor = .cloudBlue
            
        case lightLevel1:
            
            lightLevel = .one
            lightLevel1.tintColor = .orange
            lightLevel2.tintColor = .gray
            lightLevel3.tintColor = .gray
            
        case lightLevel2:
            
            lightLevel = .two
            lightLevel1.tintColor = .orange
            lightLevel2.tintColor = .orange
            lightLevel3.tintColor = .gray
            
        case lightLevel3:
            
            lightLevel = .three
            lightLevel1.tintColor = .orange
            lightLevel2.tintColor = .orange
            lightLevel3.tintColor = .orange
            
        default:
            waterLevel = .zero
            lightLevel = .zero
        }
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        
        guard let name = nameTextField.text,
              let category = categoryTextField.text,
              let buyPlace = buyPlaceTextField.text,
              let buyPriceString = buyPriceTextField.text,
              let description = descriptionTextView.text
        else { return }
        
        let temperature = self.temperature
        let humidity = self.humidity
        let buyDate = self.buyTimePicker.date
        let buyTime = buyDate.timeIntervalSince1970
        let buyPrice = Int(buyPriceString) ?? 0
        
        var plant = Plant(id: "0",
                          name: name,
                          category: category,
                          water: self.waterLevel.rawValue,
                          light: self.lightLevel.rawValue,
                          temperature: temperature,
                          humidity: humidity,
                          buyTime: buyTime,
                          buyPlace: buyPlace,
                          buyPrice: Int(buyPrice),
                          description: description,
                          favorite: false,
                          ownerID: "0",
                          isPublic: false,
                          reminder: nil)
        
        print(plant)
        guard let delegate = self.delegate else { return }
        
        delegate.addNewPlant(plant: &plant)
    }
    
    func layoutCell(plant: Plant) {
        nameTextField.text = plant.name
        categoryTextField.text = plant.category
        
        switch plant.water {
        case 1:
            
            waterLevel = .one
            waterLevel1.tintColor = .cloudBlue
            waterLevel2.tintColor = .gray
            waterLevel3.tintColor = .gray
            
        case 2:
            
            waterLevel = .two
            waterLevel1.tintColor = .cloudBlue
            waterLevel2.tintColor = .cloudBlue
            waterLevel3.tintColor = .gray
            
        case 3:
            
            waterLevel = .three
            waterLevel1.tintColor = .cloudBlue
            waterLevel2.tintColor = .cloudBlue
            waterLevel3.tintColor = .cloudBlue
            
        default:
            waterLevel = .zero
        }
        
        switch plant.light {
        case 1:
            
            lightLevel = .one
            lightLevel1.tintColor = .orange
            lightLevel2.tintColor = .gray
            lightLevel3.tintColor = .gray
            
        case 2:
            
            lightLevel = .two
            lightLevel1.tintColor = .orange
            lightLevel2.tintColor = .orange
            lightLevel3.tintColor = .gray
            
        case 3:
            
            lightLevel = .three
            lightLevel1.tintColor = .orange
            lightLevel2.tintColor = .orange
            lightLevel3.tintColor = .orange
            
        default:
            lightLevel = .zero
        }
        
        temperature = plant.temperature
        tempSlider.value = Float(plant.temperature) / 100.0
        humidity = plant.humidity
        humiditySlider.value = Float(plant.humidity) / 100.0
        
        buyTimePicker.date = Date(timeIntervalSince1970: plant.buyTime)
        buyPlaceTextField.text = plant.buyPlace
        buyPriceTextField.text = String(plant.buyPrice)
        
        descriptionTextView.text = plant.description
    }
    
}
