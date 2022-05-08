//
//  CovidModel.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/25.
//

import Foundation
import UIKit
import FastAPI

public class CovidModel {
    private let fastApi = FastAPI()
    
    public func getTaiwanStatistic(result: @escaping (TaiwanStatisticData) -> Void) {
        fastApi.get(url: "Covid/getTaiwanStatistic",header: JWTUtil.getJWTHeader(), { data, error in
            if case .requestError(let msg) = error {
                print(msg)
                return
            }
            
            if let data = data {
                do {
                    let taiwanData = try JSONDecoder().decode(TaiwanStatisticData.self, from: data)
                    result(taiwanData)
                } catch {
                    print(error)
                }
            }
        })
    }
    
    public func getCityList(result: @escaping ([String]) -> Void) {
        fastApi.get(url: "Covid/getCity", header: JWTUtil.getJWTHeader(), { data, error in
            if case .requestError(let msg) = error {
                print(msg)
                return
            }
            
            if let data = data {
                var cityList:[String] = []
                do {
                    cityList = try JSONDecoder().decode([String].self, from: data)
                } catch {
                    print("\(error)")
                }
                
                DispatchQueue.main.async {
                    result(cityList)
                }
            }
        })
    }
    
    public func getCitySatistic(cityName:String, _ cityDataList: @escaping ([CityStatistic]) -> Void) {
        fastApi.get(url: "Covid/getCityStatistic?city=" + cityName, header: JWTUtil.getJWTHeader(), { result, error in
            if case .requestError(let msg) = error {
                print(msg)
                return
            }
            
            if let result = result {
                let cityStisticList = (try? JSONDecoder().decode([CityStatistic].self, from: result)) ?? []
                DispatchQueue.main.async {
                    cityDataList(cityStisticList)
                }
            }
        })
    }
    
    public func saveSelectCity(cityName:String) {
        UserDefaults().set(cityName, forKey: "cityName")
    }
    
    public func getSelectCity() -> String {
        return UserDefaults().string(forKey: "cityName") ?? "新北市"
    }
}


