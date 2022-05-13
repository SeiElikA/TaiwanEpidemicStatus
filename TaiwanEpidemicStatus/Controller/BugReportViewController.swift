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

extension BugReportViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping() -> Void) async {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: nil, style: .default, handler: { _ in
            completionHandler()
        }))
        self.present(alertController, animated: true)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            completionHandler(true)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            completionHandler(false)
        })
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.text = defaultText
        })
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            let text = alertController.textFields?[0].text ?? ""
            completionHandler(text)
        })
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true)
    }
}
