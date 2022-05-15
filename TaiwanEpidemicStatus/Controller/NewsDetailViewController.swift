//
//  NewsDetailViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/28.
//

import UIKit
import WebKit
import GoogleMobileAds

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
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // if is udn news
    var newsContentImage:[Int:UIImage] = [:]
    var udnUrlString = ""
    var debugUrl = "https://udn.com/news/story/7332/6274560"
    
    // if is cdc news
    var cdcData: CDCNews?
    
    private var newsModel = NewsModel()
    private var testModel = TestModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initGoogleAds()
        // Set Navigation
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil

        // Set Title under line style
        viewUnderLine.layer.cornerRadius = viewUnderLine.bounds.height / 2
        
        imgCover.isUserInteractionEnabled = true
        imgCover.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openCoverImageEvent)))
        
        if let cdcData = cdcData {
            self.loadActivityindicator.stopAnimating()
            removeCoverImage()
            
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = format.date(from: cdcData.pubDate) ?? Date()
            format.dateFormat = "yyyy.MM.dd HH:mm"
        
            self.txtDate.text = format.string(from: date)
            self.txtTitle.text = cdcData.title
            self.txtSource.text = "Source: Taiwan Centers for Disease Control Official"
        
            let context = cdcData.content.replace("<br>", "").replace("&lt;br /&gt;", "").replace("&gt;", "").replace("\n", "\n\r")
            let label = getNewsLabel(text: context)
            self.stackNewsContent.addArrangedSubview(label)
        } else {
            self.checkNetwork()
        }
    }
    
    private func initGoogleAds() {
        if IAPManager.shared.getRemoveAdsStatus() {
            self.bannerView.removeFromSuperview()
            self.scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            return
        }
        
        bannerView.rootViewController = self
        bannerView.adUnitID = Global.adUnitID
        bannerView.load(GADRequest())

        bannerView.delegate = self
    }

    
    private func fetchNewsContent() {
        self.loadActivityindicator.fadeInAnimate(during: 0.5)
        self.loadActivityindicator.startAnimating()
        
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
            
            
            self.btnRefresh.isHidden = true
        }, serverNotRunning: {
            self.showServerNotRunningAlert()
        })
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
        let activityViewController = UIActivityViewController(activityItems: [URL(string: cdcData?.link ?? self.udnUrlString)!], applicationActivities: nil)
        present(activityViewController, animated: true)
    }
    
    private func getCoverImage(imgUrl:String?) {
        guard let imgUrl = imgUrl else {
            self.loadActivityindicator.stopAnimating()
            removeCoverImage()
            return
        }
        
        let dispatch = DispatchSemaphore(value: 0)
        
        if let existImg = Global.collectionImgTempList[self.udnUrlString] {
            self.imgCover.image = existImg
            dispatch.signal()
        } else {
            self.newsModel.getNewsImage(url: imgUrl, result: { img in
                DispatchQueue.main.async {
                    self.imgCover.image = img
                }
                dispatch.signal()
            })
        }
        
        dispatch.wait()
        
        self.imgCover.fadeInAnimate(during: 0.5)
        self.loadActivityindicator.fadeOutAnimate(during: 0.5, completion: {
            self.loadActivityindicator.stopAnimating()
        })
    }
    
    private func removeCoverImage() {
        // if not have coverimg, remove imgCover
        self.imgCover.translatesAutoresizingMaskIntoConstraints = false
        self.rootView.constraints.forEach({
            if $0.firstAnchor == imgCover.heightAnchor {
                rootView.removeConstraint($0)
            }
        })
        let constraint = self.imgCover.heightAnchor.constraint(equalToConstant: 52)
        constraint.isActive = true
    }
    
    private func checkNetwork() {
        testModel.testNetwork(networkError: { msg in
            print(msg)
            self.btnRefresh.isHidden = false
            self.loadActivityindicator.fadeOutAnimate(during: 0.5, completion: {
                self.loadActivityindicator.stopAnimating()
            })
        }, serverError: { msg in
            print(msg)
            self.showServerNotRunningAlert()
        }, successful: {
            self.fetchNewsContent()
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
            NewsModel().getNewsImage(url: newsImageUrl, result: { imgResult in
                DispatchQueue.main.async {
                    imgView.newsImage.image = imgResult
                    imgView.loadImageActivityIndicator.stopAnimating()
                    self.newsContentImage[img.index] = imgResult
                }
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
    
    @IBAction func btnReconnectedEvent(_ sender: Any) {
        self.checkNetwork()
    }
    
    private func showAlert(title:String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let cancelActin = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(cancelActin)
        present(alert, animated: true)
    }
}

extension NewsDetailViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        self.bannerView.removeFromSuperview()
        self.scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }
}
