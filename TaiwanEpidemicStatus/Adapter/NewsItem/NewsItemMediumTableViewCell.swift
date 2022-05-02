//
//  NewsItemLargeTableViewCell.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/18.
//

import UIKit

class NewsItemMediumTableViewCell: UITableViewCell {
    public static let identity = "NewsItemMediumTableViewCell"
    @IBOutlet weak var txtContent: UILabel!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var viewController:UIViewController?
    var shareLink:String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Setting Style
        imgNews.layer.cornerRadius = 6
        txtDate.font = UIFont.roundedFont(txtDate.font.pointSize)
        txtContent.font = UIFont.roundedFont(txtContent.font.pointSize)
        txtTitle.font = UIFont.roundedBoldFont(txtTitle.font.pointSize)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
