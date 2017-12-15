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
    var serviceRequests: [ServiceRequest]? {
        didSet {
            DispatchQueue.main.async {
                self.removePins()
                self.addPins()
            }
        }
    }
    
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
    
    private func addPins() {
        guard let serviceRequests = serviceRequests else { return }
        let serviceRequestPins = serviceRequests.flatMap { ServiceRequestPin(serviceRequest: $0) }
        mapView.addAnnotations(serviceRequestPins)
    }
    
    fileprivate func centerMap() {
        guard let userLocation = userLocation else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    fileprivate func removePins() {
        mapView.removeAnnotations(mapView.annotations)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? ServiceRequestPin else { return nil }
            
        let identifier = "pin"
        var view: MKPinAnnotationView
        
        // Check to see if a reusable annotation view is available before creating a new one.
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // else create a new annotation view
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
        }
        
        view.pinTintColor = annotation.pinTintColor
        
        if self.serviceRequests?.count ?? 0 > 50 {
            view.animatesDrop = false
        } else {
            view.animatesDrop = true
        }
        
        return view
    }
}
