//
//  SelectCityNavigationViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/26.
//

import UIKit

class SelectCityNavigationViewController: UIViewController {
    @IBOutlet weak var cityTableView: UITableView!
    @IBOutlet weak var txtNetworkInfo: UILabel!
    @IBOutlet weak var loadCityActivityIndicator: UIActivityIndicatorView!
    private lazy var timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timeOut), userInfo: .none, repeats: false)
    
    private let covidModel = CovidModel()
    
    public var selectCity:((Int) -> Void)?
    private var cityList:[String] = [] {
        didSet {
            if isViewLoaded {
                cityTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // style setting
        self.title = "City Statistic"
        navigationController?.navigationBar.barTintColor = .systemGray6 // Change navigationbar color
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let searchController = UISearchController()
        searchController.searchBar.setShowsCancelButton(true, animated: true)
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController?.searchBar.delegate = self
        
        covidModel.getCityList(result: {
            self.cityList = $0
            self.txtNetworkInfo.isHidden = true
            self.timer.invalidate()
            self.hideActivityIndicator()
        })
        
        cityTableView.dataSource = self
        cityTableView.delegate = self
        cityTableView.register(UINib(nibName: SelectCityTableViewCell.identity, bundle: nil), forCellReuseIdentifier: SelectCityTableViewCell.identity)
    }
    
    @objc private func timeOut() {
        hideActivityIndicator()
        timer.invalidate()
        if !cityList.isEmpty {
            return
        }
        
        txtNetworkInfo.isHidden = false
    }
    
    private func hideActivityIndicator() {
        self.loadCityActivityIndicator.alpha = 1
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
            self.loadCityActivityIndicator.alpha = 0
        }, completion: { _ in
            self.loadCityActivityIndicator.stopAnimating()
        })
    }
}

extension SelectCityNavigationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectCityTableViewCell.identity, for: indexPath) as! SelectCityTableViewCell
        cell.txtTitle.text = self.cityList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        self.selectCity?(index)
        self.dismiss(animated: true)
    }
}

extension SelectCityNavigationViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true)
    }
}
