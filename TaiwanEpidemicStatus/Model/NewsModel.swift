//
//  NewsModel.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/26.
//

import Foundation
import FastAPI
import UIKit
import WebKit

public class NewsModel {
    private let fastAPI = FastAPI()
    
    public func getNewsImage(url:String, result: @escaping (UIImage) -> Void) {
        fastAPI.getImage(url: url, { data, error in
            if case .requestError(let msg) = error {
                print(msg)
                return
            }
            
            if let data = data {
                result(UIImage(data: data) ?? UIImage())
            }
        })
    }
    
    public func getAllNewsList(page:Int, result: @escaping ([CovidNews]) -> Void) {
        fastAPI.get(url: "News/getNews?page=\(page)",header: JWTUtil.getJWTHeader(), { data, error in
            if case .requestError(let msg) = error {
                print(msg)
                return
            }
            
            if let data = data {
                var covidNewsData:[CovidNews] = []
                do {
                    covidNewsData = try JSONDecoder().decode([CovidNews].self, from: data).filter({$0.titleLink.starts(with: "https://udn.com/news/story/")})
                } catch {
                    print("\(error)")
                }
                 
                result(covidNewsData)
            }
        })
    }
    
    public func getCDCNewsList(result: @escaping ([CDCNews]) -> Void) {
        fastAPI.get(url: "News/getCDCNews",header: JWTUtil.getJWTHeader(), { data, error in
            if case .requestError(let msg) = error {
                print(msg)
                return
            }
            
            if let data = data {
                var cdcNewsList:[CDCNews] = []
                do {
                    cdcNewsList = try JSONDecoder().decode([CDCNews].self, from: data)
                    
                    result(cdcNewsList)
                } catch {
                    print(error)
                }
            }
        })
    }
    
    public func getUDNNewsContent(url:String, _ content: @escaping ((UDNNews) -> Void), serverNotRunning: @escaping (() -> Void) = {}) {
        fastAPI.get(url: "News/getNewsContent?url=\(url)",header: JWTUtil.getJWTHeader(), { data, error in
            if case .requestError(let msg) = error {
                print(msg)
                if msg.starts(with: "5") {
                    DispatchQueue.main.async {
                        serverNotRunning()
                    }
                }
                return
            }
            
            if let data = data {
                do {
                    let udnNews = try JSONDecoder().decode(UDNNews.self, from: data)
                    DispatchQueue.main.async {
                        content(udnNews)
                    }
                } catch {
                    print("\(error)")
                }
            }
        })
    }
}
