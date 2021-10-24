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

    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var lifeTimeLabel: UILabel!
    @IBOutlet weak var waterBarChart: BarChartView!
    
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    let unitSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
    
    var plant: Plant?
    
    var waterRecord: [WaterRecord]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let plant = plant,
              let imageURL = plant.imageURL else { return }

        plantImage.kf.setImage(with: URL(string: imageURL))
        plantNameLabel.text = plant.name
        let today = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy.MM.dd"
        let todayDate = format.string(from: today)
        let buyDate = format.string(from: Date(timeIntervalSince1970: plant.buyTime))
        
        lifeTimeLabel.text = "\(buyDate) - \(todayDate)"
        
        waterBarChart.noDataText = "沒有任何澆水紀錄"
//        setChart(dataPoints: months, valuse: unitSold)
        let waterRecord = WaterRecord(id: "1", plantID: "2", waterDate: 1634988241.350534)
        setChart(waterRecords: [waterRecord])
    }
    
    func setChart(dataPoints: [String], valuse: [Double]) {
        
        var dataEntries: [BarChartDataEntry] = []
        
        for index in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(index), y: unitSold[index])
            
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Units Sold")
        
        let chartData = BarChartData(dataSet: chartDataSet)
        
        waterBarChart.data = chartData
        
    }
    
    func setChart(waterRecords: [WaterRecord]) {
        
        var waterRecordDict: [String: Int] = [:]
        
        var dataEntries: [BarChartDataEntry] = []
        
        waterRecords.forEach { waterRecord in
            
            let waterDate = Date(timeIntervalSince1970: waterRecord.waterDate)
        
            let formatter = DateFormatter()

            formatter.dateFormat = "MM"
            let month = formatter.string(from: waterDate)
            
            waterRecordDict[month, default: 0] += 1
        }
        
        let values = Array(waterRecordDict)
        
        for index in 0..<values.count {
            
            let dataEntry = BarChartDataEntry(x: Double(index),
                                              y: Double(values[index].value))
            
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "澆水次數")
        
        let chartData = BarChartData(dataSet: chartDataSet)
        
        waterBarChart.data = chartData
        
    }
    
}
