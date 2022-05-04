//
//  PassportCollectionViewCell.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/4.
//

import UIKit

class PassportCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtVaccine: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtVaccineCount: UILabel!
    @IBOutlet weak var txtIssuedBy: UILabel!
    @IBOutlet weak var imgQRCode: UIImageView!
    
    public static let identity = "PassportCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        txtName.font = UIFont.roundedBoldFont(txtName.font.pointSize)
        txtVaccine.font = UIFont.roundedBoldFont(txtVaccine.font.pointSize)
        txtVaccineCount.font = UIFont.roundedBoldFont(txtVaccineCount.font.pointSize)
        txtDate.font = UIFont.roundedBoldFont(txtDate.font.pointSize)
        txtIssuedBy.font = UIFont.roundedBoldFont(txtIssuedBy.font.pointSize)
    }
}
