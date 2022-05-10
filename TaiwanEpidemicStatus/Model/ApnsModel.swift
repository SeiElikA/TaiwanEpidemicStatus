//
//  ApnsModel.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/10.
//

import Foundation
import FastAPI

public class ApnsModel {
    let fastApi:FastAPI = FastAPI()
    
    
    public func addTokenToServer(token:String) {
        let dic = ["token":token]
        let body = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        fastApi.post(url: "/Apns/addDeviceToken", body: body,  {_,error in
            if case .requestError(let msg) = error {
                print(msg)
            }
        })
    }
}
