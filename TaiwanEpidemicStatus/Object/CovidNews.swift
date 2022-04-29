//
//  CovidNews.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/26.
//

import Foundation
public struct CovidNews:Decodable {
    var cateLink:String
    var cateTitle:String
    var paragraph:String
    var time:Times
    var title:String
    var titleLink:String
    var url:String
}

struct Times:Decodable {
    var date:String
    var dateTime:String
}
