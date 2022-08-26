//
//  ViewController.swift
//  Weather
//
//  Created by James Baldwin on 7/26/22.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var currentWeatherLabel: UILabel!
    @IBOutlet weak var currentWeatherImage: UIImageView!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var weatherCollectionView: UICollectionView! {
        didSet {
            weatherCollectionView.delegate = self
            weatherCollectionView.dataSource = self
        }
    }
    
    let locationManager = CLLocationManager()
    var dailyWeather = DataService.shared.dailyWeather
    var hourlyWeather = DataService.shared.hourlyWeather
    var didSelectDaily = true
    var cityName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ask for Authorization from user
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        setGradient(color: UIColor.cyan.cgColor, color2: UIColor.blue.cgColor)
        DataService.weatherManager.delegate = self
        
    }
    @IBAction func hourlyButtonPressed(_ sender: UIButton) {
        didSelectDaily = false
        weatherCollectionView.reloadData()
    }
    
    @IBAction func weeklyButtonPressed(_ sender: UIButton) {
        didSelectDaily = true
        weatherCollectionView.reloadData()
    }
}

//MARK: - Functions
extension WeatherViewController {
    func setGradient(color: CGColor, color2: CGColor) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [color, color2]
        
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    //MARK: CreateCellData
    func createCellData(hourly: Hourly?, daily: Daily?) -> WeatherModel {
        if let hourly = hourly {
            let id = hourly.weather[0].id
            let temp = hourly.temp
            let dt = hourly.dt
            let weather = WeatherModel(conditionId: id, cityName: "", temperature: temp, dt: dt, description: "")
            
            return weather
        }
        
        if let daily = daily {
            let id = daily.weather[0].id
            let temp = daily.temp.max
            let dt = daily.dt
            let description = daily.weather[0].description
            let weather = WeatherModel(conditionId: id, cityName: "", temperature: temp, dt: dt, description: description)
            
            return weather
        }
        
        return WeatherModel(conditionId: 1, cityName: "", temperature: 0.0, dt: 0, description: "")
    }
}

//MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        let url = "\(DataService.weatherManager.BASE_URL)&lat=\(locValue.latitude)&lon=\(locValue.longitude)&appid=\(DataService.weatherManager.apiKey)&units=imperial"
        
        DataService.weatherManager.performRequest(with: url)
    }
}


//MARK: - CollectionView Delegate & DataSource
extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = weatherCollectionView.dequeueReusableCell(withReuseIdentifier: WeatherCollectionViewCell.reuseID, for: indexPath) as? WeatherCollectionViewCell {
            if !didSelectDaily {
                if !hourlyWeather.isEmpty {
                    let weatherData = hourlyWeather[indexPath.row]
                    let weather = createCellData(hourly: weatherData, daily: nil)
                    cell.updateCell(weatherModel: weather, isDaily: didSelectDaily)
                    return cell
                } else {
                    cell.updateCell(weatherModel: createCellData(hourly: nil, daily: nil), isDaily: didSelectDaily)
                    return cell
                }
            } else {
                if !dailyWeather.isEmpty {
                    let weatherData = dailyWeather[indexPath.row + 1]
                    let weather = createCellData(hourly: nil, daily: weatherData)
                    cell.updateCell(weatherModel: weather, isDaily: didSelectDaily)
                    return cell
                } else {
                    cell.updateCell(weatherModel: createCellData(hourly: nil, daily: nil), isDaily: didSelectDaily)
                    return cell
                }
            }
        }
        return UICollectionViewCell()
    }
}

//MARK: WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateCityName(_ weatherManager: WeatherManager, cityName: String) {
        self.currentLocationLabel.text = cityName
    }
    
    func didUpdateDaily(_ weatherManager: WeatherManager) {
        dailyWeather = DataService.shared.dailyWeather
        hourlyWeather = DataService.shared.hourlyWeather
        
        DispatchQueue.main.async {
            self.weatherCollectionView.reloadData()
        }
    }
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.currentTempLabel.text = ("\(weather.temperatureString)°")
            self.currentWeatherLabel.text = weather.description
            self.currentDateLabel.text = weather.formattedDate
            self.currentWeatherImage.image = UIImage(named: weather.conditionString)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error.localizedDescription)
    }
}
