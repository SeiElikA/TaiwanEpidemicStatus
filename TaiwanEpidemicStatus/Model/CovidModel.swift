//
//  CovidModel.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/25.
//

import FastAPI
import Foundation

class CovidModel {
    public func getCityList() -> [String] {
        let fastAPI = FastAPI()
        fastAPI.get(url: "News/getNewsConten1t") { data, error in
            if case .requestError(let msg) = error {
                print(msg)
                return
            }
            
            if let data = data {
                let resultString = String(data: data, encoding: .utf8)
                print("Successful: " + resultString!)
            }
        }
        return []
    }
}
