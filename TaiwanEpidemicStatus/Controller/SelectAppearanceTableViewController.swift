//
//  SelectLanguageTableViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/9.
//

import UIKit

class SelectAppearanceTableViewController: UITableViewController {
    private var selectIndex:Int = 0
    
    @IBOutlet var cellCollection: [UITableViewCell]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectIndex = UserDefaults().integer(forKey: "selectIndex")
        
        cellCollection.forEach({
            let isSelect = cellCollection.firstIndex(of: $0) == selectIndex
            let imageView = UIImageView(image: UIImage(systemName: isSelect ? "checkmark.circle.fill" : "circle"))
            imageView.tintColor = isSelect ? .systemBlue : .gray
            $0.accessoryView = imageView
            
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectIndex != indexPath.row {
            let uncheckImage = UIImageView(image: UIImage(systemName: "circle"))
            uncheckImage.tintColor = .gray
            cellCollection[self.selectIndex].accessoryView = uncheckImage
            self.selectIndex = indexPath.row
            
            let checkImage = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
            checkImage.tintColor = .systemBlue
            cellCollection[self.selectIndex].accessoryView = checkImage
            UserDefaults().set(self.selectIndex, forKey: "selectIndex")
            if self.selectIndex == 0 {
                view.window?.overrideUserInterfaceStyle = .unspecified
            } else if self.selectIndex == 1 {
                view.window?.overrideUserInterfaceStyle = .dark
            } else {
                view.window?.overrideUserInterfaceStyle = .light
            }
            
            SettingsTableViewController.instance?.darkModeTableCell.detailTextLabel?.text = NSLocalizedString(Global.darkModeSelection[self.selectIndex], comment: "")
        }
    }
}
