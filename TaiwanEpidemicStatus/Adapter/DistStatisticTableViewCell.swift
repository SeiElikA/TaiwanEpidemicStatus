//
//  DistStatisticTableViewCell.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/8.
//

import UIKit

class DistStatisticTableViewCell: UITableViewCell {
    public static let identity = "DistStatisticTableViewCell"
    @IBOutlet weak var txtDistName: UILabel!
    @IBOutlet weak var txtNewsCases: UILabel!
    @IBOutlet weak var txtTotalCases: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
