//
//  ConvertStringExtension.swift
//  myWeather
//
//  Created by Utsha Guha on 27-7-18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

import Foundation

extension String{
    
    static let AlbumEntity                  = "Album"
    
    func convertToFahrenheit(temperature: String) -> String {
        let fahrenheitTemperature = Double(temperature)! * 9 / 5 + 32
        return "\(String(fahrenheitTemperature))°F"
    }
}
