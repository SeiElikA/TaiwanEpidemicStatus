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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    result(UIImage(data: data) ?? UIImage())
                }
            }
        })
    }
    
    public func getNewsList(page:Int, result: @escaping ([CovidNews]) -> Void, timeOut: @escaping (() -> Void) = {}) {
        fastAPI.get(url: "News/getNews?page=\(page)",header: JWTUtil.getJWTHeader(), { data, error in
            if case .requestError(let msg) = error {
                if msg.contains("408") {
                    timeOut()
                }
                print(msg)
                return
            }
            
            if let data = data {
                var covidNewsData:[CovidNews] = []
                do {
                    covidNewsData = try JSONDecoder().decode([CovidNews].self, from: data)
                } catch {
                    print("\(error)")
                }
                 
                DispatchQueue.main.async {
                    result(covidNewsData)
                }
            }
        })
    }
    
    public func getUDNNewsContent(url:String, _ content: @escaping ((UDNNews) -> Void), serverNotRunning: @escaping (() -> Void) = {}) {
        fastAPI.get(url: "News/getNewsContent?url=\(url)",header: JWTUtil.getJWTHeader(), { data, error in
            if case .requestError(let msg) = error {
                print(msg)
                if msg.contains("Server Not Running") {
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
