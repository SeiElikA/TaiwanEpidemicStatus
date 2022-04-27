//
//  SelectCityNavigationViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/26.
//

import UIKit

class SelectCityNavigationViewController: UIViewController {
    @IBOutlet weak var cityTableView: UITableView!
    @IBOutlet weak var txtNetworkInfo: UIButton!
    @IBOutlet weak var loadCityActivityIndicator: UIActivityIndicatorView!
    private var timer:Timer?
    
    private let covidModel = CovidModel()
    
    public var selectCity:((Int) -> Void)?
    private var searchCityList:[String] = [] {
        didSet {
            if isViewLoaded {
                self.cityTableView.reloadData()
            }
        }
    }
    
    private var cityList:[String] = [] {
        didSet {
            searchCityList = cityList
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
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController?.searchBar.delegate = self
        
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(timeOut), userInfo: .none, repeats: false)
        
        fetchData()
        
        cityTableView.dataSource = self
        cityTableView.delegate = self
        cityTableView.register(UINib(nibName: SelectCityTableViewCell.identity, bundle: nil), forCellReuseIdentifier: SelectCityTableViewCell.identity)
    }
    
    @IBAction func btnReconnectedEvent(_ sender: Any) {
        fetchData()
        
        txtNetworkInfo.isHidden = true
        loadCityActivityIndicator.startAnimating()
        loadCityActivityIndicator.alpha = 1
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(timeOut), userInfo: .none, repeats: false)
    }
    
    private func fetchData() {
        covidModel.getCityList(result: {
            if $0.isEmpty {
                return
            }
            self.cityList = $0
            self.txtNetworkInfo.isHidden = true
            self.timer?.invalidate()
            self.hideActivityIndicator()
        })
    }
    
    @objc private func timeOut() {
        hideActivityIndicator()
        timer?.invalidate()
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
        return searchCityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectCityTableViewCell.identity, for: indexPath) as! SelectCityTableViewCell
        cell.txtTitle.text = self.searchCityList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let selectCityName = searchCityList[index]
        covidModel.saveSelectCity(cityName: selectCityName)
        self.selectCity?(cityList.firstIndex(of: selectCityName) ?? 0)
        self.dismiss(animated: true)
    }
}

extension SelectCityNavigationViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let search = searchController.searchBar.text ?? ""
        if search.isEmpty {
            searchCityList = cityList
            return
        }
        
        searchCityList = cityList.filter({ city in
            city.localizedStandardContains(search)
        })
    }
}
