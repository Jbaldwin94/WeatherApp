//
//  WeatherResponse.swift
//  Weather
//
//  Created by James Baldwin on 8/23/22.
//

import Foundation

struct WeatherResponse: Codable {
    let lat: Double
    let lon: Double
    let timezone: String
    let current: Current
    var hourly: [Hourly]
    var daily: [Daily]
    
    mutating func sortHourlyArray() {
        hourly.sort {(hour1: Hourly, hour2: Hourly) -> Bool in
            return hour1.dt < hour2.dt
        }
    }
    
    mutating func sortDailyArray() {
        daily.sort{ (day1, day2) -> Bool in
            return day1.dt < day2.dt
        }
    }
}

struct Current: Codable {
    let dt: Int
    let sunrise: Int
    let temp: Double
    let feels_like: Double
    let weather: [Weather]
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
}

struct Hourly: Codable {
    let dt: Int
    let temp: Double
    let feels_like: Double
    let weather: [Weather]
}

struct Daily: Codable {
    let dt: Int
    let temp: Temperature
    let feels_like: Feels_Like
    let weather: [Weather]
}

struct Temperature: Codable {
    let day: Double
    let min: Double
    let max: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct Feels_Like: Codable {
    let day: Double
    let night: Double
    let eve: Double
    let morn: Double
}
