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
    private var oldCenterMapPoint: MKMapPoint?
    var serviceRequests: [ServiceRequest]? {
        didSet {
            DispatchQueue.main.async {
                self.removePins()
                self.addPins()
            }
        }
    }
    var userLocation: CLLocation? {
        didSet {
            centerMap()
        }
    }

    @IBOutlet private weak var mapView: MKMapView!
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func addPins() {
        guard let serviceRequests = serviceRequests else { return }
        let serviceRequestPins = serviceRequests.flatMap { ServiceRequestPin(serviceRequest: $0) }
        mapView.addAnnotations(serviceRequestPins)
    }
    
    fileprivate func calculateMetersOnMap() -> Double {
        let midY = mapView.centerMapPoint.y
        let visibleRectangle = mapView.visibleMapRect
        let eastPoint = MKMapPointMake(MKMapRectGetMinX(visibleRectangle), midY)
        let westPoint = MKMapPointMake(MKMapRectGetMaxX(visibleRectangle), midY)
        return MKMetersBetweenMapPoints(eastPoint, westPoint)
    }
    
    fileprivate func centerMap() {
        guard let userLocation = userLocation else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 400, 400)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    fileprivate func removePins() {
        mapView.removeAnnotations(mapView.annotations)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let pin = view.annotation as? ServiceRequestPin else { return }
        let vc = DetailViewController()
        vc.serviceRequest = pin.serviceRequest
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if self.oldCenterMapPoint == nil {
            self.oldCenterMapPoint = mapView.centerMapPoint
        }
        let oldCenterMapPoint = self.oldCenterMapPoint!
        
        let centerMapPoint = mapView.centerMapPoint
        if oldCenterMapPoint != centerMapPoint && MKMetersBetweenMapPoints(centerMapPoint, oldCenterMapPoint) < 100 {
            // too little difference; don't reload
            return
        }
        
        self.oldCenterMapPoint = centerMapPoint
        
        let latitude: Double = mapView.centerCoordinate.latitude
        let longitude: Double = mapView.centerCoordinate.longitude
        let meters: Double = calculateMetersOnMap()
        delegate?.didChangeRegion(latitude: latitude, longitude: longitude, withinCircle: Int(meters / 2))
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
        
        if self.serviceRequests?.count ?? 0 > 25 {
            view.animatesDrop = false
        } else {
            view.animatesDrop = true
        }
        
        return view
    }
}

// MARK: - MKMapView center map point

fileprivate extension MKMapView {
    var centerMapPoint: MKMapPoint {
        let visibleRectangle = visibleMapRect
        return MKMapPointMake(MKMapRectGetMidX(visibleRectangle), MKMapRectGetMidY(visibleRectangle))
    }
}

// MARK: - MKMapPoint inequality

fileprivate func !=(lhs: MKMapPoint, rhs: MKMapPoint) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y
}
