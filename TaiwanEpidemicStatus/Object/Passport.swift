//
//  Passport.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/5.
//

import Foundation

public struct Passport:Decodable {
    var name:String
    var birthday:String
    var v:v
}

public struct v:Decodable {
    var dose:Int
    var doses:Int
    var vaccine:String
    var date:String
    var country:String
}
