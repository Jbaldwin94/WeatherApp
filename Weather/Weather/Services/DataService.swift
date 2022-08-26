//
//  DataService.swift
//  Weather
//
//  Created by James Baldwin on 7/26/22.


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
