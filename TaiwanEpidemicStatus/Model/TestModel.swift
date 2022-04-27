//
//  TestModel.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/26.
//

import Foundation
import FastAPI

public class TestModel {
    let fastApi = FastAPI()
    
    init() {
    }
    
    public func testNetwork(networkError: @escaping (String) -> Void, serverError: @escaping (String) -> Void, successful: @escaping () -> Void = {}) {
        fastApi.get(url: "/", { data, error in
            if case .requestError(let msg) = error {
                print(msg)
                DispatchQueue.main.async {
                    if msg.starts(with: "4") {
                        networkError(msg)
                    } else if msg.starts(with: "5") {
                        serverError(msg)
                    }
                }
                return
            }
            
            successful()
        })
    }
}
