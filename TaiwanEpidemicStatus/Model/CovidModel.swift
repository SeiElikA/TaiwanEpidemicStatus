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
    var txtCityList:UITextField?
    public var cityList:[String] = []
    public var cityStisticList:[CityStatistic] = []
    
    init() {
        getCityList()
    }
    
    public func getCityList() {
        fastApi.get(url: "Covid/getCity", { result, error in
            if case .requestError(let msg) = error {
                print(msg)
                return
            }
            
            if let result = result {
                self.cityList = (try? JSONDecoder().decode([String].self, from: result)) ?? []
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
                self.cityStisticList = (try? JSONDecoder().decode([CityStatistic].self, from: result)) ?? []
                DispatchQueue.main.async {
                    cityDataList(self.cityStisticList)
                }
            }
        })
    }
}


