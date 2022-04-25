//
//  MainViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/18.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var txtTemperature: UILabel!
    @IBOutlet weak var viewSearchBox: UIView!
    @IBOutlet weak var viewCityStatisticBoard: UIView!
    @IBOutlet weak var btnCityStatisticMore: UIButton!
    @IBOutlet weak var btnNewsMore: UIButton!
    @IBOutlet weak var txtTotalCases: UILabel!
    @IBOutlet weak var txtTodayCases: UILabel!
    @IBOutlet weak var btnScan: UIButton!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var txtCityCases: UILabel!
    @IBOutlet weak var txtTotalCaseLabel: UILabel!
    @IBOutlet weak var txtTodayCasesLabel: UILabel!
    @IBOutlet weak var txtNewsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting Style
        navigationController?.isNavigationBarHidden = true
        
        txtTemperature.font = UIFont.roundedBoldFont(48)
        txtTotalCases.font = UIFont.roundedBoldFont(36)
        txtTodayCases.font = UIFont.roundedBoldFont(36)
        
        viewSearchBox.layer.borderColor = UIColor.white.cgColor
        viewSearchBox.layer.borderWidth = 0.8
        viewSearchBox.layer.cornerRadius = 4
        
        viewCityStatisticBoard.layer.cornerRadius = 8
        viewCityStatisticBoard.layer.shadowColor = UIColor.black.cgColor
        viewCityStatisticBoard.layer.shadowRadius = 6
        viewCityStatisticBoard.layer.shadowOpacity = 0.2
        viewCityStatisticBoard.layer.shadowOffset = CGSize(width: 0, height: 2)
        viewCityStatisticBoard.clipsToBounds = false
        
        // set button image from left to right
        btnNewsMore.semanticContentAttribute = .forceRightToLeft
        btnCityStatisticMore.semanticContentAttribute = .forceRightToLeft
        
        mainScrollView.decelerationRate = .fast
        btnScan.layer.cornerRadius = (btnScan.frame.height / 2)
        btnScan.layer.shadowOpacity = 0.3
        btnScan.layer.shadowRadius = 10
        
        newsTableView.dataSource = self
        newsTableView.delegate = self
        newsTableView.register(UINib(nibName: NewsItemLargeTableViewCell.identity, bundle: nil), forCellReuseIdentifier: NewsItemLargeTableViewCell.identity)
        
        viewNavigationBar.clipsToBounds = false
        viewNavigationBar.layer.cornerRadius = 16
        viewNavigationBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // 多國語言
        txtCityCases.text = NSLocalizedString("CityStatistic", comment: "")
        txtTotalCaseLabel.text = NSLocalizedString("TotalCases", comment: "")
        txtTodayCasesLabel.text = NSLocalizedString("TodayCases", comment: "")
        txtNewsLabel.text = NSLocalizedString("News", comment: "")
        btnNewsMore.setTitle(NSLocalizedString("More", comment: ""), for: .normal)
        btnCityStatisticMore.setTitle(NSLocalizedString("More", comment: ""), for: .normal)
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewsItemLargeTableViewCell = tableView.dequeueReusableCell(withIdentifier: NewsItemLargeTableViewCell.identity, for: indexPath) as! NewsItemLargeTableViewCell
        
        cell.clipsToBounds = false
        return cell
    }
}

