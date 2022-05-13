//
//  DetailTableViewCell.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/13.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    public static let identity = "DetailTableViewCell"
    
    @IBOutlet weak var txtSubTitle: UILabel!
    @IBOutlet weak var txtTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
