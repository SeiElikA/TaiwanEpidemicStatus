//
//  Global.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/3.
//

import Foundation
import UIKit

public class Global {
    public static var collectionImgTempList:[String:UIImage] = [:]
    public static let darkModeSelection = [
        "WithSystem",
        "Dark",
        "Light"
    ]
    public static let antigenInfoURL = "https://ws.nhi.gov.tw/Download.ashx?u=LzAwMS9VcGxvYWQvMjkyL3JlbGZpbGUvMC8xNDk5MTgv6LKp6LOj5b%2Br56%2Bp6Kmm5YqR5a%2Bm5ZCN5Yi2cWEo5b2Z5pW054mIKTExMTA0MjdfdjIucGRm&n=6LKp6LOj5b%2Br56%2Bp6Kmm5YqR5a%2Bm5ZCN5Yi2UUEo5b2Z5pW054mIKTExMTA0MjdfVjIucGRm"
    
   // public static let adUnitID = "ca-app-pub-3940256099942544/2934735716" // test id
    public static let adUnitID = "ca-app-pub-5807172662201267/2451939724"
}
