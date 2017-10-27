//
//  LocationHistoryViewController.swift
//  iddc
//
//  Created by Zhihui Tang on 2017-09-13.
//  Copyright © 2017 eBuilder. All rights reserved.
//

import UIKit

class LocationHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.data = appDelegate.locationHistory
        self.navigationItem.title = "Location Updates"
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var tableView: UITableView!
    var data = [String]() {
        didSet {
            self.tableView?.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationItem", for: indexPath)
        let indexNumber = data.count - indexPath.row - 1
        let textArray = data[indexNumber].components(separatedBy: "|")
        cell.textLabel!.text = String(format: "%3d. %@", indexNumber, textArray[0])
        cell.detailTextLabel!.text = String(format: "       %@", textArray[1])
        cell.detailTextLabel!.textAlignment = .right
        //cell.textLabel!.text = "\(indexPath.row). \(data[indexPath.row])"
        return cell

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

}
