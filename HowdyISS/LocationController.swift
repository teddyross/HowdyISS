//
//  WebApi.swift
//  HowdyISS
//
//  Created by Me on 12/8/18.
//  Copyright © 2018 Ross Co. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class LocationController: UIViewController, CLLocationManagerDelegate {
    
    var ISSLocationTimer: Timer? = nil
    var currentFlybys: [FlyBy] = [];
    let notifications = HowdyUserNotificationController()
    let locationManager = CLLocationManager()
    var currentUserLocation: CLLocationCoordinate2D? = nil
    var hasBeenSetup: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setup() {
        
        if (hasBeenSetup) {
            print("LocationController already setup!")
            return
        }
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1000 // meters
        locationManager.startUpdatingLocation()
        
        /// Listen for when the user changes the ISS position polling interval in settings
        NotificationCenter.default.addObserver(self, selector: #selector(self.pollIntervalChanged(_:)), name: Notification.Name("pollIntervalChanged"), object: nil)
        
        /// listen for when we get the user's location
        NotificationCenter.default.addObserver(self, selector: #selector(self.pullFlybys), name: Notification.Name("gotUserLocation"), object: nil)
        
        hasBeenSetup = true
        
    }
    
    /// Invalidate the current timer and create a new one with user specified seconds
    @objc func pollIntervalChanged(_ notification: NSNotification) {
        stopTrackingISSLocation()
        if let sliderValue: Any? = notification.userInfo?["value"] {
            startTrackingISSLocation(seconds: sliderValue as! TimeInterval)
        }
    }
    
    /// Fires each time the user's location has been updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentUserLocation = location.coordinate
            NotificationCenter.default.post(name: Notification.Name("gotUserLocation"), object: nil)
        }
    }
    
    /// Fires when we failed with an error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager error: \((error as NSError).localizedDescription)")
        print("Verify that the location is being simulated")
        alertUserABoutLocation()
    }
    
   
    func alertUserABoutLocation() {
        let alert = UIAlertController(title: "You must simulate a location.", message: "Please simulate a location under the 'debug' file menu.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        // self.present(alert, animated: true, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
    /// Retrieves realtime data about the ISS
    @objc func pollCurrentISSLocation() {
        
        guard let url = URL(string: "http://api.open-notify.org/iss-now.json") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, resp, error) in
            
            if let data = data {
                if let coor = self.parseISSLocation(data: data) {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("gotISSLocation"), object: nil, userInfo: ["value": coor])
                    }
                }
                else {
                    print("could not parse iss location")
                }
            }
            else {
                print("could not get iss data")
            }
        }
        
        task.resume()
    }
    
    /// Begin tracking the ISS's location
    func startTrackingISSLocation(seconds: TimeInterval) {
        print("now tracking the ISS's location")
        pollCurrentISSLocation()
        ISSLocationTimer = Timer.scheduledTimer(
            timeInterval: seconds,
            target: self,
            selector: #selector(pollCurrentISSLocation),
            userInfo: nil,
            repeats: true
        )
    }
    
    func getCurrentFlybys() -> [FlyBy] {
        return currentFlybys
    }
    func getNumCurrentFlybys() -> Int {
        return currentFlybys.count
    }
    
    func getFlybyAt(row: Int) -> FlyBy? {
        return currentFlybys[row]
    }
    
    @objc func stopTrackingISSLocation() {
        print("stopped tracking the ISS's location")
        ISSLocationTimer?.invalidate()
    }

    func parseISSLocation(data: Data) -> CLLocationCoordinate2D? {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("failed to parse json")
                return nil
            }
            guard let raw = json["iss_position"] as? [String: String] else {
                print("failed to parse iss position")
                return nil
            }
            guard let lat = raw["latitude"] else {
                print("failed to parse latitude")
                return nil
            }
            guard let lon = raw["longitude"] else {
                print("failed to parse longitude")
                return nil
            }
            guard let latitude = CLLocationDegrees(lat) else {
                print("failed to create latitude")
                return nil
            }
            guard let longitude = CLLocationDegrees(lon) else {
                print("failed to create longitude")
                return nil
            }
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
        } catch let error as NSError {
            print("error parsing json: \(error.localizedDescription)")
            return nil
        }
        
    }
    
    func getISSSpeed() -> String {
        // the speed of the ISS doesn't change THAT much, on average this is its speed (wikipedia)
        // We can easily get the speed using the distance between the last two points and the elapsed time between them
        return "27,724 mph"  // TODO determine ISS speed
    }
    
    /// Pulls the people currently on the ISS (unfinished)
    func pullPeopleInSpace() {
        // TODO: pull the number of people on the ISS
        /*
         {
             "message": "success",
             "number": NUMBER_OF_PEOPLE_IN_SPACE,
             "people": [
                 {"name": NAME, "craft": SPACECRAFT_NAME},
                 ...
             ]
         }
         */
        
    }
    
    /// Pulls the last 5 flybys of the ISS over the user
    @objc func pullFlybys() {
        
        guard let loc = currentUserLocation else {
            print("don't have user location yet")
            return
        }
        
        let url = URL(string: "http://api.open-notify.org/iss-pass.json?lat=\(loc.latitude)&lon=\(loc.longitude)")
        
        let task = URLSession.shared.dataTask(with: url!) {
            (data, resp, error) in
            
            guard let data = data else {
                print("failed to pull flyby data")
                return
            }
            
            do {
                try self.parseReply(data: data)
                
                // let everyone know that we have updated our flybys
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("flybysAdded"), object: nil)
                }

                // offer the notification system the next flyby. it decides to send it or not.
                if let nextFlyby: FlyBy = self.getNextFlyby() {
                    self.notifications.offerNextFlyBy(flyby: nextFlyby)
                }
                
            } catch let error as NSError {
                print("failed to parse json: \(error.localizedDescription)")
            }
            
        }

        task.resume()
    }
    

    /// Parses the json data returned from the web api
    func parseReply(data: Data) throws {
        print("pulled flybys")
        
        // attempt to parse
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
        let resp = json["response"] as! [[String: Int]]
        
        // save the flyby data
        currentFlybys = []
        for d in resp {
            currentFlybys.append(
                FlyBy(unixTime: d["risetime"]!, duration: d["duration"]!)
            )
        }

    }
    
    /// Gets the next upcoming flyby in our list of flybys
    func getNextFlyby() -> FlyBy? {
        if let first = currentFlybys.first {
            return first
        }
        return nil
    }
    
    
}

