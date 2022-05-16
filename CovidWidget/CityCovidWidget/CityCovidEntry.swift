//
//  CityCovidEntry.swift
//  CovidWidgetExtension
//
//  Created by 葉家均 on 2022/5/16.
//

import Foundation
import WidgetKit

struct CityCovidEntry:TimelineEntry {
    var date: Date
    let configuration: CityConfigurationIntent
    let cityData: CityStatistic?
    let isError: Bool
}

extension CityCovidEntry {
    static var fackData:CityCovidEntry {
        let cityStatistic = CityStatistic.init(id: "", judgmentDate: "2022/01/01", announcementDate: "2022/01/01", cityName: "新北市", districtName: "全區", newCasesAmount: "3000", totalCasesAmount: "3000")
        return CityCovidEntry(date: Date(), configuration: CityConfigurationIntent(), cityData: cityStatistic, isError: false)
    }
}
