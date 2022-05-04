//
//  PassportViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/3.
//

import UIKit

class PassportViewController: UIViewController {

    @IBOutlet weak var txtTest: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func btnBackEvent(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnScanQRCode(_ sender: Any) {
        let scanViewController = ScanQRCodeViewController()
        scanViewController.scanResult = { result in
            self.txtTest.text = result
            print(result)
        }
        self.navigationController?.pushViewController(scanViewController, animated: true)
    }
}
