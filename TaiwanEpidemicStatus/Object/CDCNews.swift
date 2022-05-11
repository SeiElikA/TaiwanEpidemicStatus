//
//  CDCNews.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/2.
//

import Foundation

public struct CDCNews: Decodable {
    let author:String
    let categories:[String]
    let content:String
    let description:String
    let guid:String
    let link:String
    let pubDate:String
    let thumbnail:String
    let title:String
}
