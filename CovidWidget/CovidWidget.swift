//
//  CovidWidget.swift
//  CovidWidget
//
//  Created by 葉家均 on 2022/5/16.
//

import WidgetKit
import SwiftUI

@main
struct CovidWidget: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        TaiwanCovidWidget()
        CityCovidWidget()
    }
}

