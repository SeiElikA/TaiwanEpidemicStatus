//
//  AllNewsCollectionViewCell.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/1.
//

import UIKit

class AllNewsCollectionViewCell: UICollectionViewCell {
    public static var identity = "AllNewsCollectionViewCell"
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var txtNewsCaption: UILabel!
    @IBOutlet weak var newsPageControl: UIPageControl!
    @IBOutlet weak var loadImgActivityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgNews.layer.cornerRadius = 8
    }

}
