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
    private static let userDefaultNameToken = "JWTToken"
    private static let userDefaultNameTime = "JWTTime"
    private static let refreshTime = 10 // minute
    
    public static func getAuthBody() -> [String:String] {
        let uuid = UUID().uuidString
        let uuidAES = AESUtil.encrypt(key: aesKey, content: uuid) ?? ""
        return [
            "uuid" : "\(uuidAES)",
            "password" : "\(authPassword)"
        ]
    }
    
    public static func getRefreshBody() -> [String:String] {
        return [
            "token":"\(getToken())"
        ]
    }
    
    public static func getJWTHeader() -> [String:String] {
        return [
            "Authorization":"Bearer \(getToken())"
        ]
    }
    
    public static func saveToken(token:String) {
        UserDefaults().set(token, forKey: userDefaultNameToken)
    }
    
    public static func saveGetNextTokenTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let nextDate = Calendar.current.date(byAdding: .minute, value: JWTUtil.refreshTime, to: Date()) ?? Date()
        UserDefaults().set(formatter.string(from: nextDate), forKey: userDefaultNameTime)
    }
    
    public static func getGetNextTokenTime() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let dateString = UserDefaults().string(forKey: userDefaultNameTime) ?? ""
        return formatter.date(from: dateString) ?? Date().addingTimeInterval(-1)
    }
    
    public static func getToken() -> String {
        return UserDefaults().string(forKey: userDefaultNameToken) ?? ""
    }
    
    
    
    public static func refreshToken(complete: @escaping () -> Void = {}) {
        DispatchQueue.global(qos: .background).async {
            let authModel = AuthModel()
            var first = true
            
            while(true) {
                let semaphore = DispatchSemaphore(value: 0)
                if JWTUtil.getGetNextTokenTime() < Date() {
                    print("\(Date()): Refresh Token!")
                    authModel.refreshToken(result: {
                        saveToken(token: $0)
                        saveGetNextTokenTime()
                        semaphore.signal()
                    })
                } else {
                    semaphore.signal()
                }
                semaphore.wait()
                
                if first {
                    complete()
                    
                    first.toggle()
                }
                
                sleep(1)
            }
        }
    }
}
