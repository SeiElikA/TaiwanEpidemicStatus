//
//  Weather.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/30.
//

import Foundation
struct Weather:Decodable {
    let start:String
    let end:String
    let Wx:String
    let PoP:String
    let MinT:String
    let CI:String
    let MaxT:String
}
