//
//  ExtensionMethod.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/26.
//

import Foundation

extension String{
    func replace(_ of:String, _ with:String) -> String {
        return self.replacingOccurrences(of: of, with: with)
    }
}
