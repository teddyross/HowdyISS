//
//  HowdyUserNotifyManager.swift
//  HowdyISS
//
//  Created by Me on 12/3/18.
//  Copyright © 2018 Ross Co. All rights reserved.
//

import UIKit
import UserNotifications

class HowdyUserNotificationController:  UIViewController, UNUserNotificationCenterDelegate {
    
    var alertsAreEnabled: Bool = true
    var alertMinutes: Int = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Make this class a delegate of the notification center
        UNUserNotificationCenter.current().delegate = self
        
        // ask user if this is okay
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
                // TODO: handle errors and disallowing
        })
        
        /// Listen for when the user enables or disables notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.showAlertsChanged(_:)), name: Notification.Name("alertsAreEnabledChanged"), object: nil)
        
        /// Listen for when the user changes the alert time before an alert is fired
        NotificationCenter.default.addObserver(self, selector: #selector(self.alertTimeChanged(_:)), name: Notification.Name("alertTimeChanged"), object: nil)
        
    }
    
    @objc func alertTimeChanged(_ notification: NSNotification) {
        if let value = notification.userInfo?["value"] as? Float {
            alertMinutes = Int(value)
        }
    }
    
    /// Fires when the user enables or disables notifications
    @objc func showAlertsChanged(_ notification: NSNotification) {
        if let value: Any? = notification.userInfo?["value"] {
            alertsAreEnabled = value as! Bool
        }
    }
    
    func createNotification(flyby: FlyBy) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        
        if (flyby.secUntilOccurs() < 0) {
            content.subtitle = "Open HowdyISS to view live footage"
            content.title = "ISS is flying over right now!"
        }
        else {
            content.subtitle = "Gonna fly over in \(flyby.prettyWhen())"
            content.title = "ISS Flyby soon!"
        }
        
        content.body = "They will be overhead for \(flyby.prettyDuration())"
        return content
    }
    
    /// Sends notification if the user has enabled it
    func offerNextFlyBy(flyby: FlyBy) {
        
        if (alertsAreEnabled && flyby.minUntilOccurs() < alertMinutes) {
            let content = createNotification(flyby: flyby)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    
}
