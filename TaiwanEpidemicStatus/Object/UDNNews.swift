//
//  UDNNews.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/28.
//

import Foundation

public struct UDNNews:Decodable {
    let source:String
    let datetime:String
    let cover_img: UDNImg
    let title:String
    let post_blocks:[UDNBlock]
    let author:String
}

public struct UDNImg:Decodable {
    let caption:String?
    let formats:UDNImgFormat?
}

public struct UDNImgFormat:Decodable {
    let webp:String
    let large_jpeg:String
    let large_webp:String
    let jpeg:String
}

public struct UDNBlock:Decodable {
    let index:Int
    let text:String
    let video_url:String
    let image:UDNImg
    let block_type:String
}
