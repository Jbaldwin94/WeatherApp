//
//  Forecast.swift
//  Weather
//
//  Created by James Baldwin on 7/27/22.
//

import Foundation

struct Forecast: Codable {
    struct Weather: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct Main: Codable {
        let temp: Float
    }
    
}
