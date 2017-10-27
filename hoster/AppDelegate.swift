//
//  AppDelegate.swift
//  hoster
//
//  Created by Zhihui Tang on 2017-09-06.
//  Copyright © 2017 eBuilder. All rights reserved.
//

import UIKit
import CoreLocation
import AdSupport
import SwiftMagic

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationHistory = [String]() {
        didSet {
            if locationHistory.count > TABLE_CAPACITY {
                let range = locationHistory.startIndex..<locationHistory.index(locationHistory.startIndex, offsetBy: locationHistory.count-TABLE_CAPACITY)
                locationHistory.removeSubrange(range)
            }
        }
    }
    
    var backgroundFetchHistory = [Date]() {
        didSet {
            if backgroundFetchHistory.count > TABLE_CAPACITY {
                let range = backgroundFetchHistory.startIndex..<backgroundFetchHistory.index(backgroundFetchHistory.startIndex, offsetBy: backgroundFetchHistory.count-TABLE_CAPACITY)
                backgroundFetchHistory.removeSubrange(range)
            }
        }
    }


    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.allowsBackgroundLocationUpdates = true
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        //manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        return manager
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
        UIApplication.shared.cancelAllLocalNotifications()

        locationManager.delegate = self
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let navc = window?.rootViewController as? UINavigationController, let _ = navc.viewControllers.first as? ViewController {
            backgroundFetchHistory.append(Date())
            completionHandler(.newData)
        }
    }
    
    
    func handleEvent(forRegion region: CLRegion!, identifier: String, action: RegionAction) {
        Logger.d("Geofence triggered!")
        // Show an alert if application is active
        var reminder = ""
        if action == .onExit {
            // stop data usage calculate
        } else {
            
        }
        let message = "\(action.rawValue): \(identifier) \(reminder)"
        if UIApplication.shared.applicationState == .active {
            //guard let message = note(fromRegionIdentifier: region.identifier) else { return }
            window?.rootViewController?.showAlert(withTitle: nil, message: message)
        } else {
            // Otherwise present a local notification
            let notification = UILocalNotification()
            //notification.alertBody = note(fromRegionIdentifier: region.identifier)
            notification.alertBody = message
            notification.soundName = "Default"
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
    
    func note(fromRegionIdentifier identifier: String) -> String? {
        let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedItems) as? [NSData]
        let geotifications = savedItems?.map { NSKeyedUnarchiver.unarchiveObject(with: $0 as Data) as? Geotification }
        let index = geotifications?.index { $0?.identifier == identifier }
        return index != nil ? geotifications?[index!]?.note : nil
    }
}


extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            Logger.d("didEnterRegion\(region.identifier)")
            handleEvent(forRegion: region, identifier: region.identifier, action: .onEntry)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            Logger.d("didExitRegion \(region.identifier)")
            handleEvent(forRegion: region, identifier: region.identifier, action: .onExit)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.last != nil else {
            return
        }
        let location = locations.last!

        let status =  UIApplication.shared.applicationState == .active ? "F" : "B"
        
        let locationItem = String(format: "%@, %@|(%.8f, %.8f)", status, dateFormatter.string(from: Date()), location.coordinate.latitude, location.coordinate.longitude)
        locationHistory.append(locationItem)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

}


