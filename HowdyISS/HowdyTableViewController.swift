//
//  HowdyTableViewController.swift
//  HowdyISS
//
//  Created by Me on 12/2/18.
//  Copyright © 2018 Ross Co. All rights reserved.
//

import UIKit
import CoreLocation

class HowdyTableViewController: UITableViewController {
    
    let flybyManager = MapViewController()
    let api = LocationController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 
        api.setup()
        
        // reload the table when we get any new flybys
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: Notification.Name("flybysAdded"), object: nil)
        
    }

    @objc func reloadTable() {
        tableView.reloadData()
    }
    
    /// Returns the number of sections in the table
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// Returns the number of items in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return api.getNumCurrentFlybys()
    }
    
    /// Creates, configures, and returns a table cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HowdyCell", for: indexPath)

        guard let flyby: FlyBy = api.getFlybyAt(row: indexPath.row) else {
            print("no flyby at index \(indexPath.row)!")
            return cell
        }

        if flyby.minUntilOccurs() < 0 {
            cell.textLabel?.text = "ISS is flying over you right now!"
        } else {
            cell.textLabel?.text = "Flyby in \(flyby.prettyWhen())"
        }

        cell.detailTextLabel?.text = "Will be overhead for \(flyby.prettyDuration())"
        return cell
    }

    /// Fires whenever the view is shown
    override func viewDidAppear(_ animated: Bool) {
        api.pullFlybys()
    }
    

}
