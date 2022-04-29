//
//  NewsViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/29.
//

import UIKit

class NewsViewController: UIViewController {
    @IBOutlet weak var udnNewsTableView: UITableView!
    
    private let newsModel = NewsModel()
    private var newsPage = 0
    private var covidNewsList:[CovidNews] = [] {
        didSet {
            if isViewLoaded {
                // fade animation hide load news activity indicator
                UIView.animate(withDuration: 0.5, delay: 0, animations: {
                   // self.loadNewsActivityIndicator.alpha = 0
                }, completion: { _ in
                   // self.loadNewsActivityIndicator.stopAnimating()
                })
                self.udnNewsTableView.reloadData()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        udnNewsTableView.delegate = self
        udnNewsTableView.dataSource = self
        udnNewsTableView.register(UINib(nibName: NewsItemMediumTableViewCell.identity, bundle: nil), forCellReuseIdentifier: NewsItemMediumTableViewCell.identity)
        fetchNewsList()
    }
    
    private func fetchNewsList() {
        newsModel.getNewsList(page: newsPage, result: { list in
            self.covidNewsList = list
        }, timeOut: {
            
        })
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
