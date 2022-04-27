//
//  JWTUtil.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/27.
//

import Foundation

public class JWTUtil {
    private static let aesKey = "m6Kq/zd0Q0mtOajsI64W2g=="
    private static let authPassword = "KNFuH8R/ikyCDOgWyQLNLA=="
    private static let userDefaultName = "JWTToken"
    
    public static func getAuthBody() -> [String:String] {
        let uuid = UUID().uuidString
        print(uuid)
        let uuidAES = AESUtil.encrypt(key: aesKey, content: uuid) ?? ""
        return [
            "uuid" : "\(uuidAES)",
            "password" : "\(authPassword)"
        ]
    }
    
    public static func getJWTHeader() -> [String:String] {
        return [
            "Authorization":"Bearer \(getToken())"
        ]
    }
    
    public static func saveToken(token:String) {
        UserDefaults().set(token, forKey: userDefaultName)
    }
    
    public static func getToken() -> String {
        return UserDefaults().string(forKey: userDefaultName) ?? ""
    }
}
