//
//  TaiwanStatisticData.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/8.
//

import Foundation

public struct TaiwanStatisticData:Decodable {
    var totalCases:String
    var totalDeath:String
    var totalInspection:String
    var totalExclude:String
    var yesterdayCases:String
    var yesterdayExclude:String
    var yesterdayInspection:String
}
