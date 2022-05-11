//
//  BugReportViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/9.
//

import UIKit
import WebKit

class BugReportViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let request = URLRequest(url: URL(string: "https://feedback.kaijun.site")!)
        
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        webView.load(request)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}

extension BugReportViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none'", completionHandler: nil)
        self.webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none'", completionHandler: nil)
        self.webView.evaluateJavaScript("var script = document.createElement('meta');" +
                                        "script.name = 'viewport';" +
                                        "script.content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\";" +
                                        "document.getElementsByTagName('head')[0].appendChild(script);", completionHandler: nil)
    }
}
