//
//  NewsItemLargeTableViewCell.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/3.
//

import UIKit

class NewsItemLargeTableViewCell: UITableViewCell,BaseNewsItem {
    public static let identity = "NewsItemLargeTableViewCell"
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var txtCaption: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    public var shareLink:String?
    public var viewController:UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewBackground.layer.cornerRadius = 8
        viewBackground.layer.borderWidth = 0.5
        viewBackground.layer.borderColor = UIColor(named: "MainColor")?.cgColor
        
        txtTitle.font = UIFont.roundedBoldFont(txtTitle.font.pointSize)
        txtDate.font = UIFont.roundedFont(txtDate.font.pointSize)
        txtCaption.font = UIFont.roundedFont(txtCaption.font.pointSize)
    }
    
    @IBAction func btnShareEvent(_ sender: Any) {
        guard let shareLink = shareLink, let viewController = viewController else {
            return
        }
        
        let url = URL(string: shareLink)!
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        viewController.present(activityViewController, animated: true)
    }
    
}
