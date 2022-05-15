//
//  MainViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/18.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate {
    // UI Component
    @IBOutlet weak var imgWeatherIcon: UIImageView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var txtTemperature: UILabel!
    @IBOutlet weak var viewSearchBox: UIView!
    @IBOutlet weak var viewCityStatisticBoard: UIView!
    @IBOutlet weak var btnCityStatisticMore: UIButton!
    @IBOutlet weak var btnNewsMore: UIButton!
    @IBOutlet weak var txtTotalCases: UILabel!
    @IBOutlet weak var txtTodayCases: UILabel!
    @IBOutlet weak var btnMap: UIButton!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var txtCityCases: UILabel!
    @IBOutlet weak var txtTotalCaseLabel: UILabel!
    @IBOutlet weak var txtTodayCasesLabel: UILabel!
    @IBOutlet weak var txtNewsLabel: UILabel!
    @IBOutlet weak var txtCityList: UILabel!
    @IBOutlet weak var loadNewsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var txtUpdateTime: UILabel!
    @IBOutlet weak var txtNetworkInfo: UIButton!
    @IBOutlet weak var txtLocation: UILabel!
    private var timer:Timer?
    
    // Model
    private let covidModel = CovidModel()
    private let newsModel = NewsModel()
    private let testModel = TestModel()
    private let authModel = AuthModel()
    private let weatherModel = WeatherModel()
    
    // Data
    private var delayWeatherFetch = Date().timeIntervalSince1970
    private var isFirstFetchWeatherData = true
    private var locationManager = CLLocationManager()
    private var citySelectIndex = 12
    private var cityList:[String] = []
    private var isCityStatisticLoaded = false
    private var covidNewsList:[CovidNews] = [] {
        didSet {
            DispatchQueue.main.async {
                if self.isViewLoaded {
                    // fade animation hide load news activity indicator
                    self.loadNewsActivityIndicator.fadeOutAnimate(during: 0.5)
                    self.newsTableView.reloadData()
                }
            }
        }
    }
    private var cityStatisticData:[CityStatistic] = [] {
        didSet {
            isCityStatisticLoaded = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // set color
        let selectColor = UserDefaults().integer(forKey: "selectIndex")
        if selectColor == 0 {
            view.window?.overrideUserInterfaceStyle = .unspecified
        } else if selectColor == 1 {
            view.window?.overrideUserInterfaceStyle = .dark
        } else {
            view.window?.overrideUserInterfaceStyle = .light
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        viewCityStatisticBoard.layer.shadowColor = UIColor(named: "MainShadowColor")?.cgColor
        btnMap.layer.shadowColor = UIColor(named: "MainShadowColor")?.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting Style
        navigationController?.navigationBar.isHidden = true
        txtTemperature.font = UIFont.roundedBoldFont(48)
        
        viewSearchBox.layer.borderColor = UIColor.white.cgColor
        viewSearchBox.layer.borderWidth = 0.8
        viewSearchBox.layer.cornerRadius = 4
        
        viewCityStatisticBoard.layer.cornerRadius = 8
        viewCityStatisticBoard.layer.shadowColor = UIColor(named: "MainShadowColor")?.cgColor
        viewCityStatisticBoard.layer.shadowRadius = 6
        viewCityStatisticBoard.layer.shadowOpacity = 0.2
        viewCityStatisticBoard.layer.shadowOffset = CGSize(width: 0, height: 2)
        viewCityStatisticBoard.clipsToBounds = false
        
        // set button image from left to right
        btnNewsMore.semanticContentAttribute = .forceRightToLeft
        btnCityStatisticMore.semanticContentAttribute = .forceRightToLeft
        
        mainScrollView.decelerationRate = .fast
        btnMap.layer.cornerRadius = (btnMap.frame.height / 2)
        btnMap.layer.shadowOpacity = 0.1
        btnMap.layer.shadowRadius = 4
        btnMap.layer.shadowColor = UIColor(named: "MainShadowColor")?.cgColor
        
        
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
        
        // Set Text size
        let txtSize = txtTodayCases.font.pointSize > txtTotalCases.font.pointSize ? txtTotalCases.font.pointSize : txtTodayCases.font.pointSize
        txtTotalCases.font = UIFont.roundedBoldFont(txtSize)
        txtTodayCases.font = UIFont.roundedBoldFont(txtSize)
        
        // add scrollView Refresh
        let refreshControl = UIRefreshControl()
        mainScrollView.refreshControl = refreshControl
        mainScrollView.refreshControl?.addTarget(self, action: #selector(checkNetworkAndFetchData), for: .valueChanged)
        
        // Set Time out timer
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(networkError),userInfo: nil, repeats: false)
        setLocationManager()
        checkNetworkAndFetchData()
    }
    
    private func setLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // user 授權
        if locationManager.authorizationStatus == .denied {
            self.txtLocation.text = "Weather"
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 設定為最佳精度
        locationManager.startUpdatingLocation() // 開始update user 位置
    }
    
    @objc private func checkNetworkAndFetchData() {
        // check network connection
        testModel.testNetwork(networkError: { msg in
            print(msg)
            self.networkError()
        }, serverError: { msg in
            print(msg)
            self.showServerNotRunningAlert()
        }, successful: {
            // If token is not exist, get jwt token
            let dispatch = DispatchSemaphore(value: 0)
            if JWTUtil.getToken().isEmpty {
                self.authModel.getToken(result: {
                    JWTUtil.saveToken(token: $0)
                    dispatch.signal()
                })
            } else {
                dispatch.signal()
            }
            dispatch.wait()
            
            JWTUtil.refreshToken() {
                self.fetchData() {
                    self.timer?.invalidate()
                    DispatchQueue.main.async {
                        hideLoadView()
                    }
                }
            }
        })
        
        func hideLoadView() {
            self.loadNewsActivityIndicator.fadeOutAnimate(during: 0.5, completion: {
                self.txtNetworkInfo.isHidden = true
                self.loadNewsActivityIndicator.stopAnimating()
            })
            self.mainScrollView.refreshControl?.endRefreshing()
        }
    }
    
    @objc private func networkError() {
        self.covidNewsList = []
        self.txtNetworkInfo.isHidden = false
        self.loadNewsActivityIndicator.stopAnimating()
        self.mainScrollView.refreshControl?.endRefreshing()
        timer?.invalidate()
    }
    
    @IBAction func btnMoreStatisticEvent(_ sender: Any) {
        if !isCityStatisticLoaded {
            return
        }
        
        let statisticViewController = CovidStatisticViewController()
        statisticViewController.cityStatisticData = self.cityStatisticData
        self.navigationController?.pushViewController(statisticViewController, animated: true)
    }
    
    @IBAction func btnMoreNewsEvent(_ sender: Any) {
        let newsController = NewsViewController()
        self.navigationController?.pushViewController(newsController, animated: true)
    }
    
    @IBAction func btnReconnectedEvent(_ sender: Any) {
        self.txtNetworkInfo.isHidden = true
        self.loadNewsActivityIndicator.startAnimating()
        loadNewsActivityIndicator.fadeInAnimate(during: 0.5)
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(networkError),userInfo: nil, repeats: false)
        
        // check network connection
        testModel.testNetwork(networkError: { msg in
            print(msg)
            self.networkError()
        }, serverError: { msg in
            self.showServerNotRunningAlert()
        }, successful: {
            self.timer?.invalidate()
            DispatchQueue.global(qos: .background).async {
                self.fetchData()
            }
        })
    }
    
    @IBAction func btnMapClickEvent(_ sender: Any) {
        self.navigationController?.pushViewController(MapViewController(), animated: true)
    }
    
    @IBAction func btnSettingEvent(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "SettingStoryboard", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SettingNavigationController")
        viewController.modalPresentationStyle = .automatic
        self.navigationController?.present(viewController, animated: true)
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
    
    @IBAction func btnPassportEvent(_ sender: Any) {
//        navigationController?.pushViewController(PassportViewController(), animated: true)
        
        let url = URL(string: Global.passportURL)!
        UIApplication.shared.open(url)
    }
    
    private func fetchData(complection: (() -> Void)? = nil) {
        // get City Statistic (first open application default city)
        let dispatchGroup = DispatchGroup()
        var cityName = ""
        cityName = self.covidModel.getSelectCity()
        
        getCityStatistic(cityName: cityName)
        // get News
        dispatchGroup.enter()
        newsModel.getAllNewsList(page: 1, result: {
            self.covidNewsList = Array($0.prefix(5))
            dispatchGroup.leave()
        })
        
        dispatchGroup.enter()
        covidModel.getCityList(result: {
            self.cityList = $0
            dispatchGroup.leave()
        })
        
        dispatchGroup.wait()
        complection?()
    }
    
    private func getCityStatistic(cityName:String) {
        covidModel.getCitySatistic(cityName: cityName, { result in
            if result.isEmpty {
                return
            }
            self.cityStatisticData = result
            let cityFirstStatistic = result[0]
            self.txtTotalCases.text = cityFirstStatistic.totalCasesAmount
            self.txtTodayCases.text = cityFirstStatistic.newCasesAmount
            self.txtUpdateTime.text = self.txtUpdateTime.text?.replace("{Date}", cityFirstStatistic.announcementDate.replace("-", "."))
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // delay 30 min
        if Date().timeIntervalSince1970 - delayWeatherFetch > 30 * 60 || self.isFirstFetchWeatherData {
            self.delayWeatherFetch = Date().timeIntervalSince1970
            self.isFirstFetchWeatherData = false
            DispatchQueue.global(qos: .background).async {
                let userLocation = locations[0]
                self.weatherModel.getWeatherData(location: userLocation, weathers: {
                    let data = $0[0]
                    self.txtLocation.text = $1
                    self.txtTemperature.text = data.MaxT == data.MinT ? "\(data.MinT)°C" : "\(data.MinT)~\(data.MaxT)°C"
                    let weatherIcon = self.weatherModel.getWeatherIcon(wX: data.Wx)
                    self.imgWeatherIcon.tintColor = weatherIcon.first?.value
                    self.imgWeatherIcon.image = weatherIcon.first?.key
                }, timeOut: {
                    let weatherError = NSLocalizedString("WeatherError", comment: "")
                    self.txtLocation.text = weatherError
                })
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .denied {
            self.txtLocation.text = "Weather"
        }
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
        cell.txtCaption.text = covidNewsData.paragraph
        cell.txtDate.text = ParseUtil.covidNewsDateFormat(dateString: covidNewsData.time.dateTime) + "｜" + covidNewsData.cateTitle
        cell.shareLink = covidNewsData.titleLink
        cell.viewController = self
        
        if let existImage = Global.collectionImgTempList[covidNewsData.titleLink] {
            cell.imgNews.image = existImage
            cell.activityIndicator.fadeOutAnimate(during: 0.5)
            cell.activityIndicator.stopAnimating()
        } else {
            newsModel.getNewsImage(url: covidNewsData.url, result: { img in
                DispatchQueue.main.async {
                    cell.imgNews.image = img
                    Global.collectionImgTempList[covidNewsData.url] = img
                    // show image use animation
                    cell.imgNews.fadeInAnimate(during: 0.5, completion: {
                        cell.activityIndicator.stopAnimating()
                    })
                }
            })
        }
        
        cell.tag = indexPath.row  
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectNews(_:))))
        
        cell.layer.shadowColor = UIColor(named: "MainColor")?.cgColor
        cell.layer.shadowRadius = 3
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowOffset = CGSize(width: 0, height: 3)
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
    
    @objc private func selectNews(_ view:UIGestureRecognizer) {
        let index = view.view?.tag ?? 0
        let detailViewController = NewsDetailViewController()
        detailViewController.udnUrlString = self.covidNewsList[index].titleLink
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}
