//
//  CityStatistic.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/25.
//

import Foundation
public struct CityStatistic:Decodable {
    var id:String = ""
    var judgmentDate:String = ""
    var announcementDate:String = ""
    var cityName:String = ""
    var districtName:String = ""
    var newCasesAmount:String = ""
    var totalCasesAmount:String = ""
}
