//
//  FastAPI.swift
//  FastAPI
//
//  Created by 葉家均 on 2022/4/25.
//

import Foundation

public class FastAPI {
    private let errorMap = [
        404: "404 Not Found",
        403: "403 Forbidden",
        400: "400 Bad Request",
        401: "401 Unauthorized",
        500: "500 Internal Server Error"
    ]
    
    
    public init() {
    }
    
    public func get(url:String, _ callBack: @escaping ((Data?, APIError?) -> Void)) {
        request(url: url, callBack: callBack)
    }
    
    public func post(url:String, header:[String:String], body:Data, _ callBack: @escaping ((Data?, APIError?) -> Void)) {
        request(url: url,method: .post,headerMap: header, body: body ,callBack: callBack)
    }
    
    public func put(url:String, header:[String:String], body:Data, _ callBack: @escaping ((Data?, APIError?) -> Void)) {
        request(url: url,method: .put,headerMap: header, body: body ,callBack: callBack)
    }
    
    public func delete(url:String, _ callBack: @escaping ((Data?, APIError?) -> Void)) {
        request(url: url,method: .delete, callBack: callBack)
    }
    
    private func request(url:String, method:HttpMethod = .get, headerMap:[String:String] = [:], body:Data? = nil, callBack:  @escaping ((Data?, APIError?) -> Void)) {
        let encodeUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        var request = URLRequest(url: URL(string: Global.baseURL + encodeUrl)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        for (key,value) in headerMap {
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        func callBackSuccessful(data:Data) {
            callBack(data, nil)
        }
        
        func callBackFailure(error:APIError) {
            callBack(nil, error)
        }
        
        URLSession.shared.dataTask(with: request, completionHandler: { data , response, error in
            if let error = error {
                print(error)
                callBackFailure(error: .requestError(error.localizedDescription))
            }
            
            guard let response = response as? HTTPURLResponse else {
                return
            }
            
            if let data = data {
                // handle error
                if response.statusCode != 200 {
                    let responseContent = String(data: data, encoding: .utf8) ?? "Content Error"
                    let errorMsg = (self.errorMap[response.statusCode] ?? "Other Status Code Error") + responseContent
                    callBackFailure(error: .requestError(errorMsg))
                    return
                }
                
                // response data
                callBackSuccessful(data: data)
            }
        }).resume()
    }
}
