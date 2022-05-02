//
//  NewsViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/29.
//

import UIKit

class NewsViewController: UIViewController {
    @IBOutlet weak var allNewsTableView: UITableView!
    @IBOutlet weak var viewTabNavigation: UIView!
    @IBOutlet weak var allNewsCollection: UICollectionView!
    
    private let newsModel = NewsModel()
    private var newsPage = 0
    private var covidNewsList:[CovidNews] = [] {
        didSet {
            if isViewLoaded {
                self.allNewsTableView.reloadData()
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
        allNewsTableView.register(UINib(nibName: NewsItemMediumTableViewCell.identity, bundle: nil), forCellReuseIdentifier: NewsItemMediumTableViewCell.identity)
        
        // Setting CollectionView
        allNewsCollection.dataSource = self
        allNewsCollection.delegate = self
        allNewsCollection.register(UINib(nibName: AllNewsCollectionViewCell.identity, bundle: nil), forCellWithReuseIdentifier: AllNewsCollectionViewCell.identity)
        
        fetchNewsList()
    }
    
    private func fetchNewsList() {
        newsModel.getNewsList(page: newsPage, result: { list in
            self.covidNewsList = list
        }, timeOut: {
            
        })
    }
    
    @IBAction func btnCloseEvent(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return covidNewsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewsItemMediumTableViewCell = tableView.dequeueReusableCell(withIdentifier: NewsItemMediumTableViewCell.identity, for: indexPath) as! NewsItemMediumTableViewCell
        let covidNewsData = self.covidNewsList[indexPath.row]
        cell.txtTitle.text = covidNewsData.title
        cell.txtContent.text = covidNewsData.paragraph
        cell.txtDate.text = ParseUtil.covidNewsDateFormat(dateString: covidNewsData.time.dateTime)
        cell.shareLink = covidNewsData.titleLink
        cell.viewController = self
        
        newsModel.getNewsImage(url: covidNewsData.url, result: {
            cell.imgNews.alpha = 0
            cell.imgNews.image = $0
            // show image use animation
            UIView.animate(withDuration: 0.5, delay: 0, animations: {
                cell.imgNews.alpha = 1
            }, completion: {_ in cell.activityIndicator.stopAnimating()})
        })
        
        cell.tag = indexPath.row
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectNews(_:))))
        
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

extension NewsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ : UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllNewsCollectionViewCell.identity, for: indexPath) as! AllNewsCollectionViewCell
        return cell
    }
}
