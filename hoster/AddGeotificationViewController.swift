//
//  AddGeotificationViewController.swift
//  iddc
//
//  Created by Zhihui Tang on 2017-09-21.
//  Copyright © 2017 eBuilder. All rights reserved.
//

import UIKit
import MapKit

protocol AddGeotificationsViewControllerDelegate {
    func addGeotificationViewController(controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: AddressIdenfier, note: String)
}

enum AddressIdenfier: String {
    case home = "Home"
    case office = "Office"
}

class AddGeotificationViewController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var delegate: AddGeotificationsViewControllerDelegate?
    var identifier: AddressIdenfier = .home
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.locationManager.requestWhenInUseAuthorization()
    }
    @IBAction func zoomInToCurrentLocation(_ sender: UIButton) {
        mapView.zoomToUserLocation()
    }
    
    @IBAction func onAdd(_ sender: UIBarButtonItem) {
        let coordinate = mapView.centerCoordinate
        let radius = Double(radiusTextField.text!) ?? 0
//        let identifier = NSUUID().uuidString
        let note = noteTextField.text
        delegate?.addGeotificationViewController(controller: self, didAddCoordinate: coordinate, radius: radius, identifier: identifier, note: note!)
    }
    
}
