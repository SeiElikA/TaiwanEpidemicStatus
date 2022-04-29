//
//  NewsDetailViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/28.
//

import UIKit
import WebKit
import Social

class NewsDetailViewController: UIViewController{
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var viewUnderLine: UIView!
    @IBOutlet weak var stackNewsContent: UIStackView!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtSource: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var loadActivityindicator: UIActivityIndicatorView!
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var txtAuthor: UILabel!
    
    var newsContentImage:[Int:UIImage] = [:]
    var udnUrlString = ""
    var debugUrl = "https://udn.com/news/story/7332/6274560"
    
    private var newsModel = NewsModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Navigation
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil // UINavigationController Swipe Back

        // Set Title under line
        viewUnderLine.layer.cornerRadius = viewUnderLine.bounds.height / 2
        
        // get news content
        newsModel.getUDNNewsContent(url: udnUrlString, { data in
            self.getCoverImage(imgUrl: data.cover_img.formats?.large_jpeg)
            // title
            self.txtTitle.text = data.title
            
            // Source
            if !data.source.isEmpty {
                let sourceLocalized = NSLocalizedString("NewsSource", comment: "")
                self.txtSource.text = "\(sourceLocalized): \(data.source)"
            }
            
            // Author
            if !data.author.isEmpty {
                let authorLocalized = NSLocalizedString("NewsAuthor", comment: "")
                self.txtAuthor.text = "\(authorLocalized): \(data.author)"
            }
            
            // datetime
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd HH:mm"
            let date = format.date(from: data.datetime) ?? Date()
            format.dateFormat = "yyyy.MM.dd HH:mm"
            self.txtDate.text = format.string(from: date)
            
            // set news content
            var postBlock = data.post_blocks
            postBlock.sort(by: { $0.index < $1.index})
            postBlock.forEach({ block in
                if block.text != "\n" {
                    let component = self.getNewsComponent(block: block)
                    self.stackNewsContent.addArrangedSubview(component)
                }
            })
        }, serverNotRunning: {
            self.showServerNotRunningAlert()
        })
        
        imgCover.isUserInteractionEnabled = true
        imgCover.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openCoverImageEvent)))
    }
    
    @objc private func openCoverImageEvent() {
        if self.imgCover.image == nil {
            return
        }
        
        let viewController = NewsImagePreviewViewController()
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        viewController.previewImage = self.imgCover.image
        self.present(viewController, animated: true)
    }

    @IBAction func btnShareEvent(_ sender: Any) {
        let activityViewController = UIActivityViewController(activityItems: [URL(string: self.udnUrlString)!], applicationActivities: nil)
        present(activityViewController, animated: true)
    }
    
    private func showServerNotRunningAlert() {
        let serverErrorMsg = NSLocalizedString("ServerError", comment: "")
        let alertController = UIAlertController(title: "Error", message: serverErrorMsg, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .destructive, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        })
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
    private func getCoverImage(imgUrl:String?) {
        guard let imgUrl = imgUrl else {
            self.loadActivityindicator.stopAnimating()
            
            // if not have coverimg, remove imgCover
            self.imgCover.translatesAutoresizingMaskIntoConstraints = false
            self.rootView.constraints.forEach({
                if $0.firstAnchor == imgCover.heightAnchor {
                    rootView.removeConstraint($0)
                }
            })
            let constraint = self.imgCover.heightAnchor.constraint(equalToConstant: 52)
            constraint.isActive = true
            
            return
        }

        self.newsModel.getNewsImage(url: imgUrl, result: {
            self.imgCover.image = $0
            self.loadActivityindicator.stopAnimating()
        })
    }
    
    @IBAction func btnClose(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    public func getNewsComponent(block:UDNBlock) -> UIView {
        switch(block.block_type) {
        case "text":
            return getNewsLabel(text: block.text)
        case "image":
            return getNewsImageView(img: block)
        case "video":
            return getNewsVideo(videoUrl: block.video_url)
        case "title":
            return getNewsTitle(text: block.text)
        
        default:
            return UIView()
        }
    }
    
    private func getNewsLabel(text:String) -> UILabel {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = text + "\n"
        return label
    }
    
    private func getNewsImageView(img:UDNBlock) -> NewsImageView {
        let imgView = NewsImageView()
        let caption = img.image.caption ?? ""
        imgView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        imgView.newsCaption.text = caption
        imgView.isUserInteractionEnabled = true
        imgView.newsImage.isUserInteractionEnabled = true
        imgView.newsImage.tag = img.index
        imgView.newsImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openNewsContentImage(_:))))
        
        let newsImageUrl = img.image.formats?.large_jpeg ?? img.image.formats?.jpeg ?? nil
        if let newsImageUrl = newsImageUrl {
            NewsModel().getNewsImage(url: newsImageUrl, result: {
                imgView.newsImage.image = $0
                imgView.loadImageActivityIndicator.stopAnimating()
                self.newsContentImage[img.index] = $0
            })
        }

        return imgView
    }
    
    private func getNewsTitle(text:String) -> UILabel {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = UIColor(named: "NewsTitleColor")
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "\n" + text + "\n"
        return label
    }
    
    private func getNewsVideo(videoUrl:String) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), configuration: webConfiguration)
        
        let width = UIScreen.main.bounds.width
        let height = width * 9 / 16
        webView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        webView.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        let request = URLRequest(url: URL(string: videoUrl + "?playsinline=1")!)
        webView.load(request)
        webView.isUserInteractionEnabled = true
        return webView
    }
    
    @objc private func openNewsContentImage(_ view: UIGestureRecognizer) {
        let index = view.view?.tag ?? 0
        let img = newsContentImage[index]
        if img == nil {
            return
        }
        
        let viewController = NewsImagePreviewViewController()
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        viewController.previewImage = img
        self.present(viewController, animated: true)
    }
}
