//
//  CityCovidProvider.swift
//  CovidWidgetExtension
//
//  Created by 葉家均 on 2022/5/16.
//

import Foundation
import WidgetKit

struct CityCovidProvider:IntentTimelineProvider {
    typealias Entry = CityCovidEntry
    typealias Intent = CityConfigurationIntent
    
    func placeholder(in context: Context) -> CityCovidEntry {
        return CityCovidEntry.fackData
    }
    
    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (Entry) -> Void) {
        completion(CityCovidEntry.fackData)
    }
    
    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentDate = Date()
        var updateDate = 30
        var entry: Entry = CityCovidEntry.fackData
        
        let authModel = AuthModel()
        
        let selectCity = configuration.City ?? "新北市"
        let tokenDispatch = DispatchSemaphore(value: 0)
        

        authModel.getToken(result: {
            JWTUtil.saveToken(token: $0)
            tokenDispatch.signal()
        })
        
        tokenDispatch.wait()
        
        let dispatch = DispatchSemaphore(value: 0)
            CovidModel().getCitySatistic(cityName: selectCity) { list in
                let allData = list.first(where: {$0.districtName == "全區"})
                if let allData = allData {
                    entry = Entry(date: currentDate, configuration: configuration, cityData: allData, isError: false)
                } else {
                    entry = Entry(date: currentDate, configuration: configuration, cityData: nil, isError: true)
                }
                dispatch.signal()
            } requestError: { msg in
                entry = Entry(date: currentDate, configuration: configuration, cityData: nil, isError: true)
                updateDate = 10
                dispatch.signal()
            }
        
        dispatch.wait()
        
        let afterDate = Calendar.current.date(byAdding: .minute, value: updateDate, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(afterDate))
        completion(timeline)
    }
}
