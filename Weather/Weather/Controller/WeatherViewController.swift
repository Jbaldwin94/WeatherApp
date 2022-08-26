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
    
    func formatDate(dt: Int, dailySelected: Bool) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(dt))
        let dateFormatter = DateFormatter()
        if dailySelected {
            dateFormatter.dateStyle = DateFormatter.Style.medium
        } else {
            dateFormatter.timeStyle = DateFormatter.Style.short
        }
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
        
        
        return localDate
    }
    
    func getCityName(location: CLLocationCoordinate2D) -> String {
        let lon = location.longitude
        let lat = location.latitude
        let loc = CLLocation(latitude: lat, longitude: lon)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(loc) { placemarks, error in
            if error == nil {
                let firstLocation = placemarks?[0].locality
                if let name = firstLocation {
                    self.cityName = name
                }
            } else {
                print(error?.localizedDescription)
            }
        }
        return cityName
    }
}

//MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        getCityName(location: locValue)
        
        let url = "\(DataService.weatherManager.BASE_URL)&lat=\(locValue.latitude)&lon=\(locValue.longitude)&appid=\(DataService.weatherManager.apiKey)&units=imperial"
        
        DataService.weatherManager.performRequest(with: url)
    }
    
    func getPlace(for location: CLLocation, completion: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil else {
                print("ERROR: \(String(describing: error))")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("ERROR: \(#function): placemark is nil")
                completion(nil)
                return
            }
            
            completion(placemark)
        }
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
                    let id = hourlyWeather[indexPath.row].weather[0].id
                    let temp = hourlyWeather[indexPath.row].temp
                    let dt = hourlyWeather[indexPath.row].dt
                    let date = formatDate(dt: dt, dailySelected: didSelectDaily)
                    print("DATE: \(date)")
                    let weather = WeatherModel(conditionId: id, cityName: date, temperature: temp, dt: dt, description: "")
                    cell.updateCell(weatherModel: weather)
                    return cell
                } else {
                    let weather = WeatherModel(conditionId: 301, cityName: "...", temperature: 0.0, dt: 0, description: "")
                    cell.updateCell(weatherModel: weather)
                    return cell
                }
            } else {
                if !dailyWeather.isEmpty {
                    let id = dailyWeather[indexPath.row + 1].weather[0].id
                    let temp = dailyWeather[indexPath.row + 1].temp.max
                    let dt = dailyWeather[indexPath.row + 1].dt
                    let date = formatDate(dt: dt, dailySelected: didSelectDaily)
                    let weather = WeatherModel(conditionId: id, cityName: "\(date)", temperature: temp, dt: dt, description: "")
                    cell.updateCell(weatherModel: weather)
                    return cell
                } else {
                    let weather = WeatherModel(conditionId: 301, cityName: "...", temperature: 0.0, dt: 0, description: "")
                    cell.updateCell(weatherModel: weather)
                    return cell
                }
            }
            
        }
        return UICollectionViewCell()
}

}

extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateDaily(_ weatherManager: WeatherManager) {
        dailyWeather = DataService.shared.dailyWeather
        hourlyWeather = DataService.shared.hourlyWeather
        
        DispatchQueue.main.async {
            self.weatherCollectionView.reloadData()
        }
        
    }
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.currentLocationLabel.text = self.cityName
            self.currentTempLabel.text = weather.temperatureString
            self.currentWeatherLabel.text = weather.description
            self.currentDateLabel.text = weather.formattedDate
            self.currentWeatherImage.image = UIImage(named: weather.conditionString)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    
}
