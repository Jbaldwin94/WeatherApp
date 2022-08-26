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
 
    func updateCell(weatherModel: WeatherModel, isDaily: Bool) {
        let date = weatherModel.formattedDate
        let dateArray = date.components(separatedBy: "at")
        
        if isDaily {
            timeDateLabel.text = dateArray[0]
        } else {
            timeDateLabel.text = dateArray[1]
        }
        
        weatherImage.image = UIImage(named: weatherModel.conditionString)
        temperatureLabel.text = weatherModel.temperatureString
    }
    
    
    
}

