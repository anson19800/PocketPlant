//
//  DeathPlantViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/23.
//

import UIKit
import Charts

class DeathPlantViewController: UIViewController {

    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var lifeTimeLabel: UILabel!
    @IBOutlet weak var waterBarChart: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setChart(dataPoints: months, valuse: unitSold)
    }
    
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    let unitSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
    
    func setChart(dataPoints: [String], valuse: [Double]) {
        waterBarChart.noDataText = "沒有任何澆水紀錄"
        
        var dataEntries: [BarChartDataEntry] = []
        
        for index in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(index), y: unitSold[index])
            
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Units Sold")
        
        let chartData = BarChartData(dataSet: chartDataSet)
        
        waterBarChart.data = chartData
        
    }
    
}
