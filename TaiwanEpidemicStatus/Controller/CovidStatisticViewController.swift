//
//  CovidStatisticViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/7.
//

import UIKit
import Charts

class CovidStatisticViewController: UIViewController {
    @IBOutlet weak var viewChart: UIView!
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var txtCity: UILabel!
    
    public var cityStatisticData:[CityStatistic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set Style
        let cityName = NSLocalizedString("City", comment: "").replace("{city}", cityStatisticData.first?.cityName ?? "")
        txtCity.text = cityName
        
        viewChart.layer.cornerRadius = 8
        viewChart.layer.shadowColor = UIColor(named: "MainShadowColor")?.cgColor
        viewChart.layer.shadowRadius = 6
        viewChart.layer.shadowOpacity = 0.2
        viewChart.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        chart.xAxis.axisMinimum = 0
        chart.leftAxis.axisMinimum = 0
        chart.xAxis.spaceMin = 50
        chart.xAxis.labelPosition = .bottom
        chart.noDataText = "No Data"
        chart.noDataFont = UIFont.roundedFont(24)
        chart.gridBackgroundColor = .white
        chart.xAxis.axisLineColor = UIColor(named: "MainColor")!
        chart.legend.form = .line
    
        chart.animate(xAxisDuration: 1.5, easingOption: .linear)
        
        setChart()
    }
    
    private func setChart() {
        let year = Calendar.current.component(.year, from: Date())
        
        let data = cityStatisticData.filter({$0.districtName == "全區"}).prefix(30).reversed()
        let dayValues:[String] = data.map({$0.announcementDate.replace("-", "/").replace(
            "\(year)/", "")})
        let caseValues:[Int] = data.map({Int($0.newCasesAmount) ?? 0})
        let chartXValue:[Int] = (0..<dayValues.count).map({$0})
        
        chart.xAxis.valueFormatter = IndexAxisValueFormatter.with(values: dayValues)
        
        var dataEntries = [ChartDataEntry]()
        for i in dayValues.indices {
            dataEntries.append(ChartDataEntry(x: Double(chartXValue[i]), y: Double(caseValues[i])))
        }
        
        let newCasesLabel = NSLocalizedString("NewCases", comment: "")
        let chartSet = LineChartDataSet.init(entries: dataEntries, label: "\(year) \(newCasesLabel)")
        chartSet.setCircleColor(UIColor(named: "MainColor")!)
        chartSet.setColor(UIColor(named: "MainColor")!)
        let chartData = LineChartData(dataSet: chartSet)
        chart.data = chartData
    }
    
    @IBAction func btnBackEvent(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
