//
//  DataService.swift
//  Weather
//
//  Created by James Baldwin on 7/26/22.
// API KEY: 234a1b73ac5569f5cb4b079feded64a6

import Foundation
import CoreLocation

class DataService {
    static let shared = DataService()
    static var weatherManager = WeatherManager()

    var dailyWeather = [Daily]()
    var hourlyWeather = [Hourly]()
    
    func addWeather (d: [Daily], h: [Hourly]) {
        dailyWeather = d
        hourlyWeather = h
    }
    
}
