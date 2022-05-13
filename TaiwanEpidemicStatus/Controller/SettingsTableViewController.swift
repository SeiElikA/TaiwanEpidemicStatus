//
//  SettingsTableViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/9.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    public static var instance:SettingsTableViewController?
    
    @IBOutlet weak var cdcNewsUpdateTableCell: UITableViewCell!
    @IBOutlet weak var appLanguageTableCell: UITableViewCell!
    @IBOutlet weak var darkModeTableCell: UITableViewCell!
    @IBOutlet weak var aboutAsTableCell: UITableViewCell!
    @IBOutlet weak var bugReportTableCell: UITableViewCell!
    
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
        aboutAsTableCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(aboutAppClickEvent)))
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
    
    @objc private func aboutAppClickEvent() {
        performSegue(withIdentifier: "changeToPrivacyPolicy", sender: self)
    }
    
    @objc private func closeClickEvent() {
        self.dismiss(animated: true)
    }
}
