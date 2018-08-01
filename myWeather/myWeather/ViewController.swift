//
//  ViewController.swift
//  myWeather
//
//  Created by Utsha Guha on 25-7-18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

import UIKit
import MapKit
import CoreData

struct ConstantString {
    static let kResetAllNotification                    = "resetAll"
    static let kTempUnitKey                             = "UnitKey"
    static let kCoreDataPlaceEntity                     = "PlaceEntity"
    static let kPlaceAttribute                          = "location"
    static let kCoreDataGenericMessage                  = "There is some issue while loading/saving the existing data. Please try again later."
    static let kBookmarkAlertMessage                    = "This place is already bookmarked!"
    static let kError                                   = "Error"
    static let kAlert                                   = "Alert"
    static let kOk                                      = "OK"
    static let kComma                                   = ","
    static let kBlank                                   = ""
    static let kDefaultRain                             = "0"
    static let kWindKey                                 = "wind"
    static let kRainKey                                 = "rain"
    static let kNameKey                                 = "name"
    static let kMainKey                                 = "main"
    static let kTempKey                                 = "temp"
    static let kListKey                                 = "list"
    static let kCityKey                                 = "city"
    static let k3HKey                                   = "3h"
    static let kDateKey                                 = "dt_txt"
    static let kHumidityKey                             = "humidity"
    static let kSpeedKey                                = "speed"
    static let kDetailWeatherSegue                      = "detailedWeather"
    static let kCollectionViewCellId                    = "forecastCell"
    static let kJSONDateFormat                          = "yyyy-MM-dd HH:mm:ss"
    static let kOutputDateFormat                        = "dd MMM ha"
    static let kHelpStaticWebPage                       = "Overview"
    static let kHelpStaticWebPageFormat                 = "html"
    static let kMapViewPinID                            = "pin"
    static let kMapLocDistance                          = 5000
    
    static let kUnitTestBookmarkError                   = "None of the locations are bookmarked."
    static let kUnitTestCurrLocError                    = "Current location is not proper."
    static let kUnitTestSaveCDError                     = "Saving to Core Data is failed."
    static let kUnitTestDelCDError                      = "Deleting in Core Data is failed."
    static let kUnitTestBookrkError                     = "Bookmark is failed."
    static let kUnitTestResetError                      = "Reset Bookmark did not work."

}


class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    @IBOutlet weak var gpsButton: UIButton!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    @IBOutlet weak var helpButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var currentPlace: UILabel!
    @IBOutlet weak var placeField: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let locManager = CLLocationManager()
    let regionRadius: CLLocationDistance = CLLocationDistance(ConstantString.kMapLocDistance)
    var currentLocation: CLLocation!
    var selectedLocation:CLLocationCoordinate2D?
    var celFlag = true
    
    var savedCoordinate:[String] = []
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(resetAll(notification:)), name: NSNotification.Name(rawValue: ConstantString.kResetAllNotification), object: nil)
        if (UserDefaults.standard.value(forKey: ConstantString.kTempUnitKey) != nil) {
            let flag:Bool = UserDefaults.standard.value(forKey: ConstantString.kTempUnitKey) as! Bool
            if self.celFlag != flag {
                initialLoad()
                self.celFlag = flag
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserDefaults.standard.value(forKey: ConstantString.kTempUnitKey) != nil) {
            self.celFlag = UserDefaults.standard.value(forKey: ConstantString.kTempUnitKey) as! Bool
        }
        self.initialLoad()
    }

    func resetAll(notification: NSNotification) {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
        getCurrentLocation()
    }
    
    func initialLoad() {
        self.toolbarButtonInitialState()
        self.savedCoordinate.removeAll()
        self.savedCoordinate = self.FetchFromCoreData()
        for coordinate in self.savedCoordinate {
            let lat = Double(coordinate.components(separatedBy: ConstantString.kComma).first!)
            let lon = Double(coordinate.components(separatedBy: ConstantString.kComma).last!)
            self.getWeatherReportForLocation(locCoordinate: CLLocationCoordinate2DMake(lat!, lon!),currentLocation: false)
        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
        getCurrentLocation()
    }
    
    func getCurrentLocationCoordinate() -> CLLocationCoordinate2D {
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestAlwaysAuthorization()
        locManager.startUpdatingHeading()
        currentLocation = locManager.location
        let initialLocation = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        return initialLocation.coordinate
    }
    
    func getCurrentLocation() {
        self.getWeatherReportForLocation(locCoordinate: self.getCurrentLocationCoordinate(),currentLocation: true)
    }
    
    func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            print(coordinate)
            getWeatherReportForLocation(locCoordinate: coordinate,currentLocation: false)
        }
    }
    
    func weatherRequest(locCoordinate:CLLocationCoordinate2D) -> URLRequest {
        self.helpButton.isEnabled = false
        self.settingsButton.isEnabled = false
        self.deleteButton.isEnabled = false
        self.bookmarkButton.isEnabled = false
        let urlString:String = "http://api.openweathermap.org/data/2.5/weather?lat=\(locCoordinate.latitude)&lon=\(locCoordinate.longitude)&appid=c6e381d8c7ff98f0fee43775817cf6ad&units=metric"
        let myUrl = URL(string:urlString)
        let request = URLRequest(url:myUrl!)
        return request
    }
    
    func getWeatherReportForLocation(locCoordinate:CLLocationCoordinate2D, currentLocation:Bool) {
        self.activityIndicator.isHidden = false
        let task = URLSession.shared.dataTask(with: self.weatherRequest(locCoordinate: locCoordinate)){
            (data, response, error) in
            if error == nil{
                let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                self.designMapForResponse(responseDictionary: responseDictionary!, locCoordinate: locCoordinate,currentPlace: currentLocation)
            }
        }
        task.resume()
    }
    
    func designMapForResponse(responseDictionary:[String:Any],locCoordinate:CLLocationCoordinate2D,currentPlace:Bool) {
        if responseDictionary.keys.contains(ConstantString.kMainKey) {
            let mainDict:[String:Any] = responseDictionary[ConstantString.kMainKey] as! [String : Any]
            var temp = ConstantString.kBlank
            if (UserDefaults.standard.value(forKey: ConstantString.kTempUnitKey) != nil) {
                let flag = UserDefaults.standard.value(forKey: ConstantString.kTempUnitKey) as! Bool
                if flag{
                    temp = "\(mainDict[ConstantString.kTempKey]!)°C"
                }
                else{
                    let tempString:String = String(describing: mainDict[ConstantString.kTempKey]!)
                    temp = tempString.convertToFahrenheit(temperature: tempString)
                }
            }
            if currentPlace {
                self.currentPlace.text = responseDictionary[ConstantString.kNameKey] as? String
                self.currentTemp.text = temp
            }
            self.addAnnotation(locCoordinate: locCoordinate, place: (responseDictionary[ConstantString.kNameKey] as? String)!, temp: temp)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(locCoordinate,
                                                                      self.regionRadius, self.regionRadius)
            self.mapView.setRegion(coordinateRegion, animated: true)
            self.uiElementStateAfterLoading()
        }
    }
    
    func addAnnotation(locCoordinate:CLLocationCoordinate2D, place:String, temp:String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoordinate
        annotation.title = place
        annotation.subtitle = temp
        
        for currentAnnotation in mapView.annotations{
            if (currentAnnotation.coordinate.latitude == annotation.coordinate.latitude)
                &&  (currentAnnotation.coordinate.longitude == annotation.coordinate.longitude){
                mapView.removeAnnotation(currentAnnotation)
            }
        }
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func bookmarkPlace(_ sender: Any) {
        self.bookmark(latitude: Double(self.selectedLocation!.latitude), longitude: Double(self.selectedLocation!.longitude))
        self.bookmarkButton.isEnabled = false
        self.deleteButton.isEnabled = false
    }
    
    @IBAction func removePlace(_ sender: Any) {
        self.deleteFromCoreData(latitude: self.selectedLocation!.latitude, longitude: self.selectedLocation!.longitude)
        for annotation in mapView.annotations {
            if (annotation.coordinate.latitude == self.selectedLocation!.latitude)
                && (annotation.coordinate.longitude == self.selectedLocation!.longitude) {
                mapView.removeAnnotation(annotation)
                break
            }
        }
        
        self.bookmarkButton.isEnabled = false
        self.deleteButton.isEnabled = false
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedLocation = view.annotation?.coordinate
        self.bookmarkButton.isEnabled = true
        self.deleteButton.isEnabled = true
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = ConstantString.kMapViewPinID
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }

        
        let button = UIButton.init(type: UIButtonType.detailDisclosure)
        button.addTarget(self, action:#selector(fetchWeatherDetails(_:)) , for: UIControlEvents.touchDown)
        pinView?.rightCalloutAccessoryView = button
        
        return pinView
    }
    
    func fetchWeatherDetails(_ sender: Any) {
        self.performSegue(withIdentifier: ConstantString.kDetailWeatherSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ConstantString.kDetailWeatherSegue {
            if let destination = segue.destination as? DetailedWeatherViewController {
                destination.selectedLocation = self.selectedLocation
            }
        }
    }
    
    func bookmark(latitude:Double, longitude:Double) {
        if self.bookmarkAllowedForLocation(latitude: latitude, longitude: longitude) {
            self.saveLocationInCoreData(latitude: latitude, longitude: longitude)
        }
        else{
            self.showAlert(heading: ConstantString.kAlert, message: ConstantString.kBookmarkAlertMessage, buttonTitle: ConstantString.kOk)
        }
    }
    
    func bookmarkAllowedForLocation(latitude:Double, longitude:Double) -> Bool {
        self.savedCoordinate.removeAll()
        self.savedCoordinate = self.FetchFromCoreData()
        var flag = true
        for loc in self.savedCoordinate {
            if (Double(loc.components(separatedBy: ConstantString.kComma).first!)! == latitude)
                && (Double(loc.components(separatedBy: ConstantString.kComma).last!)! == longitude) {
                flag = false
                break
            }
        }
        return flag
    }
        
    func toolbarButtonInitialState() {
        self.bookmarkButton.isEnabled = false
        self.deleteButton.isEnabled = false
        self.helpButton.isEnabled = false
        self.settingsButton.isEnabled = false
        self.activityIndicator.isHidden = true
        self.gpsButton.isHidden = true
    }
    
    func uiElementStateAfterLoading() {
        self.gpsButton.isHidden = false
        self.bookmarkButton.isEnabled = false
        self.deleteButton.isEnabled = false
        self.activityIndicator.isHidden = true
        self.helpButton.isEnabled = true
        self.settingsButton.isEnabled = true
    }
}

