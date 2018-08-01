//
//  SettingViewController.swift
//  myWeather
//
//  Created by Utsha Guha on 27-7-18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SettingViewController: UIViewController {
    @IBOutlet weak var metricSwitch: UISwitch!
    @IBOutlet weak var resetPlaces: UIButton!
    
    @IBAction func resetAll(_ sender: Any) {
        self.deleteAllFromCoreData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ConstantString.kResetAllNotification), object: nil)
    }
    
    @IBAction func tempUnitChanged(_ sender: Any) {
        UserDefaults.standard.set(self.metricSwitch.isOn, forKey: ConstantString.kTempUnitKey)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserDefaults.standard.value(forKey: ConstantString.kTempUnitKey) != nil) {
            let flag = UserDefaults.standard.value(forKey: ConstantString.kTempUnitKey)! as! Bool
            self.metricSwitch.setOn(flag, animated: true)
        }
    }
}
