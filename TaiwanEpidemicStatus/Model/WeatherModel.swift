//
//  WeatherModel.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/4/30.
//

import Foundation
import CoreLocation
import FastAPI
import UIKit

class WeatherModel {
    private let fastAPI = FastAPI()
    
    private func getCityName(location:CLLocation, result: @escaping (Location) -> Void) {
        let geoCoder = CLGeocoder()
        let locale = Locale(identifier: "zh_TW")
        geoCoder.reverseGeocodeLocation(location, preferredLocale: locale, completionHandler: { placeMarks, error in
            if let error = error {
                print("\(error)")
            }
            
            guard let placeMark = placeMarks?.first else {
                return
            }
            var location = CLLocation()
            var street = ""
            var city = ""
            var zip = ""
            var country = ""
            
            if let getLocation = placeMark.location {
                location = getLocation
            }
            
            if let getStreet = placeMark.thoroughfare {
                street = getStreet
            }
            
            if let getCity = placeMark.subAdministrativeArea {
                city = getCity
            }
            
            if let getZip = placeMark.isoCountryCode {
                zip = getZip
            }
            
            if let getCountry = placeMark.country {
                country = getCountry
            }
            
            result(Location(location: location, street: street, city: city, zip: zip, country: country))
        })
    }
    
    public func getWeatherIcon(wX:String) -> [UIImage?:UIColor] {
        switch(wX){
        case "陰短暫陣雨":
            return [UIImage(systemName: "cloud.drizzle"): UIColor.cyan]
        case "陰時多雲陣雨","陰陣雨":
            return [UIImage(systemName: "cloud.rain"): UIColor.systemBlue]
        default:
            return [UIImage(systemName: "sun.max"): UIColor.systemYellow]
        }
    }
    
    public func getWeatherData(location:CLLocation, weathers: @escaping ([Weather], String) -> Void ,timeOut: @escaping (() -> Void) = {}) {
        var cityName = ""
        let dispatch = DispatchSemaphore(value: 0)
        
        getCityName(location: location, result: {
            cityName = $0.city.replace("台", "臺")
            dispatch.signal()
        })
        
        dispatch.wait()
        
        fastAPI.get(url: "Weather/data?city=\(cityName)",header: JWTUtil.getJWTHeader(), { data, error in
            if case .requestError(let msg) = error {
                print(msg)
                if msg.contains("408") {
                    DispatchQueue.main.async {
                        timeOut()
                    }
                }
                return
            }
            
            if let data = data {
                do {
                    let weatherData = try JSONDecoder().decode([Weather].self, from: data)
                    DispatchQueue.main.async {
                        weathers(weatherData, cityName)
                    }
                } catch {
                    print("\(error)")
                }
            }
        })
    }
}
