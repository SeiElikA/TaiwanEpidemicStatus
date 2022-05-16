//
//  IntentHandler.swift
//  IntentHandler
//
//  Created by 葉家均 on 2022/5/16.
//

import Intents
import Contacts
import WidgetKit

class IntentHandler: INExtension, CityConfigurationIntentHandling {
    private let cityList:[NSString] = [
        "基隆市",
        "台北市",
        "新北市",
        "桃園市",
        "新竹市",
        "新竹縣",
        "苗栗縣",
        "台中市",
        "彰化縣",
        "南投縣",
        "雲林縣",
        "嘉義市",
        "嘉義縣",
        "台南市",
        "高雄市",
        "屏東縣",
        "台東縣",
        "花蓮縣",
        "宜蘭縣",
        "澎湖縣",
        "金門縣",
        "連江縣",
        "境外移入"
    ]
    
    func provideCityOptionsCollection(for intent: CityConfigurationIntent, with completion: @escaping (INObjectCollection<NSString>?, Error?) -> Void) {
        completion(INObjectCollection(items: self.cityList), nil)
    }
}
