//
//  TaiwanCovidEntry.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/16.
//

import Foundation
import WidgetKit
struct TaiwanCovidEntry: TimelineEntry {
    var date: Date
    var updateDate:String
    var confirmCases: String
    var isError:Bool
}

extension TaiwanCovidEntry {
    static var fackEntry = {
        return TaiwanCovidEntry(date: Date(), updateDate: "2022.01.01 10:31", confirmCases: "300", isError: false)
    }
}
