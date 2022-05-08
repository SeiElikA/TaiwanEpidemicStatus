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
    @IBOutlet weak var viewDistStatistic: UIView!
    @IBOutlet weak var viewTaiwanStatistic: UIView!
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var txtCity: UILabel!
    @IBOutlet weak var distTableView: UITableView!
    @IBOutlet weak var txtExclude: UILabel!
    @IBOutlet weak var txtComfirmCases: UILabel!
    @IBOutlet weak var txtDeath: UILabel!
    
    // Data
    private lazy var newDate = cityStatisticData[0].announcementDate
    private let covidModel = CovidModel()
    public var cityStatisticData:[CityStatistic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set Style
        let cityName = NSLocalizedString("City", comment: "").replace("{city}", cityStatisticData.first?.cityName ?? "")
        txtCity.text = cityName
        
        setViewStyle(view: viewChart)
        setViewStyle(view: viewDistStatistic)
        setViewStyle(view: viewTaiwanStatistic)
        
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
        
        distTableView.dataSource = self
        distTableView.delegate = self
        distTableView.register(UINib(nibName: DistStatisticTableViewCell.identity, bundle: nil), forCellReuseIdentifier: DistStatisticTableViewCell.identity)
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
        
        fetchData()
    }
    
    private func fetchData() {
        covidModel.getTaiwanStatistic(result: { data in
            DispatchQueue.main.async {
                self.txtExclude.text = data.totalExclude
                self.txtDeath.text = data.totalDeath
                self.txtComfirmCases.text = data.totalCases
            }
        })
    }
    
    @IBAction func btnBackEvent(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setViewStyle(view:UIView) {
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor(named: "MainShadowColor")?.cgColor
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
}

extension CovidStatisticViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityStatisticData.filter({$0.districtName != "全區" && $0.announcementDate == newDate }).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: DistStatisticTableViewCell.identity, for: indexPath) as! DistStatisticTableViewCell
        let data = cityStatisticData.filter({$0.districtName != "全區" && $0.announcementDate == newDate})[indexPath.row]
        cell.txtDistName.text = data.districtName
        cell.txtNewsCases.text = data.newCasesAmount
        cell.txtTotalCases.text = data.totalCasesAmount
        return cell
    }
}
