//
//  OpenWeekCollectionViewCell.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/13.
//

import UIKit

class OpenWeekCollectionViewCell: UICollectionViewCell {
    public static let identity = "OpenWeekCollectionViewCell"

    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var txtWeekDay: UILabel!
    @IBOutlet weak var imgMorning: UIImageView!
    @IBOutlet weak var imgAfternoon: UIImageView!
    @IBOutlet weak var imgEvent: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewBackground.cornerRadius = 8
    }

}
