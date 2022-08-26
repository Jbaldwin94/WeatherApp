//
//  WeatherTableViewCell.swift
//  Weather
//
//  Created by James Baldwin on 7/26/22.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    static let reuseID = "weatherCell"
    
    @IBOutlet weak var timeDateLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
 
    func updateCell(weatherModel: WeatherModel) {
        timeDateLabel.text = weatherModel.cityName
        weatherImage.image = UIImage(named: weatherModel.conditionString)
        temperatureLabel.text = weatherModel.temperatureString
    }
    
    
    
}

