//
//  myWeatherTests.swift
//  myWeatherTests
//
//  Created by Utsha Guha on 25-7-18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

import XCTest
import MapKit
@testable import myWeather

class myWeatherTests: XCTestCase {
    
    var vc = ViewController()
    var settingVC = SettingViewController()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testLoadLocation()  {
        let savedLocations = vc.FetchFromCoreData()
        XCTAssert(savedLocations.count>0, ConstantString.kUnitTestBookmarkError)
    }
    
    func testCurrentLocation() {
        let locManager = CLLocationManager()
        var currentLocation: CLLocation!
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestAlwaysAuthorization()
        locManager.startUpdatingHeading()
        currentLocation = locManager.location
        XCTAssert((currentLocation.coordinate.latitude == vc.getCurrentLocationCoordinate().latitude) && (currentLocation.coordinate.longitude == vc.getCurrentLocationCoordinate().longitude), ConstantString.kUnitTestCurrLocError)
    }
    
    func testCoreData() {
        let randomLatitude = 23.0
        let randomLongitude = 25.0
        
        vc.saveLocationInCoreData(latitude: randomLatitude, longitude: randomLongitude)
        let savedLocArray = vc.FetchFromCoreData()
        var saveSuccessFlag = false
        
        for loc in savedLocArray {
            if (Double(loc.components(separatedBy: ConstantString.kComma).first!)! == randomLatitude)
                && (Double(loc.components(separatedBy: ConstantString.kComma).last!)! == randomLongitude) {
                saveSuccessFlag = true
                break
            }
        }
        XCTAssert(saveSuccessFlag == true, ConstantString.kUnitTestSaveCDError)
        
        if saveSuccessFlag {
            vc.deleteFromCoreData(latitude: randomLatitude, longitude: randomLongitude)
            let savedLocArray2 = vc.FetchFromCoreData()
            var delSuccessFlag = true
            
            for loc in savedLocArray2 {
                if (Double(loc.components(separatedBy: ConstantString.kComma).first!)! == randomLatitude)
                    && (Double(loc.components(separatedBy: ConstantString.kComma).last!)! == randomLongitude) {
                    delSuccessFlag = false
                    break
                }
            }
            
            XCTAssert(delSuccessFlag == true, ConstantString.kUnitTestDelCDError)
        }
    }
    
    func testBookmark() {
        let randomLatitude = 25.0
        let randomLongitude = 27.0
        vc.bookmark(latitude:randomLatitude, longitude:randomLongitude)
        let savedLocArray = vc.FetchFromCoreData()
        var bookmarkFlag = false
        
        for loc in savedLocArray {
            if (Double(loc.components(separatedBy: ConstantString.kComma).first!)! == randomLatitude)
                && (Double(loc.components(separatedBy: ConstantString.kComma).last!)! == randomLongitude) {
                bookmarkFlag = true
                break
            }
        }
        XCTAssert(bookmarkFlag == true, ConstantString.kUnitTestBookrkError)
        vc.deleteFromCoreData(latitude: randomLatitude, longitude: randomLongitude)
    }
    
    func testResetBookmark() {
        settingVC.deleteAllFromCoreData()
        let savedLocations = vc.FetchFromCoreData()
        XCTAssert(savedLocations.count == 0, ConstantString.kUnitTestResetError)
    }
    
}
