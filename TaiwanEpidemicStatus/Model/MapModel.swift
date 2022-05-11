//
//  MapModel.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/11.
//

import Foundation
import FastAPI
public class MapModel {
    private let fastApi = FastAPI()
    
    public func getAntigenData(result:@escaping (AntigenData) -> Void, Error: @escaping (String) -> Void) {
        fastApi.get(url: "Map/antigenData", header: JWTUtil.getJWTHeader()) { data, error in
            if case .requestError(let msg) = error {
                print(msg)
                Error(msg)
            }
            
            if let data = data {
                do {
                    let antigenData = try JSONDecoder().decode(AntigenData.self, from: data)
                    result(antigenData)
                }catch {
                    print(error)
                    Error(error.localizedDescription)
                }
            }
        }
    }
}
