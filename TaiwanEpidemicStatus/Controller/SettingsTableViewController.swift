//
//  SettingsTableViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/9.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    private let cdcNewsNoticeKey = ""
    
    @IBOutlet weak var cdcNewsUpdateTableCell: UITableViewCell!
    @IBOutlet weak var appLanguageTableCell: UITableViewCell!
    @IBOutlet weak var darkModeTableCell: UITableViewCell!
    @IBOutlet weak var aboutAsTableCell: UITableViewCell!
    @IBOutlet weak var bugReportTableCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeClickEvent))
        self.navigationItem.rightBarButtonItem = barButton
        
        // set cell style
        let switchView = UISwitch()
        switchView.isOn = UserDefaults().bool(forKey: cdcNewsNoticeKey)
        switchView.addTarget(self, action: #selector(cdcNewsNotificationChange), for: .valueChanged)
        cdcNewsUpdateTableCell.accessoryView = switchView
        
        // set click event
        bugReportTableCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openBugReportClickEvent)))
        appLanguageTableCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeAppLanguageClickEvent)))
        darkModeTableCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeDarkMode)))
        
        
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
        UserDefaults().set(uiSwitch.isOn, forKey: cdcNewsNoticeKey)
    }
    
    @objc private func closeClickEvent() {
        self.dismiss(animated: true)
    }
}
