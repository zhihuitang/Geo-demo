//
//  BackgroundFetchViewController.swift
//  iddc
//
//  Created by Zhihui Tang on 2017-09-13.
//  Copyright © 2017 eBuilder. All rights reserved.
//

import UIKit

class BackgroundFetchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Background Fetch"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.data = appDelegate.backgroundFetchHistory
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var tableView: UITableView!
    var data = [Date]() {
        didSet {
            self.tableView?.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BackgroundFetchItem", for: indexPath)

        let indexNumber = data.count - indexPath.row - 1
        var diff: TimeInterval = 0
        if indexNumber > 0 {
            diff = data[indexNumber].timeIntervalSince(data[indexNumber-1])
        }
        let text = String(format: "%@, %.1f", (dateFormatter.string(from: data[indexNumber])),diff)
        
        cell.textLabel!.text = "\(indexNumber). \(text)"
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
