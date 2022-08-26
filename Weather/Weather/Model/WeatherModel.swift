//
//  WeatherModel.swift
//  Weather
//
//  Created by James Baldwin on 8/22/22.
//

import Foundation

struct WeatherModel {
    let conditionId: Int
    let cityName: String
    let temperature: Double
    let dt: Int
    let description: String
    
    var temperatureString: String {
        return String(format: "%.0f", temperature)
    }
    
    var conditionString: String {
        switch conditionId {
        case 200...232:
            return "Lightning"
        case 300...321:
            return "Rainy"
        case 500...531:
            return "Rainy"
        case 600...622:
            return "Snow"
        case 800:
            return "Sunny"
        case 801...804:
            return "Cloudy"
        default:
            return "Sunny"
        }
    }
    
    var formattedDate: String {
        let date = Date(timeIntervalSince1970: TimeInterval(dt))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.timeZone = .current
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
}
