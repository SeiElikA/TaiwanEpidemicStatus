//
//  BugReportViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/9.
//

import UIKit
import WebKit

class BugReportViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let request = URLRequest(url: URL(string: "https://www.google.com")!)
        webView.load(request)
    }
}
