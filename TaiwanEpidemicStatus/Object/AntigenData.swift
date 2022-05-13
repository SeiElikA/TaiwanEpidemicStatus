//
//  AntigenData.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/11.
//

import Foundation

public struct AntigenData:Decodable {
    var type:String
    var features: [Feature]
}

public struct Feature: Decodable {
    var type:String
    var properties: Properties
    var geometry: Geometry
}

public struct Properties: Decodable {
    var code:Int
    var name:String
    var address:String
    var longitude:Double
    var latitude:Double
    var brands:[String]
    var count:Int
    var phone:String
    var updated_at:String
    var open_week: OpenWeek?
    var note:String?
}

public struct Geometry:Decodable {
    var type:String
    var coordinates:[Double]
}

public struct OpenWeek:Decodable {
    var monday:Monday
    var tuesday:Tuesday
    var wednesday:Wednesday
    var thursday:Thursday
    var friday:Friday
    var saturday:Saturday
    var sunday:Sunday
}

public struct Monday:Decodable,Day {
    var morning:Bool
    var afternoon: Bool
    var evening: Bool
}

public struct Tuesday:Decodable,Day {
    var morning:Bool
    var afternoon: Bool
    var evening: Bool
}

public struct Wednesday:Decodable,Day {
    var morning:Bool
    var afternoon: Bool
    var evening: Bool
}

public struct Thursday:Decodable,Day {
    var morning:Bool
    var afternoon: Bool
    var evening: Bool
}

public struct Friday:Decodable,Day {
    var morning:Bool
    var afternoon: Bool
    var evening: Bool
}

public struct Saturday:Decodable,Day {
    var morning:Bool
    var afternoon: Bool
    var evening: Bool
}

public struct Sunday:Decodable,Day {
    var morning:Bool
    var afternoon: Bool
    var evening: Bool
}

protocol Day {
    var morning:Bool {get set}
    var afternoon: Bool {get set}
    var evening: Bool {get set}
}