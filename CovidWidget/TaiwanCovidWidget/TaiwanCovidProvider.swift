//
//  TaiwanCovidProvider.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/16.
//

import Foundation
import WidgetKit

struct TaiwanCovidProvider: TimelineProvider {
    typealias SimpleEntry = TaiwanCovidEntry
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry.fackEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry.fackEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        var updateTime = 30
        var entry: SimpleEntry = TaiwanCovidEntry.fackEntry()
        let dispatch = DispatchSemaphore(value: 0)
        let tokenDispatch = DispatchSemaphore(value: 0)
        let authModel = AuthModel()
        
        authModel.getToken(result: {
            JWTUtil.saveToken(token: $0)
            tokenDispatch.signal()
        })
        
        tokenDispatch.wait()
            CovidModel().getTaiwanStatistic(result: { data in
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy.MM.dd HH:mm"
                entry = TaiwanCovidEntry(date: currentDate, updateDate: dateformatter.string(from: currentDate), confirmCases: data.yesterdayCases, isError: false)
                dispatch.signal()
            }, requestError: {
                print($0)
                updateTime = 10
                entry = TaiwanCovidEntry(date: Date(), updateDate: "", confirmCases: "0", isError: true)
                dispatch.signal()
            })
        
        dispatch.wait()

        let updateDate = Calendar.current.date(byAdding: .minute, value: updateTime, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(updateDate))
        completion(timeline)
    }
}
