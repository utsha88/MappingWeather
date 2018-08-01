//
//  ViewControllerExtension.swift
//  myWeather
//
//  Created by Utsha Guha on 27-7-18.
//  Copyright © 2018 Utsha Guha. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension UIViewController{
    func showAlert(heading:String, message:String, buttonTitle:String) {
        let alert = UIAlertController(title: heading, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteAllFromCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ConstantString.kCoreDataPlaceEntity)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                context.delete(data)
            }
        } catch {
            self.showAlert(heading: ConstantString.kAlert, message: ConstantString.kBookmarkAlertMessage, buttonTitle: ConstantString.kOk)
        }
        do {
            try context.save()
        } catch {
            self.showAlert(heading: ConstantString.kAlert, message: ConstantString.kBookmarkAlertMessage, buttonTitle: ConstantString.kOk)
        }
    }
    
    func FetchFromCoreData() -> [String] {
        //self.savedCoordinate.removeAll()
        var savedLoc:[String] = []
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ConstantString.kCoreDataPlaceEntity)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                let myData = data.value(forKey: ConstantString.kPlaceAttribute) as! String
                savedLoc.append(myData)
            }
        } catch {
            self.showAlert(heading: ConstantString.kError, message: ConstantString.kCoreDataGenericMessage, buttonTitle: ConstantString.kOk)
        }
        do {
            try context.save()
        } catch {
            self.showAlert(heading: ConstantString.kError, message: ConstantString.kCoreDataGenericMessage, buttonTitle: ConstantString.kOk)
        }
        return savedLoc
    }
    
    func saveLocationInCoreData(latitude:Double,longitude:Double) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: ConstantString.kCoreDataPlaceEntity, in: context)
        let newAlbum = NSManagedObject(entity: entity!, insertInto: context)
        let coordinate =  String(latitude) + ConstantString.kComma + String(longitude)
        newAlbum.setValue(coordinate, forKey: ConstantString.kPlaceAttribute)
        do {
            try context.save()
        } catch {
            self.showAlert(heading: ConstantString.kError, message: ConstantString.kCoreDataGenericMessage, buttonTitle: ConstantString.kOk)
        }
    }
    
    func deleteFromCoreData(latitude:Double,longitude:Double) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ConstantString.kCoreDataPlaceEntity)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            let coordinate = String(latitude) + ConstantString.kComma + String(longitude)
            for data in result as! [NSManagedObject] {
                let myData = data.value(forKey: ConstantString.kPlaceAttribute) as! String
                if myData == coordinate {
                    context.delete(data)
                    break
                }
            }
        } catch {
            self.showAlert(heading: ConstantString.kError, message: ConstantString.kCoreDataGenericMessage, buttonTitle: ConstantString.kOk)
        }
        do {
            try context.save()
        } catch {
            self.showAlert(heading: ConstantString.kError, message: ConstantString.kCoreDataGenericMessage, buttonTitle: ConstantString.kOk)
        }
    }
}
