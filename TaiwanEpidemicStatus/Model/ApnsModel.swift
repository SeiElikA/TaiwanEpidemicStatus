//
//  ApnsModel.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/10.
//

import Foundation
import FastAPI

public class ApnsModel {
    private let fastApi:FastAPI = FastAPI()
    private static let cdcNewsNoticeKey = "cdcNewsNoticeKey"
    
    public func addTokenToServer(token:String) {
        let dic = ["token":token]
        let body = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        fastApi.post(url: "/Apns/addDeviceToken", body: body,  {_,error in
            if case .requestError(let msg) = error {
                print(msg)
            }
        })
    }
    
    public static func isApnsOpen() -> Bool {
        return UserDefaults().bool(forKey: cdcNewsNoticeKey)
    }
    
    public static func setApnsOpen(isOpen:Bool) {
        UserDefaults().set(isOpen, forKey: ApnsModel.cdcNewsNoticeKey)
    }
}
