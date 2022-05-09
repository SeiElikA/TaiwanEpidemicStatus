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
            $0.accessoryView = UIImageView(image: UIImage(systemName: cellCollection.firstIndex(of: $0) == selectIndex ? "checkmark.circle.fill" : "circle"))
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectIndex != indexPath.row {
            cellCollection[self.selectIndex].accessoryView = UIImageView(image: UIImage(systemName: "circle"))
            self.selectIndex = indexPath.row
            cellCollection[self.selectIndex].accessoryView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
            UserDefaults().set(self.selectIndex, forKey: "selectIndex")
            if self.selectIndex == 0 {
                view.window?.overrideUserInterfaceStyle = .unspecified
            } else if self.selectIndex == 1 {
                view.window?.overrideUserInterfaceStyle = .dark
            } else {
                view.window?.overrideUserInterfaceStyle = .light
            }
        }
    }
}
