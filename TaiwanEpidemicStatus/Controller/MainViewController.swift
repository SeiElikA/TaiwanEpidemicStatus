//
//  MainViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/18.
//

import UIKit

class MainViewController: UIViewController {
    // UI Component
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
    @IBOutlet weak var txtCityList: UILabel!
    @IBOutlet weak var loadNewsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var txtUpdateTime: UILabel!
    @IBOutlet weak var txtNetworkInfo: UIButton!
    
    // Model
    private let covidModel = CovidModel()
    private let newsModel = NewsModel()
    private let testModel = TestModel()
    private let authModel = AuthModel()
    
    // Data
    private var citySelectIndex = 12
    private var cityList:[String] = []
    private var covidNewsList:[CovidNews] = [] {
        didSet {
            if isViewLoaded {
                // fade animation hide load news activity indicator
                UIView.animate(withDuration: 0.5, delay: 0, animations: {
                    self.loadNewsActivityIndicator.alpha = 0
                }, completion: { _ in
                    self.loadNewsActivityIndicator.stopAnimating()
                })
                self.newsTableView.reloadData()
            }
        }
    }
    
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
        btnScan.layer.shadowOpacity = 0.1
        btnScan.layer.shadowRadius = 4
        
        newsTableView.dataSource = self
        newsTableView.delegate = self
        newsTableView.register(UINib(nibName: NewsItemMediumTableViewCell.identity, bundle: nil), forCellReuseIdentifier: NewsItemMediumTableViewCell.identity)
        
        // Set Select City
        txtCityList.text = covidModel.getSelectCity()
        
        // Bottom Navigation Bar
        viewNavigationBar.clipsToBounds = false
        viewNavigationBar.layer.cornerRadius = 16
        viewNavigationBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // click search box event
        viewSearchBox.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(btnSelectCity(_:))))
        
        // check network connection
        testModel.testNetwork(networkError: { msg in
            self.txtNetworkInfo.isHidden = false
            self.loadNewsActivityIndicator.stopAnimating()
        }, serverError: { msg in
            self.showServerError()
        }, successful: {
            // If token is not exist, get jwt token
            let group = DispatchGroup()
            
            group.enter()
            if JWTUtil.getToken().isEmpty {
                self.authModel.getToken(result: {
                    JWTUtil.saveToken(token: $0)
                    
                    JWTUtil.refreshToken() {
                        self.fetchData()
                    }
                })
            } else {
                JWTUtil.refreshToken() {
                    self.fetchData()
                }
            }
        })
    }
    
    @IBAction func btnReconnectedEvent(_ sender: Any) {
        self.txtNetworkInfo.isHidden = true
        self.loadNewsActivityIndicator.startAnimating()
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
            self.loadNewsActivityIndicator.alpha = 1
        })
        
        // check network connection
        testModel.testNetwork(networkError: { msg in
            self.txtNetworkInfo.isHidden = false
            self.loadNewsActivityIndicator.stopAnimating()
        }, serverError: { msg in
            self.showServerError()
        }, successful: {
            self.fetchData()
        })
    }
    
    public func showServerError() {
        let errorMsg = NSLocalizedString("ServerError", comment: "")
        let errorMsgTitle = NSLocalizedString("ServerErrorTitle", comment: "")
        let alertController = UIAlertController(title: errorMsgTitle, message: errorMsg, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .destructive, handler: { _ in
            exit(0)
        })
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
    @IBAction func btnSelectCity(_ sender: Any) {
        let navigationView = UINavigationController(rootViewController: SelectCityNavigationViewController())
        let viewController = navigationView.viewControllers.first as! SelectCityNavigationViewController
        viewController.selectCity = { index in
            let cityName = self.cityList[index]
            self.txtCityList.text = cityName
            self.getCityStatistic(cityName: cityName)
        }
        navigationController?.present(navigationView, animated: true)
    }
    
    private func fetchData() {
        // get City Statistic (first open application default city)
        let cityName = txtCityList.text ?? ""
        getCityStatistic(cityName: cityName)
        
        // get News
        newsModel.getNewsList(page: 1, result: {
            self.covidNewsList = Array($0.prefix(5))
        })
        
        covidModel.getCityList(result: {
            self.cityList = $0
        })
    }
    
    private func getCityStatistic(cityName:String) {
        covidModel.getCitySatistic(cityName: cityName, { result in
            let cityFirstStatistic = result[0]
            self.txtTotalCases.text = cityFirstStatistic.totalCasesAmount
            self.txtTodayCases.text = cityFirstStatistic.newCasesAmount
            self.txtUpdateTime.text = self.txtUpdateTime.text?.replace("{Date}", cityFirstStatistic.announcementDate.replace("-", "."))
        })
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return covidNewsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewsItemMediumTableViewCell = tableView.dequeueReusableCell(withIdentifier: NewsItemMediumTableViewCell.identity, for: indexPath) as! NewsItemMediumTableViewCell
        let covidNewsData = self.covidNewsList[indexPath.row]
        cell.txtTitle.text = covidNewsData.title
        cell.txtContent.text = covidNewsData.paragraph
        cell.txtDate.text = ParseUtil.covidNewsDateFormat(dateString: covidNewsData.time.dateTime)
        
        newsModel.getNewsImage(url: covidNewsData.url, result: {
            cell.imgNews.alpha = 0
            cell.imgNews.image = $0
            // show image use animation
            UIView.animate(withDuration: 0.5, delay: 0, animations: {
                cell.imgNews.alpha = 1
            }, completion: {_ in cell.activityIndicator.stopAnimating()})
        })
        
        cell.clipsToBounds = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // fade animation show tableview cell
        cell.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.05 * Double(indexPath.row), animations: {
            cell.alpha = 1
        })
    }
}
