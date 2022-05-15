//
//  SettingsTableViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/9.
//

import UIKit
import StoreKit

class SettingsTableViewController: UITableViewController {
    public static var instance:SettingsTableViewController?
    
    @IBOutlet weak var cdcNewsUpdateTableCell: UITableViewCell!
    @IBOutlet weak var appLanguageTableCell: UITableViewCell!
    @IBOutlet weak var darkModeTableCell: UITableViewCell!
    @IBOutlet weak var privateTableCell: UITableViewCell!
    @IBOutlet weak var bugReportTableCell: UITableViewCell!
    @IBOutlet weak var removeAdsTableCell: UITableViewCell!
    @IBOutlet weak var restoreBuyRecordTableCell: UITableViewCell!
    @IBOutlet weak var buyCoffeeTableCell: UITableViewCell!
    @IBOutlet weak var aboutUsTableCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isModalInPresentation = true // disable drop down back previous viewController
        
        SettingsTableViewController.instance = self
        let barButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeClickEvent))
        self.navigationItem.rightBarButtonItem = barButton
        
        // set cell style
        let switchView = UISwitch()
        switchView.isOn = !ApnsModel.isApnsOpen()
        switchView.addTarget(self, action: #selector(cdcNewsNotificationChange), for: .valueChanged)
        cdcNewsUpdateTableCell.accessoryView = switchView
        // set dark mode select
        let darkModeSelection = UserDefaults().integer(forKey: "selectIndex")
        darkModeTableCell.detailTextLabel?.text = NSLocalizedString(Global.darkModeSelection[darkModeSelection], comment: "")
        // set this application language
        let countryCode = Bundle.main.preferredLocalizations.first ?? "" // get application language code
        let name = Locale.current.localizedString(forLanguageCode: countryCode) // change language code to full name
        appLanguageTableCell.detailTextLabel?.text = name
        
        
        // set click event
        bugReportTableCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openBugReportClickEvent)))
        appLanguageTableCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeAppLanguageClickEvent)))
        darkModeTableCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeDarkMode)))
        privateTableCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(aboutAppClickEvent)))
        removeAdsTableCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeGoogleAds)))
        restoreBuyRecordTableCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(restoreBuyRecord)))
        buyCoffeeTableCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buyCoffeeEvent)))
        aboutUsTableCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeToAboutUsEvent)))
    }
    
    @objc private func changeToAboutUsEvent() {
        performSegue(withIdentifier: "goToAboutUs", sender: self)
    }
    
    @objc private func buyCoffeeEvent() {
        if !IAPManager.shared.isDeviceCanPay() {
            let alertController = UIAlertController(title: "This device can't payment", message: nil, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
            return
        }
        
        
        let product = IAPManager.shared.products.first(where: {$0.productIdentifier == Global.buySmallCoffeeProductID})
        guard let product = product else {
            let alertController = UIAlertController(title: "Buy Failure", message: "Some thing wrong, please check your network status and restart application", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
            return
        }
        IAPManager.shared.buy(product: product)
    }
    
    @objc private func restoreBuyRecord() {
        SKPaymentQueue.default().restoreCompletedTransactions()
        let msg = NSLocalizedString("restoreSuccessful", comment: "")
        let alertController = UIAlertController(title: msg, message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @objc private func changeDarkMode() {
        performSegue(withIdentifier: "darkMode", sender: self)
    }
    
    @objc private func changeAppLanguageClickEvent() {
        let url = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(url)
    }
    
    @objc private func openBugReportClickEvent() {
        performSegue(withIdentifier: "bugReport", sender: self)
    }
    
    @objc private func cdcNewsNotificationChange(uiSwitch:UISwitch) {
        ApnsModel.setApnsOpen(isOpen: !uiSwitch.isOn)
        
        if uiSwitch.isOn {
            // 註冊遠程通知
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            // 取消註冊遠程通知
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }
    
    @objc private func removeGoogleAds() {
        if !IAPManager.shared.isDeviceCanPay() {
            let alertController = UIAlertController(title: "This device can't payment", message: nil, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
            return
        }
        
        if IAPManager.shared.getRemoveAdsStatus() {
            let alertController = UIAlertController(title: NSLocalizedString("HasRemoveAds", comment: ""), message: nil, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
            return
        }
        
        let product = IAPManager.shared.products.first(where: {$0.productIdentifier == Global.removeAdsProductID})
        guard let product = product else {
            let alertController = UIAlertController(title: "Buy Failure", message: "Some thing wrong, please check your network status and restart application", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
            return
        }
        IAPManager.shared.buy(product: product)
    }
    
    @objc private func aboutAppClickEvent() {
        performSegue(withIdentifier: "changeToPrivacyPolicy", sender: self)
    }
    
    @objc private func closeClickEvent() {
        self.dismiss(animated: true)
    }
}
