//
//  CityCovidWidget.swift
//  CovidWidgetExtension
//
//  Created by 葉家均 on 2022/5/16.
//

import Foundation
import WidgetKit
import SwiftUI

struct CityCovidWidget: Widget {
    let kind = "CityCovidWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: CityConfigurationIntent.self, provider: CityCovidProvider(), content: { entry in
            CityCovidView(entry: entry)
        })
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("City Covid Widget")
        .description("Show City Covid Statistic")
    }
}
