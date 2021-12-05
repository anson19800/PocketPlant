//
//  DeathPlantViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/23.
//

import UIKit
import Kingfisher
import Charts

class DeathPlantViewController: UIViewController {

    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var plantImage: UIImageView! {
        didSet {
            plantImage.applyshadowWithCorner(
                containerView: imageContainer,
                cornerRadious: 0,
                opacity: 0.3)
        }
    }
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var lifeTimeLabel: UILabel!
    @IBOutlet weak var waterInfoLabel: UILabel!
    @IBOutlet weak var waterBarChart: BarChartView!
   
    var plant: Plant?
    
    var waterRecords: [WaterRecord]?
    
    let firebaseManager = FirebaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let plant = plant,
              let imageURL = plant.imageURL else { return }

        configurUI(plant, imageURL: imageURL)
        
        waterBarChart.noDataText = "沒有任何澆水紀錄"
        
        
        firebaseManager.fetchWaterRecord(plantID: plant.id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {

            case .success(let waterRecords):

                guard waterRecords.count != 0
                        
                else {
                    
                    self.noDataAlert(plant: plant, type: .water)
                    
                    return
                }

                self.setChart(waterRecords: waterRecords)

            case .failure:

                self.noDataAlert(plant: plant, type: .water)
            }
        }
    }
    
    func configurUI(_ plant: Plant, imageURL: String) {
        
        plantImage.kf.setImage(with: URL(string: imageURL))
        plantNameLabel.text = plant.name
        let today = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy.MM.dd"
        let todayDate = format.string(from: today)
        let buyDate = format.string(from: Date(timeIntervalSince1970: plant.buyTime))
        
        lifeTimeLabel.text = "\(buyDate) - \(todayDate)"
        waterInfoLabel.text = "澆水紀錄 ｜ 總共澆了0次水"
    }
    
    func setChart(waterRecords: [WaterRecord]) {
        
        var waterRecordDict: [String: Int] = {
            
            var dict: [String: Int] = [:]
            
            for index in 1...12 {
                dict["\(index)月"] = 0
            }
            
            return dict
        }()
        
        var dataEntries: [BarChartDataEntry] = []
        
        waterRecords.forEach { waterRecord in
            
            let waterDate = Date(timeIntervalSince1970: waterRecord.waterDate)
        
            let formatter = DateFormatter()

            formatter.dateFormat = "M月"
            let month = formatter.string(from: waterDate)
            
            waterRecordDict[month, default: 0] += 1
        }
        
        let values = Array(waterRecordDict)
        
        for index in 0..<values.count {
            
            let dataEntry = BarChartDataEntry(x: Double(index),
                                              y: Double(waterRecordDict["\(index + 1)月"] ?? 0))
            
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: nil)
        
        let chartData = BarChartData(dataSet: chartDataSet)
        
        chartData.barWidth = Double(0.5)
        
        waterBarChart.data = chartData
        
        let xValues = ["1月", "2月", "3月", "4月", "5月", "6月",
                       "7月", "8月", "9月", "10月", "11月", "12月"]
        
        waterBarChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: xValues)
        waterBarChart.xAxis.drawGridLinesEnabled = false
        waterBarChart.xAxis.labelPosition = .bottom
        waterBarChart.xAxis.granularity = 1
        waterBarChart.xAxis.labelRotationAngle = -25
        waterBarChart.xAxis.setLabelCount(12, force: false)
        
        waterBarChart.leftAxis.drawGridLinesEnabled = false
        waterBarChart.leftAxis.granularity = 1.0
        waterBarChart.leftAxis.axisMinimum = 0.0
        
        waterBarChart.legend.enabled = false
        waterBarChart.extraBottomOffset = 20
        
        waterBarChart.animate(xAxisDuration: 0, yAxisDuration: 2)
        
        waterBarChart.rightAxis.enabled = false
        waterInfoLabel.text = "澆水紀錄 ｜ 總共澆了\(waterRecords.count)次水"
    }
    
    func noDataAlert(plant: Plant, type: RecordType) {
        
        let controller = UIAlertController(title: "沒有紀錄",
                                           message: "沒有\(plant.name)的\(type.rawValue)紀錄",
                                           preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    
}
