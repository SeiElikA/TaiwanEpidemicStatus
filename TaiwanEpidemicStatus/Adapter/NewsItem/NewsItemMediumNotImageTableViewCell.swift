//
//  NewsItemMediumNotImageTableViewCell.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/2.
//

import UIKit

class NewsItemMediumNotImageTableViewCell: UITableViewCell {
    public static let identity = "NewsItemMediumNotImageTableViewCell"
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtDescription: UILabel!
    @IBOutlet weak var imgShare: UIButton!
    @IBOutlet weak var txtDate: UILabel!
    
    public var viewController:UIViewController?
    public var shareLink:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewBackground.layer.cornerRadius = 8
        viewBackground.layer.borderWidth = 0.5
        viewBackground.layer.borderColor = UIColor(named: "MainColor")?.cgColor
    }
    
    @IBAction func btnShareEvent(_ sender: Any) {
        guard let shareLink = shareLink, let viewController = viewController else {
            return
        }
        
        let url = URL(string: shareLink)!
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        viewController.present(activityController, animated: true)
    }
}
