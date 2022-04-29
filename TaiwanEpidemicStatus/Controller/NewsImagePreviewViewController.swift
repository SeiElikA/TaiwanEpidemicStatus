//
//  NewsImagePreviewViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/29.
//

import UIKit

class NewsImagePreviewViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var previewImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgNews.image = previewImage
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(btnCloseEvent(_:))))
        
        scrollView.delegate = self
    }
    
    @IBAction func btnCloseEvent(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgNews
    }
}
