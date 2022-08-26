//
//  WeatherManager.swift
//  Weather
//
//  Created by James Baldwin on 8/22/22.
//

import Foundation
import CoreLocation
import MapKit


protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didUpdateDaily(_ weatherManager: WeatherManager)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let apiKey = "234a1b73ac5569f5cb4b079feded64a6"
    
    let BASE_URL = "https://api.openweathermap.org/data/2.5/onecall?"
    
    var delegate: WeatherManagerDelegate?
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = parseJSON(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherResponse.self, from: weatherData)
            let id = decodedData.current.weather[0].id
            let temp = decodedData.current.temp
            let name = ""
            let dt = decodedData.current.dt
            let description = decodedData.current.weather[0].description
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp, dt: dt, description: description)

            let dailyArray = decodedData.daily
            let hourlyArray = decodedData.hourly
            DataService.shared.addWeather(d: dailyArray, h: hourlyArray)
            print("FIZZ: \(DataService.shared.dailyWeather)")
            delegate?.didUpdateDaily(self)
            
            print("BUZZ: \(DataService.shared.hourlyWeather)")
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}

