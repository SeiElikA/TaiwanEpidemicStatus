//
//  TaiwanCovidWidget.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/16.
//

import Foundation
import SwiftUI
import WidgetKit

struct TaiwanCovidWidget: Widget {
    let kind = "TaiwanCovidWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TaiwanCovidProvider(), content: { entry in
            TaiwanCovidWidgetView(entry: entry)
        })
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Taiwan Covid Statistic Widget")
        .description("Display Taiwan Covid Statistic")
    }
}
