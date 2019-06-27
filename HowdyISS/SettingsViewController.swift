//
//  SettingsViewController.swift
//  HowdyISS
//
//  Created by Me on 12/4/18.
//  Copyright © 2018 Ross Co. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var mapType: UIPickerView!
    @IBOutlet weak var alertTime: UISlider!
    @IBOutlet weak var showAlerts: UISwitch!
    @IBOutlet weak var pollingText: UITextView!
    @IBOutlet weak var alertTimeText: UITextView!
    @IBOutlet weak var pollingInterval: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Set the initial text for the ISS position polling interval.
        /// open-notify.org does not recommend polling in less than 5 second intervals
        if let value: Float = pollingInterval?.value {
            pollingText.text = "Get ISS location every \(Int(value)) seconds"
        }
        
        /// Set the initial text for the alert time
        if let value: Float = alertTime?.value {
            alertTimeText.text = "Alert me \(Int(value)) min before flyby"
        }
        
    }
    
    /// Fires when the user changes the ISS position polling interval
    @IBAction func pollIntervalChanged(_ sender: Any) {
        if let value: Float = pollingInterval?.value {
            pollingText.text = "Get ISS location every \(Int(value)) seconds"
            NotificationCenter.default.post(name: Notification.Name("pollIntervalChanged"), object: nil, userInfo: ["value": value])
        }
    }
    
    /// Fires when the user turns alerts on or off
    @IBAction func showAlertsChanged(_ sender: Any) {
        if let value: Bool = showAlerts?.isOn {
            NotificationCenter.default.post(name: Notification.Name("alertsAreEnabledChanged"), object: nil, userInfo: ["value": value])
        }
    }
    
    /// Fires when the user changes the alert time
    @IBAction func alertTimeChanged(_ sender: Any) {
        if let value: Float = alertTime?.value {
            alertTimeText.text = "Alert me \(Int(value)) min before flyby"
            NotificationCenter.default.post(name: Notification.Name("alertTimeChanged"), object: nil, userInfo: ["value": value])
        }
        
    }
    
}
