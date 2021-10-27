//
//  CalendarPageViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/27.
//

import UIKit

class CalendarPageViewController: UIViewController {
    
    @IBOutlet weak var calendar: UIDatePicker!
    
    @IBOutlet weak var infoTableView: UITableView! {
        didSet {
            infoTableView.delegate = self
            infoTableView.dataSource = self
            infoTableView.registerCellWithNib(
                identifier: String(describing: CalendarInfoTableViewCell.self),
                bundle: nil)
        }
    }
    
    private var waterRecords: [WaterRecord]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.locale = Locale(identifier: "zh_Hant_TW")
        calendar.calendar = Calendar(identifier: .republicOfChina)
        
        FirebaseManager.shared.fetchWaterRecord(date: Date()) { result in
            switch result {
            case .success(let waterRecords):
                self.waterRecords = waterRecords
                self.infoTableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
        
    }
    @IBAction func dateDidPick(_ sender: UIDatePicker) {
        
        let date = sender.date
        
        FirebaseManager.shared.fetchWaterRecord(date: date) { result in
            switch result {
            case .success(let waterRecords):
                self.waterRecords = waterRecords
                self.infoTableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            
            guard let plant = sender as? Plant,
                  let destinationVC = segue.destination as? PlantDetailViewController else { return }
            
            destinationVC.plant = plant
            
        }
    }
    
}

extension CalendarPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let records = waterRecords {
            return records.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = infoTableView.dequeueReusableCell(withIdentifier: String(describing: CalendarInfoTableViewCell.self),
                                                     for: indexPath)
        guard let calendarCell = cell as? CalendarInfoTableViewCell,
              let records = waterRecords else { return cell }
        
        let record = records[indexPath.row]
        
        calendarCell.layoutCell(imageURL: record.plantImage,
                                plantName: record.plantName,
                                time: record.waterDate)
        return calendarCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let waterRecords = waterRecords else { return }
        
        let plantID = waterRecords[indexPath.row].plantID
        
        FirebaseManager.shared.fetchPlants(plantID: plantID) { result in
            switch result {
            case .success(let plant):
                self.performSegue(withIdentifier: "showDetail", sender: plant)
            case .failure(let error):
                print(error)
            }
        }
    }
}
