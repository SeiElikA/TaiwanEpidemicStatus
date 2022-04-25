//
//  APIError.swift
//  FastAPI
//
//  Created by 葉家均 on 2022/4/25.
//

import Foundation
public enum APIError: Error {
    case requestError(String)
}
