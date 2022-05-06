//
//  LoadingGetPassportViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/5.
//

import UIKit

class LoadingGetPassportViewController: UIViewController {
    public var hc1Code:String?
    private var passportModel = PassportModel()
    private lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private lazy var coreDataModel = PassportEntityModel(context: context)
    private var timer:Timer?
    public var closeViewController: (() -> Void)?
    
    @IBOutlet weak var btnReconnected: UIButton!
    @IBOutlet weak var stackLoading: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presentingViewController?.view.alpha = 0
        
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(timeOut), userInfo: nil, repeats: false)
        
        passportModel.decodePassport(hc1: hc1Code ?? "", result: { passport, msg in
            DispatchQueue.main.async {
                self.timer?.invalidate()
                if let msg = msg {
                    print(msg)
                    let errorMsg = NSLocalizedString("HC1Error", comment: "")
                    let alertController = UIAlertController(title: "Error", message: errorMsg, preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                        self.backToPassportViewController()
                    })
                    alertController.addAction(action)
                    self.present(alertController, animated: true)
                    return
                }
                
                if let passport = passport {
                    // Save passport to core data
                    self.coreDataModel.insertPassport(passport: passport, hc1Code: self.hc1Code ?? "")
                    self.backToPassportViewController()
                    PassportViewController.instance?.reloadPassportData()
                    return
                }
                
                self.backToPassportViewController()
            }
        })
    }
    
    public func backToPassportViewController() {
        let viewController = self.navigationController?.viewControllers[1]
        self.navigationController?.popToViewController(viewController!, animated: true)
        timer?.invalidate()
    }
    
    @IBAction func btnReconnectedEvent(_ sender: Any) {
        self.btnReconnected.isHidden = true
        self.stackLoading.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(timeOut), userInfo: nil, repeats: false)
    }
    
    @objc private func timeOut() {
        timer?.invalidate()
        self.btnReconnected.isHidden = false
        self.stackLoading.fadeOutAnimate(during: 0.5) {
            self.stackLoading.isHidden = true
        }
    }
}
