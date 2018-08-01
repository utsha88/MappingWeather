//
//  DetailedWeatherViewController.swift
//  myWeather
//
//  Created by Utsha Guha on 25-7-18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class DetailedWeatherViewController: UIViewController,UICollectionViewDataSource {
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var selectedLocation:CLLocationCoordinate2D?
    var weatherDetail:[String:Any] = [:]
    var forecastArray = Array<[String:Any]>()
    var unitFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        unitFlag = UserDefaults.standard.value(forKey: ConstantString.kTempUnitKey) as! Bool
        self.activityIndicator.isHidden = false
        self.loadForecastForLocation(inputRequest: self.weatherRequest(locCoordinate: self.selectedLocation!))
    }
        
    func loadForecastForLocation(inputRequest:URLRequest) {
        let task = URLSession.shared.dataTask(with: self.weatherRequest(locCoordinate: self.selectedLocation!)){
            (data, response, error) in
            if error == nil{
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                self.drawCollectionViewForResponse(responseDictionary: responseDictionary!)
            }
        }
        task.resume()
    }
    
    func drawCollectionViewForResponse(responseDictionary:[String:Any]) {
        self.forecastArray = responseDictionary[ConstantString.kListKey] as! Array<[String : Any]>
        let cityDict:[String:Any] = responseDictionary[ConstantString.kCityKey] as! [String : Any]
        self.placeName.text = cityDict[ConstantString.kNameKey] as? String
        self.forecastCollectionView.reloadData()
        self.activityIndicator.isHidden = true
    }
    
    func weatherRequest(locCoordinate:CLLocationCoordinate2D) -> URLRequest {
        let urlString:String = "http://api.openweathermap.org/data/2.5/forecast?lat=\(locCoordinate.latitude)&lon=\(locCoordinate.longitude)&appid=c6e381d8c7ff98f0fee43775817cf6ad&units=metric"
        let myUrl = URL(string:urlString)
        let request = URLRequest(url:myUrl!)
        return request
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.forecastArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ForecastCellView = collectionView .dequeueReusableCell(withReuseIdentifier: ConstantString.kCollectionViewCellId, for: indexPath) as! ForecastCellView
        var rainInfo:String = ConstantString.kDefaultRain
        let listDict:[String:Any] = self.forecastArray[indexPath.row]
        let mainDict:[String:Any] = listDict[ConstantString.kMainKey] as! [String : Any]
        let windDict:[String:Any] = listDict[ConstantString.kWindKey] as! [String : Any]
        var rainDict:[String:Any] = [:]
        if listDict.keys.contains(ConstantString.kRainKey) {
            rainDict = listDict[ConstantString.kRainKey] as! [String : Any]
        }
        
        if rainDict.count>0 {
            rainInfo = String(describing: rainDict[ConstantString.k3HKey]!)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ConstantString.kJSONDateFormat
        let date = dateFormatter.date(from: listDict[ConstantString.kDateKey] as! String)!
        dateFormatter.dateFormat = ConstantString.kOutputDateFormat
        
        
        var temp = ConstantString.kBlank
        let flag = UserDefaults.standard.value(forKey: ConstantString.kTempUnitKey) as! Bool
        if flag{
            temp = "\(mainDict[ConstantString.kTempKey]!)°C"
        }
        else{
            let tempString:String = String(describing: mainDict[ConstantString.kTempKey]!)
            temp = tempString.convertToFahrenheit(temperature: tempString)
        }
        
        cell.cellTemp.text = temp
        cell.cellHumidity.text = "\(mainDict[ConstantString.kHumidityKey]!)%"
        cell.cellWind.text = "\(windDict[ConstantString.kSpeedKey]!) mph"
        cell.cellRain.text = "\(rainInfo)mm"
        cell.cellDate.text = dateFormatter.string(from: date)
        
        return cell
    }
}
