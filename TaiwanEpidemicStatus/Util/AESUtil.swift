//
//  AESUtil.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/27.
//

import Foundation
import CryptoSwift

public class AESUtil {
    public static func encrypt(key: String, content:String) -> String? {
        let aes = try? AES(key: key.bytes, blockMode: ECB())
        let encrypted = try? aes?.encrypt(content.bytes)
        return encrypted?.toBase64()
    }
}
