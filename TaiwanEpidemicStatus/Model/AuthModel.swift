//
//  AuthModel.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/27.
//

import Foundation
import FastAPI
public class AuthModel {
    let fastAPI = FastAPI()
    
    public func getToken(result: @escaping (String) -> Void) {
        let body = try? JSONEncoder().encode(JWTUtil.getAuthBody())
        
        fastAPI.post(url: "Authentication/getToken", body: body) { data, error in
            if case .requestError(let msg) = error {
                print(msg)
                return
            }
            
            if let data = data {
                let token = String(data: data, encoding: .utf8) ?? ""
                DispatchQueue.main.async {
                    result(token)
                }
            }
        }
    }
}
