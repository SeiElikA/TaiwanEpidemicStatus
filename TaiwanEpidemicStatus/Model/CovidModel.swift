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
    let fastApi = FastAPI()
    
    init() {
    }
    
    public func getCityList(result: @escaping ([String]) -> Void) {
        fastApi.get(url: "Covid/getCity", { data, error in
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
        fastApi.get(url: "Covid/getCityStatistic?city=" + cityName, { result, error in
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
}


