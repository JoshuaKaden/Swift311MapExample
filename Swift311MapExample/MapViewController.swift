//
//  MapViewController.swift
//  Swift311MapExample
//
//  Created by Kaden, Joshua on 12/14/17.
//  Copyright © 2017 NYC DoITT. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewControllerDelegate: class {
    func didChangeRegion(latitude: Double, longitude: Double, withinCircle: Int)
}

class MapViewController: UIViewController {

    weak var delegate: MapViewControllerDelegate?
    
    @IBOutlet private weak var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
    fileprivate var userLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    fileprivate func centerMap() {
        guard let userLocation = userLocation else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
        mapView.setRegion(coordinateRegion, animated: true)
    }

}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationManager.stopUpdatingLocation()
        
        if let userLocation = userLocation {
            if userLocation.coordinate.latitude == location.coordinate.latitude && userLocation.coordinate.longitude == location.coordinate.longitude {
                return
            }
        }
        
        userLocation = location
        centerMap()
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let latitude: Double = mapView.centerCoordinate.latitude
        let longitude: Double = mapView.centerCoordinate.longitude
        
        let zoomWidth = mapView.visibleMapRect.size.width
        let zoomFactor = Int(zoomWidth / 20)
        
        delegate?.didChangeRegion(latitude: latitude, longitude: longitude, withinCircle: zoomFactor)
    }
}
