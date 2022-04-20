//
//  NewsItemLargeTableViewCell.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/18.
//

import UIKit

class NewsItemLargeTableViewCell: UITableViewCell {
    public static let identity = "NewsItemLargeTableViewCell"
    @IBOutlet weak var txtContent: UILabel!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var viewBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Setting Style
        viewBackground.layer.cornerRadius = 8
        imgNews.layer.cornerRadius = 8
        txtDate.font = UIFont.roundedFont(txtDate.font.pointSize)
        txtContent.font = UIFont.roundedFont(txtContent.font.pointSize)
        txtTitle.font = UIFont.roundedBoldFont(txtTitle.font.pointSize)
        viewBackground.layer.borderWidth = 0.5
        viewBackground.layer.borderColor = UIColor(named: "MainColor")?.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
