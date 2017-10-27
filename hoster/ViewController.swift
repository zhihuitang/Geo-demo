//
//  ViewController.swift
//  hoster
//
//  Created by Zhihui Tang on 2017-09-06.
//  Copyright © 2017 eBuilder. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import AdSupport
import SwiftMagic

let TABLE_CAPACITY = 500

var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .long
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    return formatter
}()


struct PreferencesKeys {
    static let savedItems = "savedItems"
}

class ViewController: UIViewController {
    
    @IBOutlet weak var officeLocation: UILabel!
    @IBOutlet weak var homeLocation: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var switchBtn: UISwitch!
    var geoHome: Geotification? {
        didSet {
            self.homeLocation.text = geoHome?.address ?? ""
        }
    }
    
    var geoOffice: Geotification? {
        didSet {
            self.officeLocation.text = geoOffice?.address ?? ""
        }
    }
    
    let geocoder = CLGeocoder()
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        return manager
    }()
   
    override func viewDidAppear(_ animated: Bool) {
        switchBtn.isEnabled = self.geoOffice != nil || self.geoHome != nil
    }
    
    @IBAction func switchButtonPressed(_ sender: UISwitch) {
        if sender.isOn {
            appDelegate.locationManager.requestAlwaysAuthorization()
            appDelegate.locationManager.startUpdatingLocation()
            startMonitoring(geotification: self.geoOffice)
            startMonitoring(geotification: self.geoHome)
        } else {
            appDelegate.locationManager.stopUpdatingLocation()
            stopMonitoring(geotification: self.geoOffice)
            stopMonitoring(geotification: self.geoHome)
        }
    }
    
    override func viewDidLoad() {
        let regions = locationManager.monitoredRegions
        switchBtn.isOn = regions.count > 0
        for region in regions {
            Logger.d("monitoring: \(region.identifier)")
        }
        
        self.geoHome = loadGeotifications(identifier: AddressIdenfier.home.rawValue)
        self.geoOffice = loadGeotifications(identifier: AddressIdenfier.office.rawValue)
        
    }
    
    func loadGeotifications(identifier: String) -> Geotification? {
        if let savedItem = UserDefaults.standard.object(forKey: identifier) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: savedItem) as? Geotification
        }
        return nil
    }
    
    func saveGeotification(geotification: Geotification) {
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: geotification), forKey: geotification.identifier)
    }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .long
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return formatter
    }()

    @IBAction func zoomToCurrentLocation(_ sender: UIButton) {
        mapView.zoomToUserLocation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        if let destinationVC = segue.destination as? AddGeotificationViewController, let identifier = segue.identifier {
            destinationVC.delegate = self
            destinationVC.identifier = identifier == "addGeotificationOffice" ? .office : .home
            destinationVC.navigationItem.title = "Set \(destinationVC.identifier)"
        }
    }
    
    func startMonitoring(geotification: Geotification?) {
        guard geotification != nil else { return }
        
        saveGeotification(geotification: geotification!)
        
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            showAlert(withTitle:"Warning", message: "Your monitoring request is saved but will only be activated once you grant requestAlwaysAuthorization permission to access the device location.")
        }
        let region = self.region(withGeotification: geotification!)
        locationManager.startMonitoring(for: region)
        
    }
    
    func stopMonitoring(geotification: Geotification?) {
        guard geotification != nil else { return }
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification!.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }

    
    func region(withGeotification geotification: Geotification) -> CLCircularRegion {
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        //
        Logger.d("start monitoring")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }

}


extension ViewController: AddGeotificationsViewControllerDelegate {
    func addGeotificationViewController(controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: AddressIdenfier, note: String) {
        //controller.dismiss(animated: true, completion: nil)
        
        controller.navigationController?.popViewController(animated: true)
        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier.rawValue, note: note)
        
        if identifier == .office {
            self.geoOffice = geotification
        } else {
            self.geoHome = geotification
        }
        self.switchBtn.isEnabled = true
        
        //startMonitoring(geotification: geotification)
        //saveAllGeotifications()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            var address = "(\(coordinate.latitude),\(coordinate.longitude))"
            if let placemark = placemarks?.first,
                let streetNumber = placemark.subThoroughfare,
                let street = placemark.thoroughfare,
                let city = placemark.locality,
                let country = placemark.country {
                address = "\(streetNumber) \(street) \(city), \(country)"
            }
            if identifier == .office {
                self?.geoOffice?.address = address
                self?.officeLocation.text = address
            } else {
                self?.geoHome?.address = address
                self?.homeLocation.text = address
            }

        }

    }
}


