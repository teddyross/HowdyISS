//
//  FlybyViewController.swift
//  HowdyISS
//
//  Created by Me on 12/2/18.
//  Copyright © 2018 Ross Co. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!

    let api = LocationController()
    var previousAnnotation: MKPointAnnotation? = nil;
    var coordinates: [CLLocationCoordinate2D] = []       // TODO use MKMapPoint instead of CLLocationCoordinate2D
    var trackingLine: MKPolyline? = nil
    var shouldCenterMap = true

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView?.delegate = self
        mapView?.mapType = .satelliteFlyover
        mapView?.isZoomEnabled = true
        mapView?.isScrollEnabled = true

        api.startTrackingISSLocation(seconds: 20.0)
        
        /// Listen for when the user changes the alert time before an alert is fired
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateISSLocation(_:)), name: Notification.Name("gotISSLocation"), object: nil)

    }


    @objc func updateISSLocation(_ notification: NSNotification) {
        if let coor = notification.userInfo?["value"] as? CLLocationCoordinate2D {
            setMapPosition(coordinate: coor)
        }
    }

    
    func setMapPosition(coordinate: CLLocationCoordinate2D) {
        
            guard let map = mapView else {
                print("mapview not created yet!")
                return
            }
        
            // to prevent annoyance, center the map initially and then stop centering
            if shouldCenterMap {
                map.setCenter(coordinate, animated: true)
                shouldCenterMap = false
            }

            let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "ISS"
                annotation.subtitle = "\(coordinate.latitude), \(coordinate.longitude), speed: \(api.getISSSpeed())"
        
            map.addAnnotation(annotation)
            
            // remove the last one or we will be spawning many pins on our map
            if previousAnnotation != nil {
                map.removeAnnotation(previousAnnotation!)
            }

            // keep the last one so we can delete it when we get a newer one
            previousAnnotation = annotation

            // add to our list that we use to create the tracking line
            coordinates.append(coordinate)
        
            drawLine()
    }
    
    func drawLine() {

        if trackingLine != nil {
            mapView?.removeOverlay(trackingLine!)
        }

        trackingLine = MKPolyline(coordinates: coordinates, count: coordinates.count)

        if trackingLine != nil {
            mapView?.addOverlay(trackingLine!)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .orange
            renderer.lineWidth = 2.0
            return renderer
        }

        print("cannot render polyline")
        return MKOverlayRenderer()
    }
    
    func setupMapView() {
        mapView?.delegate = self
        mapView?.mapType = .satelliteFlyover
        mapView?.isZoomEnabled = true
        mapView?.isScrollEnabled = true
    }
    



    
}
