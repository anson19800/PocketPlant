//
//  CalendarPageViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/27.
//

import UIKit
import Lottie

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
    
    @IBOutlet weak var animationContainer: UIView!
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    private var waterRecords: [WaterRecord]? {
        didSet {
            checkEmpty()
        }
    }
    
    private var emptyAnimation: AnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.locale = Locale(identifier: "zh_Hant_TW")
        calendar.calendar = Calendar(identifier: .republicOfChina)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .plain,
                                                                target: nil,
                                                                action: nil)
        
        emptyAnimation = loadAnimation(name: "70780-emptyResult", loopMode: .loop)
        if let emptyAnimation = emptyAnimation {
            emptyAnimation.frame = animationContainer.bounds
            animationContainer.addSubview(emptyAnimation)
            emptyAnimation.play()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.calendar.date = Date()
        
        fetchRecord(date: self.calendar.date)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func dateDidPick(_ sender: UIDatePicker) {
        
        let date = sender.date
        
        fetchRecord(date: date)
    }
    
    func fetchRecord(date: Date) {
        
        FirebaseManager.shared.fetchWaterRecord(date: date) { result in
            switch result {
            case .success(let waterRecords):
                self.waterRecords = waterRecords
                self.infoTableView.performBatchUpdates {
                    let indexSet = IndexSet(integersIn: 0...0)
                    self.infoTableView.reloadSections(indexSet, with: .fade)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWater" {
            
            guard let plant = sender as? Plant,
                  let destinationVC = segue.destination as? DeathPlantViewController else { return }
            
            destinationVC.plant = plant
            
        }
    }
    
    private func checkEmpty() {
        if let waterRecords = waterRecords {
            if waterRecords.count <= 0 {
                animationContainer.isHidden = false
                emptyLabel.isHidden = false
                emptyLabel.text = "這天沒有澆水紀錄"
                if let emptyAnimation = emptyAnimation {
                    emptyAnimation.play()
                }
            } else {
                animationContainer.isHidden = true
                emptyLabel.isHidden = true
                if let emptyAnimation = emptyAnimation {
                    emptyAnimation.stop()
                }
            }
        } else {
            
            animationContainer.isHidden = false
            emptyLabel.isHidden = false
            emptyLabel.text = "這天沒有澆水紀錄"
            if let emptyAnimation = emptyAnimation {
                emptyAnimation.play()
            }
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
        
        calendarCell.indexPath = indexPath
        
        calendarCell.delegate = self
        
        return calendarCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let waterRecords = waterRecords else { return }
        
        let plantID = waterRecords[indexPath.row].plantID
        
        FirebaseManager.shared.fetchPlants(plantID: plantID) { result in
            switch result {
            case .success(let plant):
                self.performSegue(withIdentifier: "showWater", sender: plant)
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension CalendarPageViewController: CalendarInfoTableViewCellDelegate {
    
    func deleteAction(indexPath: IndexPath) {
        
        guard var records = waterRecords else { return }
        
        let plantName = records[indexPath.row].plantName
        
        let controller = UIAlertController(title: "刪除提醒", message: "確定要刪除這筆\(plantName)的澆水紀錄嗎？", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { _ in
            
            let recordID = records[indexPath.row].id
            
            FirebaseManager.shared.deleteWaterRecord(recordID: recordID) { result in
                switch result {
                case .success(let successInfo):
                    print(successInfo)
                    records.remove(at: indexPath.row)
                    self.waterRecords = records
                    self.infoTableView.deleteRows(at: [indexPath], with: .left)
                    self.infoTableView.reloadData()
//                    self.fetchRecord(date: self.calendar.date)
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
        
    }
}
