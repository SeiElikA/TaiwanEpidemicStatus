//
//  PassportModel.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/5.
//

import Foundation
import FastAPI

public class PassportModel {
    private let fastAPI = FastAPI()
    
    public func decodePassport(hc1:String, result: @escaping (Passport?, String?) -> Void) {
        let hc1Dic = ["HC1": hc1]
        let body = try? JSONSerialization.data(withJSONObject: hc1Dic, options: .prettyPrinted)
        fastAPI.post(url: "Passport/Decode",header: JWTUtil.getJWTHeader(), body: body) { data, error in
            if case .requestError(let msg) = error {
                result(nil, msg)
                return
            }
            
            if let data = data {
                let passportResult = try? JSONDecoder().decode(Passport.self, from: data)
                result(passportResult, nil)
            }
        }
    }
    
 
}
