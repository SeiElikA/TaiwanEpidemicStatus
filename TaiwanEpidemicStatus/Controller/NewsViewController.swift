//
//  NewsViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/29.
//

import UIKit

class NewsViewController: UIViewController {
    @IBOutlet weak var allNewsTableView: ExpandTableView!
    @IBOutlet weak var cdcNewsTableView: ExpandTableView!
    @IBOutlet weak var viewTabNavigation: UIView!
    @IBOutlet weak var allNewsCollection: UICollectionView!
    @IBOutlet weak var txtCDCNews: UILabel!
    @IBOutlet weak var txtAllNews: UILabel!
    @IBOutlet weak var viewCDCNews: UIScrollView!
    @IBOutlet weak var viewAllNews: UIScrollView!
    @IBOutlet weak var mainViewBackground: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadNewsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnReconnected: UIButton!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtSmallTitle: UILabel!
    @IBOutlet weak var btnBackButton: UIButton!
    @IBOutlet weak var scrollViewAllNewsContent: UIView!
    private var timer:Timer?
    private var isTableFirstLoading = true
    
    private let newsModel = NewsModel()
    private let testModel = TestModel()
    private var newsPage = 0
    private var isAllNews = true
    
    private var covidNewsList:[CovidNews] = [] {
        didSet {
            self.allCollectionViewList = Array(covidNewsList.prefix(5))
            self.allTableViewList = covidNewsList.filter({ item in
                !allCollectionViewList.contains(where: { hasData in
                    hasData.title == item.title
                })
            })
        }
    }
    private var allTableViewList:[CovidNews] = [] {
        didSet {
            if isViewLoaded {
                self.allNewsTableView.reloadData()
            }
        }
    }
    private var allCollectionViewList:[CovidNews] = [] {
        didSet {
            if isViewLoaded {
                self.allNewsCollection.reloadData()
            }
        }
    }
    
    private var cdcTableViewList: [CDCNews] = [] {
        didSet {
            if isViewLoaded {
                cdcNewsTableView.reloadData()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting Style
        viewTabNavigation.layer.cornerRadius = viewTabNavigation.bounds.height / 2

        // Settign TableView
        allNewsTableView.delegate = self
        allNewsTableView.dataSource = self
        allNewsTableView.register(UINib(nibName: NewsItemLargeTableViewCell.identity, bundle: nil), forCellReuseIdentifier: NewsItemLargeTableViewCell.identity)
        allNewsTableView.register(UINib(nibName: NewsItemMediumTableViewCell.identity, bundle: nil), forCellReuseIdentifier: NewsItemMediumTableViewCell.identity)
        
        cdcNewsTableView.dataSource = self
        cdcNewsTableView.delegate = self
        cdcNewsTableView.register(UINib(nibName: NewsItemMediumNotImageTableViewCell.identity, bundle: nil), forCellReuseIdentifier: NewsItemMediumNotImageTableViewCell.identity)
        
        // Setting CollectionView
        allNewsCollection.dataSource = self
        allNewsCollection.delegate = self
        allNewsCollection.register(UINib(nibName: AllNewsCollectionViewCell.identity, bundle: nil), forCellWithReuseIdentifier: AllNewsCollectionViewCell.identity)
        
        // Add News Tab click event
        txtCDCNews.isUserInteractionEnabled = true
        txtCDCNews.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeNewsTabView)))
        
        txtAllNews.isUserInteractionEnabled = true
        txtAllNews.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeNewsTabView)))
        
        viewAllNews.delegate = self
        
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(networkError), userInfo: nil, repeats: false)
        fetchNewsList()
    }
    
    @objc private func networkError() {
        self.loadingView.isHidden = false
        self.btnReconnected.isHidden = false
        self.loadNewsActivityIndicator.isHidden = true
        self.timer?.invalidate()
    }
    
    private func fetchNewsList() {
        testModel.testNetwork(networkError: { msg in
            print(msg)
            self.networkError()
        }, serverError: { msg in
            print(msg)
            self.showServerNotRunningAlert()
        }, successful: {
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            self.newsModel.getAllNewsList(page: self.newsPage, result: { list in
                DispatchQueue.main.async {
                    self.covidNewsList = list
                }
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            self.newsModel.getCDCNewsList(result: { list in
                DispatchQueue.main.async {
                    self.cdcTableViewList = list
                }
                dispatchGroup.leave()
            })
            
            DispatchQueue.global().async {
                dispatchGroup.wait()
                
                dispatchGroup.notify(queue: .main, execute: {
                    self.loadingView.fadeOutAnimate(during: 0.5, completion: {
                        self.loadingView.isHidden = true
                        self.timer?.invalidate()
                    })
                })
            }
        })
    }
    
    @IBAction func btnReconntedEvent(_ sender: Any) {
        btnReconnected.isHidden = true
        loadNewsActivityIndicator.isHidden = false
        loadNewsActivityIndicator.startAnimating()
        loadNewsActivityIndicator.fadeInAnimate(during: 0.5)
        
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(networkError), userInfo: nil, repeats: false)
        self.fetchNewsList()
    }
    
    @IBAction func btnCloseEvent(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func selectNews(_ view:UIGestureRecognizer) {
        let index = view.view?.tag ?? 0
        let detailViewController = NewsDetailViewController()
        detailViewController.udnUrlString = self.covidNewsList[index].titleLink
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    @objc private func selectCDCNews(_ view: UIGestureRecognizer) {
        let index = view.view?.tag ?? 0
        let detailViewController = NewsDetailViewController()
        detailViewController.cdcData = self.cdcTableViewList[index]
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    @objc private func changeNewsTabView() {
        isAllNews.toggle()
        let newsViewWidth = self.viewAllNews.frame.width
        let textStartPosition = (isAllNews ? self.txtAllNews : self.txtCDCNews).frame.origin.x
        
        let animator = UIViewPropertyAnimator(duration: 0.15, curve: .linear) {
            self.viewTabNavigation.frame.origin.x = textStartPosition
            self.txtCDCNews.textColor = self.isAllNews ? .lightGray : UIColor(named: "MainShadowColor")
            self.txtAllNews.textColor = self.isAllNews ? UIColor(named: "MainShadowColor") : .lightGray
            self.viewAllNews.frame = self.viewAllNews.frame.offsetBy(dx: self.isAllNews ? newsViewWidth : -newsViewWidth, dy: 0)
            self.viewCDCNews.frame = self.viewCDCNews.frame.offsetBy(dx: self.isAllNews ? newsViewWidth : -newsViewWidth, dy: 0)
        }
        animator.startAnimation()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.contentOffset.y + scrollView.frame.height
        if scrollViewHeight == self.scrollViewAllNewsContent.bounds.height{
            self.newsPage += 1
            self.newsModel.getAllNewsList(page: self.newsPage, result: { list in
                DispatchQueue.main.async {
                    self.covidNewsList.append(contentsOf: list)
                }
            })
        }
    }
}

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return self.allTableViewList.count
        }
        return self.cdcTableViewList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.tag == 0 ? getAllTableViewCell(tableView: tableView, indexPath: indexPath) : getCDCTableViewCell(tableView: tableView, indexPath: indexPath)
        
        cell.layer.shadowColor = UIColor(named: "MainColor")?.cgColor
        cell.layer.shadowRadius = 3
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowOffset = CGSize(width: 0, height: 3)
        cell.clipsToBounds = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // fade animation show tableview cell
        if isTableFirstLoading {
            cell.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0.05 * Double(indexPath.row), animations: {
                cell.alpha = 1
            })
        }

        isTableFirstLoading = false
    }
    
    private func getAllTableViewCell(tableView:UITableView, indexPath:IndexPath) -> UITableViewCell {
        var cell: BaseNewsItem
        let covidNewsData = self.allTableViewList[indexPath.row]

        
        if let existImage = Global.collectionImgTempList[covidNewsData.titleLink] {
            cell = existImage.size.width <= 1200 ? tableView.dequeueReusableCell(withIdentifier: NewsItemMediumTableViewCell.identity, for: indexPath) as! NewsItemMediumTableViewCell : tableView.dequeueReusableCell(withIdentifier: NewsItemLargeTableViewCell.identity, for: indexPath) as! NewsItemLargeTableViewCell
            
            cell.imgNews.image = existImage
            cell.activityIndicator.fadeOutAnimate(during: 0.5)
            cell.activityIndicator.stopAnimating()
        } else {
            let random = [0,1].randomElement()
            cell = random == 0 ? tableView.dequeueReusableCell(withIdentifier: NewsItemMediumTableViewCell.identity, for: indexPath) as! NewsItemMediumTableViewCell : tableView.dequeueReusableCell(withIdentifier: NewsItemLargeTableViewCell.identity, for: indexPath) as! NewsItemLargeTableViewCell
            
            newsModel.getNewsImage(url: covidNewsData.url, result: { img in
                DispatchQueue.main.async {
                    cell.imgNews.image = img
                    Global.collectionImgTempList[covidNewsData.titleLink] = img
                    // show image use animation
                    cell.imgNews.fadeInAnimate(during: 0.5, completion: {
                        cell.activityIndicator.stopAnimating()
                    })
                }

            })
        }
        
        cell.txtTitle.text = covidNewsData.title
        cell.txtCaption.text = covidNewsData.paragraph
        cell.txtDate.text = ParseUtil.covidNewsDateFormat(dateString: covidNewsData.time.dateTime) + "｜" + covidNewsData.cateTitle
        cell.shareLink = covidNewsData.titleLink
        cell.viewController = self
        
        cell.tag = indexPath.row + 5
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectNews(_:))))
    
        return cell
    }
    
    private func getCDCTableViewCell(tableView:UITableView, indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsItemMediumNotImageTableViewCell.identity, for: indexPath) as! NewsItemMediumNotImageTableViewCell
        let data = cdcTableViewList[indexPath.row]
        
        cell.txtTitle.text = data.title
        cell.txtDate.text = data.pubDate.replace("-", ".")
        cell.txtDescription.text = data.description.replace("<br><br>", "")
        cell.viewController = self
        cell.shareLink = data.link
        
        cell.tag = indexPath.row
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectCDCNews(_:))))
        return cell
    }
}

extension NewsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ : UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allCollectionViewList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllNewsCollectionViewCell.identity, for: indexPath) as! AllNewsCollectionViewCell
        
        let data = self.allCollectionViewList[indexPath.row]
        cell.tag = indexPath.row
        cell.newsPageControl.currentPage = indexPath.row
        
        if let existNewsImg = Global.collectionImgTempList[data.titleLink] {
            cell.imgNews.image = existNewsImg
            cell.loadImgActivityIndicator.stopAnimating()
            cell.imgNews.fadeInAnimate(during: 0.5)
        } else {
            cell.imgNews.image = UIImage(named: "ImgPlaceHolder")
            cell.loadImgActivityIndicator.startAnimating()
            
            self.newsModel.getNewsImage(url: data.url, result: { img in
                DispatchQueue.main.async {
                    cell.imgNews.image = img
                    Global.collectionImgTempList[data.titleLink] = img
                    cell.loadImgActivityIndicator.stopAnimating()
                    cell.imgNews.fadeInAnimate(during: 0.5)
                }
            })
        }
        cell.txtNewsCaption.text = data.title
        
        cell.layer.shadowColor = UIColor(named: "MainColor")?.cgColor
        cell.layer.shadowRadius = 3
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowOffset = CGSize(width: 0, height: 3)
        cell.clipsToBounds = false
        
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectNews(_:))))
        
        return cell
    }
}
