//
//  WeatherResponse.swift
//  Weather
//
//  Created by James Baldwin on 7/26/22.
//

import Foundation

struct WeatherResponse: Codable {
    let lat: Double
    let lon: Double
    let timezone: String
    let current: Current
    var hourly: [Hourly]
    var daily: [Daily]

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
